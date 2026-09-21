using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_currency_rate</c> (spec §8): 1 &lt;currency&gt; = <see cref="RateToBase"/> base currency on <see cref="RateDate"/>.</summary>
public sealed class CurrencyRate : Entity<uint>, ITenantEntity
{
    public const string DefaultSource = "CBAR";

    private CurrencyRate()
    {
    }

    public uint TenantId { get; private set; }

    public string Currency { get; private set; } = string.Empty;

    public DateOnly RateDate { get; private set; }

    public decimal RateToBase { get; private set; }

    public string Source { get; private set; } = DefaultSource;

    public static Result<CurrencyRate> Create(uint tenantId, string currency, DateOnly rateDate, decimal rateToBase, string source = DefaultSource)
    {
        if (!Money.IsValidCurrency(currency))
        {
            return MasterDataErrors.InvalidSupplier("currency must be an ISO 4217 code.");
        }

        if (rateToBase <= 0m)
        {
            return MasterDataErrors.InvalidFactor("rate_to_base must be positive.");
        }

        return new CurrencyRate
        {
            TenantId = tenantId,
            Currency = currency.ToUpperInvariant(),
            RateDate = rateDate,
            RateToBase = rateToBase,
            Source = source,
        };
    }
}
