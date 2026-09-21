using Wms.MasterData.Contracts;

namespace Wms.Inventory.Application.Dtos;

/// <summary><c>ProductRef</c> of inventory.v1.yaml — the shape every document line and balance row carries.</summary>
public sealed record ProductRefDto(
    uint Id,
    string Sku,
    string Name,
    ushort BaseUomId,
    string BaseUomCode,
    bool RequiresBatch,
    bool RequiresExpiry)
{
    public static ProductRefDto From(ProductDto product)
    {
        ArgumentNullException.ThrowIfNull(product);
        return new ProductRefDto(
            product.Id, product.Sku, product.Name, product.BaseUomId, product.BaseUomCode,
            product.RequiresBatch, product.RequiresExpiry);
    }

    /// <summary>Placeholder for an id whose master row was deleted; keeps the contract's required fields present.</summary>
    public static ProductRefDto Unknown(uint id) => new(id, string.Empty, string.Empty, 0, string.Empty, false, false);
}

/// <summary><c>LocationRef</c> of inventory.v1.yaml.</summary>
public sealed record LocationRefDto(uint Id, string Code, string Name, bool IsVirtual)
{
    public static LocationRefDto From(LocationDto location)
    {
        ArgumentNullException.ThrowIfNull(location);
        return new LocationRefDto(location.Id, location.Code, location.Name, location.IsVirtual);
    }

    public static LocationRefDto Unknown(uint id) => new(id, string.Empty, string.Empty, false);
}

/// <summary><c>BatchRef</c> of inventory.v1.yaml.</summary>
public sealed record BatchRefDto(long Id, string BatchNo, DateOnly? ExpiryDate, string Status);
