using Wms.Common.Domain;

namespace Wms.Identity.Domain.Entities;

/// <summary><c>iam_tenant</c> (spec §7). The tenant row itself is not tenant-scoped, so it carries no query filter.</summary>
public sealed class Tenant : Entity<uint>
{
    public const string DefaultCurrencyCode = "AZN";

    private Tenant()
    {
    }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public string DefaultCurrency { get; private set; } = DefaultCurrencyCode;

    public string Timezone { get; private set; } = "Asia/Baku";

    public string Locale { get; private set; } = "az-AZ";

    public bool IsActive { get; private set; } = true;

    public DateTimeOffset CreatedAt { get; private set; }

    public static Result<Tenant> Create(string code, string name, DateTimeOffset now, string currency = DefaultCurrencyCode, string timezone = "Asia/Baku", string locale = "az-AZ")
    {
        var normalizedCode = (code ?? string.Empty).Trim().ToUpperInvariant();
        var normalizedName = (name ?? string.Empty).Trim();
        if (normalizedCode.Length is 0 or > 32)
        {
            return IdentityErrors.InvalidTenant("code must be 1..32 characters.");
        }

        if (normalizedName.Length is 0 or > 200)
        {
            return IdentityErrors.InvalidTenant("name must be 1..200 characters.");
        }

        if (!Money.IsValidCurrency(currency))
        {
            return IdentityErrors.InvalidTenant("default_currency must be an ISO 4217 code.");
        }

        return new Tenant
        {
            Code = normalizedCode,
            Name = normalizedName,
            DefaultCurrency = currency.ToUpperInvariant(),
            Timezone = timezone,
            Locale = locale,
            CreatedAt = now,
        };
    }

    public void Deactivate() => IsActive = false;

    public void Activate() => IsActive = true;
}
