using System.Text.Json;
using System.Text.Json.Serialization;
using Wms.Common.Infrastructure.Http;
using Wms.MasterData.Application;
using Wms.MasterData.Application.Dtos;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Spec §16 / CONVENTIONS: a principal without <c>master.product.view_cost</c> must not receive cost-bearing
/// fields at all — the property is <b>absent</b> from the JSON, not present as <c>null</c> or a masked zero.
/// The host configures <c>JsonIgnoreCondition.WhenWritingNull</c>; these tests pin both halves of that contract
/// against the real MasterData DTOs.
/// </summary>
public sealed class CostFieldVisibilityTests
{
    /// <summary>Mirrors <c>WmsCommonServiceCollectionExtensions.ConfigureHttpJsonOptions</c>.</summary>
    private static readonly JsonSerializerOptions HostOptions = CreateHostOptions();

    private static JsonSerializerOptions CreateHostOptions()
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
        options.Converters.Add(new DecimalStringJsonConverter());
        options.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.SnakeCaseUpper));
        options.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
        return options;
    }

    [Fact]
    public void A_gated_cost_value_becomes_null_without_the_permission()
    {
        Assert.Equal(12.5000m, CostFieldVisibility.Gate<decimal>(canViewCost: true, 12.5000m));
        Assert.Null(CostFieldVisibility.Gate<decimal>(canViewCost: false, 12.5000m));
        Assert.Null(CostFieldVisibility.GateRef<string>(canViewCost: false, "AZN"));
        Assert.Equal("AZN", CostFieldVisibility.GateRef(canViewCost: true, "AZN"));
    }

    [Fact]
    public void A_null_optional_field_is_omitted_from_the_payload_not_serialised_as_null()
    {
        var gated = NewProduct() with
        {
            MinStock = CostFieldVisibility.Gate<decimal>(canViewCost: false, 10m),
            MaxStock = CostFieldVisibility.Gate<decimal>(canViewCost: false, 90m),
            ReorderPoint = CostFieldVisibility.Gate<decimal>(canViewCost: false, 20m),
        };

        var json = JsonSerializer.Serialize(gated, HostOptions);

        Assert.DoesNotContain("minStock", json, StringComparison.Ordinal);
        Assert.DoesNotContain("maxStock", json, StringComparison.Ordinal);
        Assert.DoesNotContain("reorderPoint", json, StringComparison.Ordinal);
        Assert.DoesNotContain("null", json, StringComparison.Ordinal);
    }

    [Fact]
    public void A_visible_optional_field_is_present_and_serialised_as_a_decimal_string()
    {
        var visible = NewProduct() with { MinStock = CostFieldVisibility.Gate<decimal>(canViewCost: true, 10.5m) };

        var json = JsonSerializer.Serialize(visible, HostOptions);

        Assert.Contains("\"minStock\":\"10.5\"", json, StringComparison.Ordinal);
    }

    [Fact]
    public void Enums_travel_as_upper_snake_on_the_wire()
    {
        var json = JsonSerializer.Serialize(NewProduct() with { ProductType = ProductType.NonFood }, HostOptions);

        Assert.Contains("\"productType\":\"NON_FOOD\"", json, StringComparison.Ordinal);
        Assert.Contains("\"issueStrategy\":\"FEFO\"", json, StringComparison.Ordinal);
    }

    [Fact]
    public void Mandatory_decimals_are_always_present()
    {
        var json = JsonSerializer.Serialize(NewProduct(), HostOptions);

        // vatRate is required by the contract, so it must survive even when every optional field is stripped.
        Assert.Contains("\"vatRate\":\"18.0000\"", json, StringComparison.Ordinal);
    }

    private static ProductDetailDto NewProduct() => new(
        Id: 42,
        Sku: "CHK-001",
        Name: "Toyuq döşü",
        Barcode: null,
        BaseUomId: 1,
        BaseUomCode: "G",
        ProductType: ProductType.Food,
        RequiresBatch: true,
        RequiresExpiry: true,
        IsActive: true,
        CategoryId: 7,
        CategoryPath: "/FOOD/MEAT",
        Brand: null,
        DefaultSupplierId: null,
        MinStock: null,
        MaxStock: null,
        ReorderPoint: null,
        VatRate: 18.0000m,
        IssueStrategy: IssueStrategy.Fefo,
        ShelfLifeDays: null,
        ImageAttachmentId: null,
        Uoms: [],
        Audit: new AuditFieldsDto(new DateTimeOffset(2026, 9, 22, 8, 0, 0, TimeSpan.Zero), 1, null, null, 1));
}
