namespace Wms.Identity.Contracts;

public sealed record TenantDto(uint Id, string Code, string Name, string DefaultCurrency, string Timezone, string Locale, bool IsActive);

/// <summary>Read access to <c>iam_tenant</c> (default currency, timezone) for other modules.</summary>
public interface ITenantDirectory
{
    Task<TenantDto?> GetAsync(uint tenantId, CancellationToken cancellationToken);
}
