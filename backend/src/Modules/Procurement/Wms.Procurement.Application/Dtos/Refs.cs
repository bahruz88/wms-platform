using Wms.MasterData.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Dtos;

/// <summary>Mandatory audit columns of spec §6.2, shaped like <c>common.v1.yaml#/components/schemas/AuditFields</c>.</summary>
public sealed record AuditDto(DateTimeOffset CreatedAt, uint CreatedBy, DateTimeOffset? UpdatedAt, uint? UpdatedBy, uint RowVersion);

/// <summary><c>ProductRef</c> of procurement.v1.yaml.</summary>
public sealed record ProductRefDto(uint Id, string Sku, string Name, ProductType ProductType, string BaseUomCode)
{
    public static ProductRefDto From(ProductDto product)
    {
        ArgumentNullException.ThrowIfNull(product);
        return new ProductRefDto(
            product.Id,
            product.Sku,
            product.Name,
            string.Equals(product.ProductType, "FOOD", StringComparison.OrdinalIgnoreCase) ? ProductType.Food : ProductType.NonFood,
            product.BaseUomCode);
    }

    /// <summary>Placeholder for an id whose master row was deleted; keeps the contract's required fields present.</summary>
    public static ProductRefDto Unknown(uint id) => new(id, string.Empty, string.Empty, ProductType.NonFood, string.Empty);
}

/// <summary><c>SupplierRef</c> of procurement.v1.yaml.</summary>
public sealed record SupplierRefDto(uint Id, string Code, string Name, string Currency, bool IsApprovedFoodSupplier)
{
    public static SupplierRefDto From(MasterData.Contracts.SupplierRefDto supplier)
    {
        ArgumentNullException.ThrowIfNull(supplier);
        return new SupplierRefDto(supplier.Id, supplier.Code, supplier.Name, supplier.Currency, supplier.IsApprovedFoodSupplier);
    }

    public static SupplierRefDto Unknown(uint id) => new(id, string.Empty, string.Empty, "AZN", false);
}

/// <summary><c>LocationRef</c> of procurement.v1.yaml.</summary>
public sealed record LocationRefDto(uint Id, string Code, string Name)
{
    public static LocationRefDto From(LocationDto location)
    {
        ArgumentNullException.ThrowIfNull(location);
        return new LocationRefDto(location.Id, location.Code, location.Name);
    }

    public static LocationRefDto Unknown(uint id) => new(id, string.Empty, string.Empty);
}

/// <summary><c>UserRef</c> of procurement.v1.yaml.</summary>
public sealed record UserRefDto(uint Id, string Username, string FullName)
{
    /// <summary>
    /// A user id Procurement cannot put a name to. Spec §5 does not let this module read <c>iam_user</c>, so
    /// the documents that must name a person — the approval chain — carry the username denormalised
    /// (<c>proc_approval_instance.requested_by_username</c>, <c>proc_approval_step.approver_username</c>), the
    /// same device that keeps <c>approver_role_code</c> on the step. This placeholder is what remains for a
    /// row written before that column existed: the id, rendered so a screen shows something addressable
    /// instead of an empty cell.
    /// </summary>
    public static UserRefDto Unknown(uint id) => new(id, $"#{id}", $"İstifadəçi #{id}");

    /// <summary>A user id with the username the document recorded when it was raised or decided.</summary>
    public static UserRefDto Named(uint id, string? username) =>
        string.IsNullOrWhiteSpace(username) ? Unknown(id) : new UserRefDto(id, username, username);
}
