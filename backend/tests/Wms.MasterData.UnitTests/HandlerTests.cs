using Wms.MasterData.Application.Commands;
using Wms.MasterData.Application.Queries;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Handler-level rules the contract names: uniqueness conflicts answer <c>409</c> (never a 500 from the unique
/// index), optimistic locking answers <c>409 STALE_VERSION</c>, and the immutable columns are refused before
/// anything else is written.
/// </summary>
public sealed class HandlerTests
{
    private static readonly CancellationToken None = CancellationToken.None;
    private static readonly DateOnly Start = new(2026, 1, 1);

    // ================================================================ uniqueness conflicts (409)

    [Fact]
    public async Task Creating_a_product_with_a_taken_sku_is_a_conflict()
    {
        var products = new FakeProductRepository();
        products.TakenSkus.Add("CHK-001");
        var categories = new FakeProductCategoryRepository();
        categories.Categories.Add(ProductCategory.Create(1, "FOOD", "Qida", ProductType.Food).WithId(7u));
        var uoms = new FakeUomRepository();
        uoms.Uoms.Add(Uom.Create(1, "G", "qram", UomClass.Mass).Value.WithId((ushort)1));

        var handler = new CreateProductCommandHandler(
            new FakeMasterDataUnitOfWork(), products, categories, uoms, new FakeSupplierRepository(), new FakeTenantContext(), new FakeClock());

        var result = await handler.HandleAsync(NewProductCommand("chk-001"), None);

        Assert.True(result.IsFailure);
        Assert.Equal("SKU_ALREADY_EXISTS", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
        Assert.Empty(products.Products);
    }

    [Fact]
    public async Task Creating_a_reason_code_with_a_taken_code_is_a_conflict()
    {
        var reasonCodes = new FakeReasonCodeRepository();
        reasonCodes.ReasonCodes.Add(ReasonCode.Create(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste).WithId((ushort)1));
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new CreateReasonCodeCommandHandler(unitOfWork, reasonCodes, new FakeTenantContext());

        var result = await handler.HandleAsync(
            new CreateReasonCodeCommand("EXPIRED", "Təkrar", ReasonGroup.Waste, RequiresApproval: true, RequiresPhoto: false),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("REASON_CODE_ALREADY_EXISTS", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
        Assert.Single(reasonCodes.ReasonCodes);
        Assert.False(unitOfWork.Committed);
    }

    [Fact]
    public async Task Creating_a_category_with_a_taken_code_is_a_conflict()
    {
        var categories = new FakeProductCategoryRepository();
        categories.Categories.Add(ProductCategory.Create(1, "CHEMICAL", "Kimyəvi", ProductType.NonFood).WithId(3u));
        var handler = new CreateCategoryCommandHandler(new FakeMasterDataUnitOfWork(), categories, new FakeTenantContext());

        var result = await handler.HandleAsync(
            new CreateCategoryCommand(ParentId: null, "CHEMICAL", "Başqa", ProductType.NonFood, DefaultIssueStrategy: null),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("CATEGORY_CODE_ALREADY_EXISTS", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
    }

    [Fact]
    public async Task Creating_a_second_virtual_location_of_the_same_type_is_unprocessable()
    {
        var locations = new FakeLocationRepository();
        locations.Locations.Add(Location.Create(1, "V_WASTE", "Tullantı", LocationType.VWaste).Value.WithId(9u));
        var handler = new CreateLocationCommandHandler(new FakeMasterDataUnitOfWork(), locations, new FakeTenantContext());

        var result = await handler.HandleAsync(
            new CreateLocationCommand(ParentId: null, "V_WASTE_2", "Tullantı 2", LocationType.VWaste, AllowsFood: true, AllowsNonFood: true),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("VIRTUAL_LOCATION_EXISTS", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    // ================================================================ optimistic locking (409)

    [Fact]
    public async Task Updating_a_product_with_a_stale_row_version_is_rejected()
    {
        var products = new FakeProductRepository();
        products.Products.Add(NewProduct().WithId(42u));
        var handler = new UpdateProductCommandHandler(
            new FakeMasterDataUnitOfWork(), products, new FakeProductCategoryRepository(), new FakeSupplierRepository(), new FakeTenantContext());

        var result = await handler.HandleAsync(NewUpdateCommand(rowVersion: 7), None);

        Assert.True(result.IsFailure);
        Assert.Equal("STALE_VERSION", result.Error.Code);
        Assert.Equal(409, result.Error.Status);
    }

    [Fact]
    public async Task Updating_a_reason_code_with_a_stale_row_version_is_rejected()
    {
        var reasonCodes = new FakeReasonCodeRepository();
        reasonCodes.ReasonCodes.Add(ReasonCode.Create(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste).WithId((ushort)5));
        var handler = new UpdateReasonCodeCommandHandler(new FakeMasterDataUnitOfWork(), reasonCodes, new FakeTenantContext());

        var result = await handler.HandleAsync(
            new UpdateReasonCodeCommand(5, RowVersion: 9, "Yeni ad", RequiresApproval: true, RequiresPhoto: true, IsActive: true, ReasonGroup: null),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("STALE_VERSION", result.Error.Code);
    }

    // ================================================================ immutability through the handler

    [Fact]
    public async Task Updating_a_product_sku_is_refused_before_anything_is_written()
    {
        var products = new FakeProductRepository();
        var product = NewProduct().WithId(42u);
        products.Products.Add(product);
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new UpdateProductCommandHandler(
            unitOfWork, products, new FakeProductCategoryRepository(), new FakeSupplierRepository(), new FakeTenantContext());

        var result = await handler.HandleAsync(NewUpdateCommand(sku: "CHK-999"), None);

        Assert.True(result.IsFailure);
        Assert.Equal("SKU_IMMUTABLE", result.Error.Code);
        Assert.Equal("Toyuq döşü", product.Name);
        Assert.Equal(0, unitOfWork.SaveCount);
        Assert.False(unitOfWork.Committed);
    }

    [Fact]
    public async Task Updating_a_product_base_uom_is_refused()
    {
        var products = new FakeProductRepository();
        products.Products.Add(NewProduct().WithId(42u));
        var handler = new UpdateProductCommandHandler(
            new FakeMasterDataUnitOfWork(), products, new FakeProductCategoryRepository(), new FakeSupplierRepository(), new FakeTenantContext());

        var result = await handler.HandleAsync(NewUpdateCommand(baseUomId: 99), None);

        Assert.True(result.IsFailure);
        Assert.Equal("BASE_UOM_IMMUTABLE", result.Error.Code);
    }

    [Fact]
    public async Task A_successful_product_update_is_audited_and_committed()
    {
        var products = new FakeProductRepository();
        var product = NewProduct().WithId(42u);
        products.Products.Add(product);
        var categories = new FakeProductCategoryRepository();
        categories.Categories.Add(ProductCategory.Create(1, "FOOD", "Qida", ProductType.Food).WithId(7u));
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new UpdateProductCommandHandler(
            unitOfWork, products, categories, new FakeSupplierRepository(), new FakeTenantContext());

        var result = await handler.HandleAsync(NewUpdateCommand(name: "Toyuq budu"), None);

        Assert.True(result.IsSuccess);
        Assert.Equal("Toyuq budu", product.Name);
        Assert.True(unitOfWork.Committed);
        var audit = Assert.Single(unitOfWork.AuditTrail.Entries);
        Assert.Equal("master_product", audit.EntityType);
        Assert.Equal(42L, audit.EntityId);
    }

    // ================================================================ versioned factors through the handler

    [Fact]
    public async Task Adding_a_uom_with_a_past_valid_from_is_refused()
    {
        var products = new FakeProductRepository();
        products.Products.Add(NewProduct().WithId(42u));
        var uoms = new FakeUomRepository();
        uoms.Uoms.Add(Uom.Create(1, "CASE", "yeşik", UomClass.Count).Value.WithId((ushort)2));
        var handler = new AddProductUomCommandHandler(
            new FakeMasterDataUnitOfWork(), products, uoms, new FakeTenantContext(), new FakeClock());

        var result = await handler.HandleAsync(
            new AddProductUomCommand(42, 2, 12m, IsPurchaseDefault: false, IsIssueDefault: false, new DateOnly(2026, 1, 1)),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_FACTOR", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public async Task Adding_a_new_factor_versions_the_existing_row()
    {
        var products = new FakeProductRepository();
        var product = NewProduct().WithId(42u);
        product.AddOrReplaceUom(2, 12m, Start);
        products.Products.Add(product);

        var uoms = new FakeUomRepository();
        uoms.Uoms.Add(Uom.Create(1, "CASE", "yeşik", UomClass.Count).Value.WithId((ushort)2));
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new AddProductUomCommandHandler(unitOfWork, products, uoms, new FakeTenantContext(), new FakeClock());

        var newFrom = new DateOnly(2026, 10, 1);
        var result = await handler.HandleAsync(
            new AddProductUomCommand(42, 2, 24m, IsPurchaseDefault: true, IsIssueDefault: false, newFrom),
            None);

        Assert.True(result.IsSuccess);
        Assert.Equal(24m, result.Value.FactorToBase);
        Assert.Equal("CASE", result.Value.UomCode);
        Assert.Equal(2, product.Uoms.Count(u => u.UomId == 2));
        Assert.Equal(newFrom.AddDays(-1), product.Uoms.First(u => u.UomId == 2 && u.FactorToBase == 12m).ValidTo);
        Assert.True(unitOfWork.Committed);
        Assert.Contains(unitOfWork.AuditTrail.Entries, e => e.EntityType == "master_product_uom");
    }

    // ================================================================ reason code group filtering

    [Fact]
    public async Task Reason_codes_are_filtered_by_group_and_activity()
    {
        var queries = new FakeMasterDataQueries();
        queries.ReasonCodes.AddRange(
        [
            new(1, "EXPIRED", "Vaxtı keçib", ReasonGroup.Waste, true, true, true, 1),
            new(2, "DAMAGED", "Zədələnib", ReasonGroup.Waste, true, true, false, 1),
            new(3, "COUNT_DIFF", "Sayım fərqi", ReasonGroup.Adjustment, true, false, true, 1),
            new(4, "AQTA", "AQTA nümunəsi", ReasonGroup.Sample, false, false, true, 1),
        ]);
        var handler = new ReasonCodeQueryHandler(queries);

        var waste = await handler.HandleAsync(new GetReasonCodesQuery(ReasonGroup.Waste, IsActive: null), None);
        var activeWaste = await handler.HandleAsync(new GetReasonCodesQuery(ReasonGroup.Waste, IsActive: true), None);
        var all = await handler.HandleAsync(new GetReasonCodesQuery(null, null), None);

        Assert.True(waste.IsSuccess);
        Assert.Equal<string>(["DAMAGED", "EXPIRED"], waste.Value.Select(r => r.Code));
        Assert.Equal<string>(["EXPIRED"], activeWaste.Value.Select(r => r.Code));
        Assert.Equal(4, all.Value.Count);
        Assert.Null(queries.LastReasonGroup);
    }

    // ================================================================ helpers

    private static Product NewProduct() =>
        Product.Create(1, "CHK-001", "Toyuq döşü", categoryId: 7, baseUomId: 1, Start).Value;

    private static CreateProductCommand NewProductCommand(string sku) => new(
        sku,
        "Toyuq döşü",
        Barcode: null,
        CategoryId: 7,
        Brand: null,
        BaseUomId: 1,
        DefaultSupplierId: null,
        MinStock: null,
        MaxStock: null,
        ReorderPoint: null,
        VatRate: null,
        RequiresBatch: false,
        RequiresExpiry: false,
        IssueStrategy: null,
        ShelfLifeDays: null,
        AdditionalUoms: []);

    private static UpdateProductCommand NewUpdateCommand(
        uint rowVersion = 1,
        string name = "Toyuq döşü",
        string? sku = null,
        ushort? baseUomId = null) => new(
        ProductId: 42,
        RowVersion: rowVersion,
        Name: name,
        Barcode: null,
        CategoryId: 7,
        Brand: null,
        DefaultSupplierId: null,
        MinStock: null,
        MaxStock: null,
        ReorderPoint: null,
        VatRate: 18m,
        RequiresBatch: false,
        RequiresExpiry: false,
        IssueStrategy: IssueStrategy.Fefo,
        ShelfLifeDays: null,
        ImageAttachmentId: null,
        IsActive: true,
        Sku: sku,
        BaseUomId: baseUomId);
}
