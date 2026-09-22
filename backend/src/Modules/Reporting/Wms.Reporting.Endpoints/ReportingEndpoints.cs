using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Reporting.Application;
using Wms.Reporting.Application.Commands;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Application.Queries;
using Wms.Reporting.Contracts;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Endpoints;

/// <summary>The eight operations of reporting.v1.yaml.</summary>
public static class ReportingEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/dashboard/summary", GetDashboardSummaryAsync)
            .RequirePermission(ReportingPermissions.DashboardView)
            .WithName("getDashboardSummary");

        group.MapGet("/reports", ListReportsAsync)
            .RequirePermission(ReportingPermissions.ReportView)
            .WithName("listReports");

        group.MapGet("/reports/{code}", GetReportDefinitionAsync)
            .RequirePermission(ReportingPermissions.ReportView)
            .WithName("getReportDefinition");

        group.MapPost("/reports/{code}/run", RunReportAsync)
            .RequirePermission(ReportingPermissions.ReportView)
            // Header required, response NOT replayed: a repeated key re-runs the report (reporting.v1.yaml).
            .RequireIdempotencyKeyHeader()
            .WithName("runReport");

        group.MapGet("/exports", ListExportsAsync)
            .RequirePermission(ReportingPermissions.ExportCreate)
            .WithName("listExports");

        group.MapPost("/exports", CreateExportAsync)
            .RequirePermission(ReportingPermissions.ExportCreate)
            .RequireIdempotencyKey()
            .WithName("createExport");

        group.MapGet("/exports/{id:long}", GetExportAsync)
            .RequirePermission(ReportingPermissions.ExportCreate)
            .WithName("getExport");

        group.MapDelete("/exports/{id:long}", CancelExportAsync)
            .RequirePermission(ReportingPermissions.ExportCreate)
            .WithName("cancelExport");
    }

    private static async Task<IResult> GetDashboardSummaryAsync(
        uint? locationId,
        string? period,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        if (!TryParseEnum<DashboardPeriod>(period, DashboardPeriod.Week, out var parsedPeriod))
        {
            return Invalid("period", "TODAY, WEEK və ya MONTH gözlənilir.");
        }

        var result = await dispatcher
            .QueryAsync(new GetDashboardSummaryQuery(locationId, parsedPeriod), cancellationToken)
            .ConfigureAwait(false);

        if (result.IsSuccess)
        {
            // Contract: Cache-Control: max-age=60. The payload depends on the principal's permissions and
            // location grants, so it is private to that browser and never shared by a proxy.
            httpContext.Response.Headers.CacheControl = "private, max-age=60";
        }

        return result.ToOk();
    }

    private static async Task<IResult> ListReportsAsync(string? category, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        if (!TryParseNullableEnum<ReportCategory>(category, out var parsed))
        {
            return Invalid("category", "STOCK, MOVEMENT, QUALITY, PROCUREMENT, FINANCE və ya AUDIT gözlənilir.");
        }

        var result = await dispatcher.QueryAsync(new ListReportsQuery(parsed), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> GetReportDefinitionAsync(string code, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetReportDefinitionQuery(code), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> RunReportAsync(
        string code,
        ReportRunRequest? request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var command = new RunReportCommand(
            code,
            request?.Parameters ?? [],
            request?.Page ?? 1,
            request?.Size ?? PageRequest.DefaultSize,
            request?.Sort);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ListExportsAsync(
        string? status,
        [AsParameters] PagingRequest paging,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        if (!TryParseNullableEnum<ExportStatus>(status, out var parsed))
        {
            return Invalid("status", "QUEUED, RUNNING, COMPLETED, FAILED və ya CANCELLED gözlənilir.");
        }

        var result = await dispatcher
            .QueryAsync(new ListExportsQuery(parsed, paging.ToPageRequest()), cancellationToken)
            .ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateExportAsync(
        ExportCreateRequest request,
        HttpContext httpContext,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        if (request.Format is not { } format)
        {
            return Invalid("format", "XLSX, CSV və ya PDF gözlənilir.");
        }

        var command = new CreateExportCommand(
            request.ReportCode ?? string.Empty,
            format,
            request.Parameters ?? [],
            request.FileName,
            request.Locale,
            IdempotencyKey.Require(httpContext));

        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(job => TypedResults.Accepted(job.StatusUrl, job));
    }

    private static async Task<IResult> GetExportAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetExportQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CancelExportAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.SendAsync(new CancelExportCommand(id), cancellationToken).ConfigureAwait(false);
        return result.ToNoContent();
    }

    private static IResult Invalid(string field, string message) =>
        CommonErrors.Validation(new Dictionary<string, string[]>(StringComparer.Ordinal) { [field] = [message] }).ToProblem();

    private static bool TryParseEnum<T>(string? value, T fallback, out T parsed)
        where T : struct, Enum
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            parsed = fallback;
            return true;
        }

        return Enum.TryParse(value.Replace("_", string.Empty, StringComparison.Ordinal), ignoreCase: true, out parsed);
    }

    private static bool TryParseNullableEnum<T>(string? value, out T? parsed)
        where T : struct, Enum
    {
        parsed = null;
        if (string.IsNullOrWhiteSpace(value))
        {
            return true;
        }

        if (Enum.TryParse<T>(value.Replace("_", string.Empty, StringComparison.Ordinal), ignoreCase: true, out var result))
        {
            parsed = result;
            return true;
        }

        return false;
    }
}
