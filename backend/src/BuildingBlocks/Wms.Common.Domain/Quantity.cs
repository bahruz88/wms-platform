using System.Globalization;

namespace Wms.Common.Domain;

/// <summary>
/// Quantity in a unit of measure. Always <c>decimal</c> (DECIMAL(18,4)), rounded with
/// <see cref="MidpointRounding.AwayFromZero"/> to the UoM's decimals (spec §12.1).
/// </summary>
public readonly record struct Quantity : IComparable<Quantity>
{
    /// <summary>DECIMAL(18,4) — the storage scale of every quantity column.</summary>
    public const int StorageDecimals = 4;

    private Quantity(decimal value)
    {
        Value = value;
    }

    public decimal Value { get; }

    public static Quantity Zero => new(0m);

    public bool IsZero => Value == 0m;

    public bool IsNegative => Value < 0m;

    public bool IsPositive => Value > 0m;

    /// <summary>Creates a quantity rounded to <paramref name="decimals"/> places, away from zero.</summary>
    public static Quantity Of(decimal value, int decimals = StorageDecimals) => new(Round(value, decimals));

    /// <summary>qty_base = entered_qty × conversion_rate, rounded to the base UoM decimals (spec §12.1).</summary>
    public static Quantity Convert(decimal enteredQty, decimal conversionRate, int baseDecimals)
    {
        if (conversionRate <= 0m)
        {
            throw new ArgumentOutOfRangeException(nameof(conversionRate), "Conversion rate must be positive.");
        }

        return Of(enteredQty * conversionRate, baseDecimals);
    }

    public static decimal Round(decimal value, int decimals)
    {
        if (decimals is < 0 or > 28)
        {
            throw new ArgumentOutOfRangeException(nameof(decimals));
        }

        return Math.Round(value, decimals, MidpointRounding.AwayFromZero);
    }

    public Quantity Negate() => new(-Value);

    public Quantity Add(Quantity other) => new(Value + other.Value);

    public Quantity Subtract(Quantity other) => new(Value - other.Value);

    public int CompareTo(Quantity other) => Value.CompareTo(other.Value);

    public override string ToString() => Value.ToString(CultureInfo.InvariantCulture);

    public static Quantity operator +(Quantity left, Quantity right) => left.Add(right);

    public static Quantity operator -(Quantity left, Quantity right) => left.Subtract(right);

    public static Quantity operator -(Quantity value) => value.Negate();

    public static bool operator <(Quantity left, Quantity right) => left.CompareTo(right) < 0;

    public static bool operator >(Quantity left, Quantity right) => left.CompareTo(right) > 0;

    public static bool operator <=(Quantity left, Quantity right) => left.CompareTo(right) <= 0;

    public static bool operator >=(Quantity left, Quantity right) => left.CompareTo(right) >= 0;
}
