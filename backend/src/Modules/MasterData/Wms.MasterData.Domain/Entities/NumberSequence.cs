using System.Globalization;
using Wms.Common.Domain;

namespace Wms.MasterData.Domain.Entities;

/// <summary>
/// <c>master_number_sequence</c> (spec §8, Əlavə B): <c>PR-2026-00001</c>. Incremented under <c>SELECT ... FOR UPDATE</c>;
/// gaps are acceptable because a rolled-back transaction loses its number.
/// </summary>
public sealed class NumberSequence : Entity<uint>, ITenantEntity
{
    public const byte DefaultPadding = 5;

    private NumberSequence()
    {
    }

    public uint TenantId { get; private set; }

    public string DocType { get; private set; } = string.Empty;

    public string Prefix { get; private set; } = string.Empty;

    /// <summary><c>'2026'</c> or <c>'2026-09'</c>.</summary>
    public string Period { get; private set; } = string.Empty;

    public uint LastNumber { get; private set; }

    public byte Padding { get; private set; } = DefaultPadding;

    public static NumberSequence Create(uint tenantId, string docType, string prefix, string period, byte padding = DefaultPadding) =>
        new()
        {
            TenantId = tenantId,
            DocType = docType,
            Prefix = prefix,
            Period = period,
            Padding = padding,
            LastNumber = 0,
        };

    /// <summary>Increments the counter and formats the next document number.</summary>
    public Result<string> Next()
    {
        var next = LastNumber + 1;
        var maxExclusive = (uint)Math.Pow(10, Padding);
        if (next >= maxExclusive)
        {
            return MasterDataErrors.NumberSequenceExhausted(DocType);
        }

        LastNumber = next;
        return Format(next);
    }

    /// <summary>What <see cref="Next"/> would hand out, without reserving it (contract <c>nextNumberPreview</c>).</summary>
    public string PreviewNext() => Format(LastNumber + 1);

    private string Format(uint number) => string.Create(
        CultureInfo.InvariantCulture,
        $"{Prefix}-{Period}-{number.ToString(CultureInfo.InvariantCulture).PadLeft(Padding, '0')}");
}
