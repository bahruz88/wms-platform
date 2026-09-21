namespace Wms.Common.Application.Abstractions;

/// <summary>Current tenant. Comes ONLY from the JWT <c>tenant_id</c> claim (spec §12.9), never from the request body.</summary>
public interface ITenantContext
{
    uint TenantId { get; }

    bool HasTenant { get; }
}
