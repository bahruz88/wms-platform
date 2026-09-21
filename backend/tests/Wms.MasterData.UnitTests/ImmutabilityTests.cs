using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Spec §12.1, §12.3, §12.6: four columns are frozen once the row exists because posted movements, ledger
/// counter-accounts and audit history were written against them. The rule lives in the entity, so it holds
/// with or without HTTP.
/// </summary>
public sealed class ImmutabilityTests
{
    private static readonly DateOnly ValidFrom = new(2026, 1, 1);

    private static Product NewProduct(string sku = "CHK-001", ushort baseUomId = 3) =>
        Product.Create(1, sku, "Toyuq döşü", categoryId: 7, baseUomId, ValidFrom).Value;

    [Fact]
    public void Product_sku_cannot_change_after_creation()
    {
        var product = NewProduct();

        var result = product.ChangeSku("CHK-002");

        Assert.True(result.IsFailure);
        Assert.Equal("SKU_IMMUTABLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal("CHK-001", product.Sku);
    }

    [Theory]
    [InlineData("CHK-001")]
    [InlineData("chk-001")]
    [InlineData("  CHK-001  ")]
    [InlineData(null)]
    [InlineData("")]
    public void Product_sku_unchanged_or_absent_is_accepted(string? sku)
    {
        var product = NewProduct();

        Assert.True(product.ChangeSku(sku).IsSuccess);
        Assert.Equal("CHK-001", product.Sku);
    }

    [Fact]
    public void Product_base_uom_cannot_change_after_creation()
    {
        var product = NewProduct(baseUomId: 3);

        var result = product.ChangeBaseUom(4);

        Assert.True(result.IsFailure);
        Assert.Equal("BASE_UOM_IMMUTABLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal((ushort)3, product.BaseUomId);
    }

    [Fact]
    public void Product_base_uom_unchanged_or_absent_is_accepted()
    {
        var product = NewProduct(baseUomId: 3);

        Assert.True(product.ChangeBaseUom(3).IsSuccess);
        Assert.True(product.ChangeBaseUom(null).IsSuccess);
    }

    [Fact]
    public void Location_type_cannot_change_after_creation()
    {
        var location = Location.Create(1, "WH-FOOD", "Qida anbarı", LocationType.CentralWarehouse).Value;

        var result = location.ChangeLocationType(LocationType.Restaurant);

        Assert.True(result.IsFailure);
        Assert.Equal("LOCATION_TYPE_IMMUTABLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal(LocationType.CentralWarehouse, location.LocationType);
    }

    [Fact]
    public void Location_type_unchanged_or_absent_is_accepted()
    {
        var location = Location.Create(1, "WH-FOOD", "Qida anbarı", LocationType.CentralWarehouse).Value;

        Assert.True(location.ChangeLocationType(LocationType.CentralWarehouse).IsSuccess);
        Assert.True(location.ChangeLocationType(null).IsSuccess);
    }

    [Fact]
    public void Reason_group_cannot_change_after_creation()
    {
        var reasonCode = ReasonCode.Create(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste);

        var result = reasonCode.ChangeReasonGroup(ReasonGroup.Adjustment);

        Assert.True(result.IsFailure);
        Assert.Equal("REASON_GROUP_IMMUTABLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal(ReasonGroup.Waste, reasonCode.ReasonGroup);
    }

    [Fact]
    public void Reason_group_unchanged_or_absent_is_accepted()
    {
        var reasonCode = ReasonCode.Create(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste);

        Assert.True(reasonCode.ChangeReasonGroup(ReasonGroup.Waste).IsSuccess);
        Assert.True(reasonCode.ChangeReasonGroup(null).IsSuccess);
    }

    [Fact]
    public void Category_product_type_cannot_change_after_creation()
    {
        var category = ProductCategory.Create(1, "CHEMICAL", "Kimyəvi", ProductType.NonFood);

        var result = category.ChangeProductType(ProductType.Food);

        Assert.True(result.IsFailure);
        Assert.Equal("PRODUCT_TYPE_IMMUTABLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
        Assert.Equal(ProductType.NonFood, category.ProductType);
    }

    [Fact]
    public void Every_immutability_error_carries_its_own_code()
    {
        var product = NewProduct();
        var location = Location.Create(1, "WH", "Anbar", LocationType.CentralWarehouse).Value;
        var reasonCode = ReasonCode.Create(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste);
        var category = ProductCategory.Create(1, "CHEMICAL", "Kimyəvi", ProductType.NonFood);

        string[] codes =
        [
            product.ChangeSku("OTHER").Error.Code,
            product.ChangeBaseUom(99).Error.Code,
            location.ChangeLocationType(LocationType.Shelf).Error.Code,
            reasonCode.ChangeReasonGroup(ReasonGroup.Return).Error.Code,
            category.ChangeProductType(ProductType.Food).Error.Code,
        ];

        Assert.Equal(codes.Length, codes.Distinct(StringComparer.Ordinal).Count());
    }
}
