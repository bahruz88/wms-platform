namespace Wms.Common.Application.Auditing;

/// <summary>Appends a row to <c>common_audit_log</c> in the current unit of work (spec §12.6, §16).</summary>
public interface IAuditTrail
{
    void Record(string entityType, long entityId, AuditAction action, object? changes = null);
}
