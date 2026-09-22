using Wms.Common.Domain;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Domain.Entities;

/// <summary>
/// <c>rpt_export_job</c>: one asynchronous export (reporting.v1.yaml <c>createExport</c>). The row carries the
/// requester's location scope and cost permission as they were at request time, because the worker that renders
/// the file runs without an HTTP principal and would otherwise be unrestricted (README §8.17).
/// </summary>
public sealed class ExportJob : AuditableEntity<long>, ITenantEntity
{
    /// <summary>Contract: at most three queued or running jobs per user.</summary>
    public const int MaxActivePerUser = 3;

    /// <summary>Contract: the rendered file is kept for seven days.</summary>
    public const int RetentionDays = 7;

    private ExportJob()
    {
    }

    public uint TenantId { get; private set; }

    public string ReportCode { get; private set; } = string.Empty;

    public ExportFormat Format { get; private set; }

    public ExportStatus Status { get; private set; } = ExportStatus.Queued;

    public byte? ProgressPct { get; private set; }

    public long? RowCount { get; private set; }

    public string? FileName { get; private set; }

    public long? SizeBytes { get; private set; }

    /// <summary>MinIO object key; never serialised to a client (the client gets a presigned URL).</summary>
    public string? StorageKey { get; private set; }

    public string? ErrorMessage { get; private set; }

    public string ParametersJson { get; private set; } = "{}";

    /// <summary>Serialised location scope of the requester; <c>null</c> = unrestricted.</summary>
    public string? LocationScopeJson { get; private set; }

    public bool IncludeCost { get; private set; }

    public string? Locale { get; private set; }

    public uint RequestedBy { get; private set; }

    public DateTimeOffset RequestedAt { get; private set; }

    public DateTimeOffset? StartedAt { get; private set; }

    public DateTimeOffset? CompletedAt { get; private set; }

    public DateTimeOffset? ExpiresAt { get; private set; }

    public Guid IdempotencyKey { get; private set; }

    public bool IsActive => Status is ExportStatus.Queued or ExportStatus.Running;

    public static ExportJob Create(
        uint tenantId,
        string reportCode,
        ExportFormat format,
        string parametersJson,
        string? locationScopeJson,
        bool includeCost,
        string? locale,
        string? fileName,
        uint requestedBy,
        Guid idempotencyKey,
        DateTimeOffset now) =>
        new()
        {
            TenantId = tenantId,
            ReportCode = reportCode.Trim().ToUpperInvariant(),
            Format = format,
            Status = ExportStatus.Queued,
            ProgressPct = 0,
            ParametersJson = parametersJson,
            LocationScopeJson = locationScopeJson,
            IncludeCost = includeCost,
            Locale = locale,
            FileName = fileName,
            RequestedBy = requestedBy,
            RequestedAt = now,
            IdempotencyKey = idempotencyKey,
        };

    public void Start(DateTimeOffset now)
    {
        Status = ExportStatus.Running;
        StartedAt = now;
        ProgressPct = 1;
    }

    public void Progress(byte percent) => ProgressPct = Math.Clamp(percent, (byte)0, (byte)100);

    public void Complete(string storageKey, string fileName, long sizeBytes, long rowCount, DateTimeOffset now)
    {
        Status = ExportStatus.Completed;
        StorageKey = storageKey;
        FileName = fileName;
        SizeBytes = sizeBytes;
        RowCount = rowCount;
        ProgressPct = 100;
        CompletedAt = now;
        ExpiresAt = now.AddDays(RetentionDays);
        ErrorMessage = null;
    }

    public void Fail(string message, DateTimeOffset now)
    {
        Status = ExportStatus.Failed;
        ErrorMessage = message.Length > 1000 ? message[..1000] : message;
        CompletedAt = now;
    }

    /// <summary>Contract: a queued or running job is cancelled, a completed one has its file removed.</summary>
    public void Cancel(DateTimeOffset now)
    {
        Status = ExportStatus.Cancelled;
        StorageKey = null;
        SizeBytes = null;
        CompletedAt = now;
        ExpiresAt = null;
    }
}
