using System.Globalization;
using System.Text.Json;
using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Common.Infrastructure.Jobs;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Commands;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Infrastructure.Jobs;

/// <summary>
/// Renders the queued export jobs of <c>rpt_export_job</c> (reporting.v1.yaml <c>createExport</c>: "Hangfire
/// işi"). It is a recurring sweep rather than a fire-and-forget enqueue because the API containers run with
/// <c>Jobs__Enabled=false</c> and therefore have no <c>IBackgroundJobClient</c> at all — the request only
/// inserts the row, and the single worker picks it up wherever the request was served.
/// </summary>
public sealed class ReportExportRunnerJob(
    IServiceScopeFactory scopeFactory,
    ILogger<ReportExportRunnerJob> logger)
{
    public const string JobId = "reporting-export-runner";

    /// <summary>Every minute — the same cadence spec §15 gives the reporting read model.</summary>
    public const string Cron = "* * * * *";

    /// <summary>Jobs rendered per sweep; the per-user cap is three, so this drains a busy tenant quickly.</summary>
    public const int BatchSize = 10;

    [DisableConcurrentExecution(timeoutInSeconds: 900)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        IReadOnlyList<uint> tenantIds;
        using (var scope = scopeFactory.CreateScope())
        {
            tenantIds = await scope.ServiceProvider
                .GetRequiredService<IReportingTenantScanner>()
                .GetActiveTenantsAsync(cancellationToken)
                .ConfigureAwait(false);
        }

        foreach (var tenantId in tenantIds)
        {
            await RunTenantAsync(tenantId, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task RunTenantAsync(uint tenantId, CancellationToken cancellationToken)
    {
        IReadOnlyList<long> due;
        using (var scope = TenantScope(tenantId))
        {
            due = await scope.ServiceProvider
                .GetRequiredService<IExportJobRepository>()
                .DueJobIdsAsync(BatchSize, cancellationToken)
                .ConfigureAwait(false);
        }

        foreach (var jobId in due)
        {
            await RenderAsync(tenantId, jobId, cancellationToken).ConfigureAwait(false);
        }
    }

    private async Task RenderAsync(uint tenantId, long jobId, CancellationToken cancellationToken)
    {
        // One scope per job so a failure never poisons the next job's change tracker.
        using var scope = TenantScope(tenantId);
        var services = scope.ServiceProvider;
        var repository = services.GetRequiredService<IExportJobRepository>();
        var unitOfWork = services.GetRequiredService<IReportingUnitOfWork>();
        var clock = services.GetRequiredService<IClock>();

        var job = await repository.GetAsync(jobId, cancellationToken).ConfigureAwait(false);
        if (job is null || job.Status != ExportStatus.Queued)
        {
            return;
        }

        job.Start(clock.UtcNow);
        await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        try
        {
            var renderer = services.GetServices<IExportRenderer>().FirstOrDefault(r => r.Format == job.Format)
                ?? throw new NotSupportedException($"No renderer for export format {job.Format}.");

            var filter = new ReportRunFilter(
                job.ReportCode,
                ReportingJson.Deserialize<Dictionary<string, JsonElement>>(job.ParametersJson) ?? [],
                // The worker has no HTTP principal, so the scope frozen on the row is the only restriction
                // there is; reading it back is what keeps a branch user's export a branch user's export.
                job.LocationScopeJson is null
                    ? LocationScope.Unrestricted
                    : LocationScope.RestrictedTo(ReportingJson.Deserialize<uint[]>(job.LocationScopeJson) ?? []),
                job.IncludeCost,
                Page: 1,
                Size: IReportRunner.ExportRowCap,
                SortKey: null,
                SortDescending: false);

            var dataSet = await services.GetRequiredService<IReportRunner>()
                .RenderAsync(filter, cancellationToken)
                .ConfigureAwait(false);
            if (dataSet.IsFailure)
            {
                job.Fail($"{dataSet.Error.Code}: {dataSet.Error.Message}", clock.UtcNow);
                await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
                return;
            }

            job.Progress(50);
            var content = renderer.Render(dataSet.Value);
            var fileName = FileName(job, renderer.FileExtension, clock.UtcNow);
            var key = ExportObjectKey.For(tenantId, job.Id, renderer.FileExtension);

            await services.GetRequiredService<IExportFileStore>()
                .UploadAsync(key, content, renderer.ContentType, cancellationToken)
                .ConfigureAwait(false);

            job.Complete(key, fileName, content.LongLength, dataSet.Value.Rows.Count, clock.UtcNow);
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            logger.LogInformation(
                "Export {ExportId} ({ReportCode}/{Format}) rendered: {Rows} row(s), {Bytes} byte(s)",
                job.Id, job.ReportCode, job.Format, dataSet.Value.Rows.Count, content.LongLength);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogError(ex, "Export {ExportId} ({ReportCode}) failed", job.Id, job.ReportCode);
            job.Fail(ex.Message, clock.UtcNow);
            await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }

    /// <summary>Contract: an empty <c>fileName</c> means <c>&lt;code&gt;_&lt;date&gt;.&lt;ext&gt;</c>.</summary>
    private static string FileName(ExportJob job, string extension, DateTimeOffset now)
    {
        if (!string.IsNullOrWhiteSpace(job.FileName))
        {
            return job.FileName.EndsWith('.' + extension) ? job.FileName : job.FileName + '.' + extension;
        }

        return string.Create(CultureInfo.InvariantCulture, $"{job.ReportCode}_{now:yyyy-MM-dd}.{extension}");
    }

    private IServiceScope TenantScope(uint tenantId)
    {
        var scope = scopeFactory.CreateScope();
        scope.ServiceProvider.GetRequiredService<ITenantContextInitializer>().Initialize(tenantId);
        return scope;
    }
}

public sealed class ReportingJobSchedule : IJobSchedule
{
    public void Register(IRecurringJobManager manager)
    {
        ArgumentNullException.ThrowIfNull(manager);
        manager.AddOrUpdate<ReportExportRunnerJob>(
            ReportExportRunnerJob.JobId,
            job => job.RunAsync(CancellationToken.None),
            ReportExportRunnerJob.Cron,
            new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });
    }
}
