using System.Globalization;
using Microsoft.AspNetCore.Http;
using Wms.Common.Application.Abstractions;

namespace Wms.Common.Infrastructure.Tenancy;

/// <summary>Allows background jobs (no HTTP context) to run on behalf of a tenant.</summary>
public interface ITenantContextInitializer
{
    void Initialize(uint tenantId);
}

/// <summary>Tenant resolved from the <c>tenant_id</c> JWT claim only (spec §12.9).</summary>
public sealed class TenantContext(IHttpContextAccessor httpContextAccessor) : ITenantContext, ITenantContextInitializer
{
    private uint? _initialized;

    public uint TenantId => _initialized ?? FromClaims() ?? 0;

    public bool HasTenant => TenantId != 0;

    public void Initialize(uint tenantId)
    {
        if (tenantId == 0)
        {
            throw new ArgumentOutOfRangeException(nameof(tenantId), "Tenant id must be positive.");
        }

        _initialized = tenantId;
    }

    private uint? FromClaims()
    {
        var raw = httpContextAccessor.HttpContext?.User.FindFirst(ClaimNames.TenantId)?.Value;
        return uint.TryParse(raw, NumberStyles.None, CultureInfo.InvariantCulture, out var tenantId) ? tenantId : null;
    }
}
