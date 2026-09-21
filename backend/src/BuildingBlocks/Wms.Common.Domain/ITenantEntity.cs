namespace Wms.Common.Domain;

/// <summary>Row belongs to a tenant. A global query filter is applied automatically (spec §12.9).</summary>
public interface ITenantEntity
{
    uint TenantId { get; }
}
