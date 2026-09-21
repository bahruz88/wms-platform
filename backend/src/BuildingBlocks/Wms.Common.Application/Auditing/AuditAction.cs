namespace Wms.Common.Application.Auditing;

/// <summary>Values of <c>common_audit_log.action</c> (spec §11).</summary>
public enum AuditAction
{
    Create,
    Update,
    Delete,
    Approve,
    Reject,
    Post,
    Reverse,
    Export,
}
