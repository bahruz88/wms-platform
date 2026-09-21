using System.Globalization;

namespace Wms.Common.Domain;

/// <summary>Monetary amount: DECIMAL(18,4) + ISO 4217 CHAR(3) currency (spec §6.3).</summary>
public readonly record struct Money
{
    public const int StorageDecimals = 4;

    private Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }

    public decimal Amount { get; }

    public string Currency { get; }

    public static Result<Money> Create(decimal amount, string currency)
    {
        if (!IsValidCurrency(currency))
        {
            return CommonErrors.Unprocessable("INVALID_CURRENCY", $"'{currency}' is not an ISO 4217 currency code.");
        }

        return new Money(Quantity.Round(amount, StorageDecimals), currency.ToUpperInvariant());
    }

    /// <summary>Non-validating factory for trusted input (e.g. values loaded from the database).</summary>
    public static Money Of(decimal amount, string currency)
    {
        var result = Create(amount, currency);
        return result.IsSuccess ? result.Value : throw new ArgumentException(result.Error.Message, nameof(currency));
    }

    public static Money Zero(string currency) => Of(0m, currency);

    public static bool IsValidCurrency(string? currency) =>
        currency is { Length: 3 } && currency.All(char.IsAsciiLetter);

    public Money Add(Money other)
    {
        EnsureSameCurrency(other);
        return new Money(Amount + other.Amount, Currency);
    }

    public Money Subtract(Money other)
    {
        EnsureSameCurrency(other);
        return new Money(Amount - other.Amount, Currency);
    }

    public Money Multiply(decimal factor) => new(Quantity.Round(Amount * factor, StorageDecimals), Currency);

    /// <summary>Converts using a DECIMAL(18,8) rate: 1 unit of this currency = <paramref name="rateToTarget"/> target units.</summary>
    public Money ConvertTo(string targetCurrency, decimal rateToTarget)
    {
        if (rateToTarget <= 0m)
        {
            throw new ArgumentOutOfRangeException(nameof(rateToTarget), "FX rate must be positive.");
        }

        return Of(Amount * rateToTarget, targetCurrency);
    }

    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture, $"{Amount:0.0000} {Currency}");

    public static Money operator +(Money left, Money right) => left.Add(right);

    public static Money operator -(Money left, Money right) => left.Subtract(right);

    private void EnsureSameCurrency(Money other)
    {
        if (!string.Equals(Currency, other.Currency, StringComparison.Ordinal))
        {
            throw new InvalidOperationException($"Currency mismatch: {Currency} vs {other.Currency}.");
        }
    }
}
