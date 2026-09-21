using Wms.Common.Application.Auditing;

namespace Wms.Common.Infrastructure.Audit;

/// <summary>Row of <c>common_audit_log</c> (spec §11). Append-only: the DB user only has SELECT, INSERT (spec §16).</summary>
public sealed class AuditLogEntry
{
    private AuditLogEntry()
    {
    }

    public long Id { get; private set; }

    public uint TenantId { get; private set; }

    public string EntityType { get; private set; } = string.Empty;

    public long EntityId { get; private set; }

    public AuditAction Action { get; private set; }

    /// <summary>JSON <c>{"field":{"old":..,"new":..}}</c>.</summary>
    public string? Changes { get; private set; }

    public uint UserId { get; private set; }

    public string? IpAddress { get; private set; }

    public DateTimeOffset OccurredAt { get; private set; }

    public static AuditLogEntry Create(
        uint tenantId,
        string entityType,
        long entityId,
        AuditAction action,
        string? changesJson,
        uint userId,
        string? ipAddress,
        DateTimeOffset occurredAt)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(entityType);
        return new AuditLogEntry
        {
            TenantId = tenantId,
            EntityType = entityType,
            EntityId = entityId,
            Action = action,
            Changes = changesJson,
            UserId = userId,
            IpAddress = ipAddress,
            OccurredAt = occurredAt,
        };
    }
}
