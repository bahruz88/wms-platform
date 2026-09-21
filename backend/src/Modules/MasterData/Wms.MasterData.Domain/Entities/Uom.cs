using Wms.Common.Domain;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.Domain.Entities;

/// <summary><c>master_uom</c> (spec §8). <see cref="Decimals"/> drives quantity rounding (spec §12.1).</summary>
public sealed class Uom : Entity<ushort>, ITenantEntity
{
    public const byte DefaultDecimals = 3;

    private Uom()
    {
    }

    public uint TenantId { get; private set; }

    public string Code { get; private set; } = string.Empty;

    public string Name { get; private set; } = string.Empty;

    public UomClass UomClass { get; private set; }

    public byte Decimals { get; private set; } = DefaultDecimals;

    public static Result<Uom> Create(uint tenantId, string code, string name, UomClass uomClass, byte decimals = DefaultDecimals)
    {
        var normalizedCode = (code ?? string.Empty).Trim().ToUpperInvariant();
        if (normalizedCode.Length is 0 or > 12)
        {
            return MasterDataErrors.InvalidUom("code must be 1..12 characters.");
        }

        if (decimals > Quantity.StorageDecimals)
        {
            return MasterDataErrors.InvalidUom($"decimals cannot exceed the DECIMAL(18,{Quantity.StorageDecimals}) storage scale.");
        }

        return new Uom
        {
            TenantId = tenantId,
            Code = normalizedCode,
            Name = (name ?? string.Empty).Trim(),
            UomClass = uomClass,
            Decimals = decimals,
        };
    }
}
