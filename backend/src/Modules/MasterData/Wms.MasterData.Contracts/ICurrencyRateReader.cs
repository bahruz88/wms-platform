namespace Wms.MasterData.Contracts;

/// <summary>CBAR rates from <c>master_currency_rate</c>. No rate on the date → the caller must block (spec §12.5), never fall back.</summary>
public interface ICurrencyRateReader
{
    Task<string> GetBaseCurrencyAsync(CancellationToken cancellationToken);

    /// <summary>1 <paramref name="currency"/> = X base currency on <paramref name="date"/> (DECIMAL(18,8)); null when missing.</summary>
    Task<decimal?> GetRateToBaseAsync(string currency, DateOnly date, CancellationToken cancellationToken);
}
