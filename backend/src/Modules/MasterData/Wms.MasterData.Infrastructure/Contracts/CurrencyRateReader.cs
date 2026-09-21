using Wms.Identity.Contracts;
using Wms.Common.Application.Abstractions;
using Wms.MasterData.Contracts;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>
/// In-process <see cref="ICurrencyRateReader"/>. The base currency comes from <c>iam_tenant.default_currency</c>
/// (allowed cross-module dependency: MasterData → Identity.Contracts). A missing rate returns null so the caller
/// blocks the operation instead of silently reusing an old rate (spec §12.5).
/// </summary>
public sealed class CurrencyRateReader(MasterDataDbContext db, ITenantDirectory tenants, ITenantContext tenantContext) : ICurrencyRateReader
{
    /// <summary>Used only when the tenant row cannot be read (spec §7: <c>iam_tenant.default_currency</c> defaults to AZN).</summary>
    public const string FallbackBaseCurrency = "AZN";

    public async Task<string> GetBaseCurrencyAsync(CancellationToken cancellationToken)
    {
        var tenant = await tenants.GetAsync(tenantContext.TenantId, cancellationToken).ConfigureAwait(false);
        return tenant?.DefaultCurrency ?? FallbackBaseCurrency;
    }

    public async Task<decimal?> GetRateToBaseAsync(string currency, DateOnly date, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(currency);
        var normalized = currency.ToUpperInvariant();
        var baseCurrency = await GetBaseCurrencyAsync(cancellationToken).ConfigureAwait(false);
        if (string.Equals(normalized, baseCurrency, StringComparison.Ordinal))
        {
            return 1m;
        }

        return await db.CurrencyRates.AsNoTracking()
            .Where(r => r.Currency == normalized && r.RateDate == date)
            .Select(r => (decimal?)r.RateToBase)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);
    }
}
