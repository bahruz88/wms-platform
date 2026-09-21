using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_currency_rate</c> (spec §8): 1 &lt;currency&gt; = <see cref="RateToBase"/> base currency on <see cref="RateDate"/>.</summary>
public sealed class CurrencyRate : Entity<uint>, ITenantEntity
{
    public const string DefaultSource = "CBAR";

    public const string ManualSource = "MANUAL";

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

    /// <summary>
    /// Contract <c>upsertCurrencyRate</c>: an existing <c>(currency, rate_date)</c> row is re-rated and its source
    /// switches to the caller's (usually <c>MANUAL</c>); the audit trail keeps the previous value.
    /// </summary>
    public Result UpdateRate(decimal rateToBase, string source)
    {
        if (rateToBase <= 0m)
        {
            return MasterDataErrors.InvalidCurrencyRate("rate_to_base must be positive.");
        }

        RateToBase = rateToBase;
        Source = string.IsNullOrWhiteSpace(source) ? ManualSource : source.Trim().ToUpperInvariant();
        return Result.Success();
    }
}
