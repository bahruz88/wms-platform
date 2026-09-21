namespace Wms.Common.Domain;

/// <summary>Soft delete via <c>is_deleted</c>. Never used on ledger tables (spec §6.2).</summary>
public interface ISoftDeletable
{
    bool IsDeleted { get; }

    void SoftDelete();

    void Restore();
}
