using Wms.MasterData.Application.Commands;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;
using Wms.MasterData.Endpoints;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// The rest of the reference data the contract exposes: the category tree, virtual locations, certificate
/// expiry, currency-rate upsert, number-sequence preview and the UPPER_SNAKE wire format of query enums.
/// </summary>
public sealed class ReferenceDataTests
{
    private static readonly CancellationToken None = CancellationToken.None;

    // ================================================================ category tree

    [Fact]
    public void A_category_path_is_built_from_the_parent()
    {
        var parent = ProductCategory.Create(1, "NON_FOOD", "Qeyri-qida", ProductType.NonFood);
        var child = ProductCategory.Create(1, "CHEMICAL", "Kimyəvi", ProductType.NonFood, parentId: 1, parentPath: parent.Path);

        Assert.Equal("/NON_FOOD", parent.Path);
        Assert.Equal("/NON_FOOD/CHEMICAL", child.Path);
        Assert.True(child.IsActive);
        Assert.Equal(1u, child.RowVersion);
    }

    [Fact]
    public void Re_parenting_rewrites_the_materialised_path()
    {
        var food = ProductCategory.Create(1, "FOOD", "Qida", ProductType.Food).WithId(1u);
        var meat = ProductCategory.Create(1, "MEAT", "Ət", ProductType.Food).WithId(2u);

        Assert.True(meat.Reparent(food.Id, food.Path).IsSuccess);

        Assert.Equal(1u, meat.ParentId);
        Assert.Equal("/FOOD/MEAT", meat.Path);
    }

    [Fact]
    public async Task A_category_cannot_move_under_its_own_descendant()
    {
        var categories = new FakeProductCategoryRepository();
        var food = ProductCategory.Create(1, "FOOD", "Qida", ProductType.Food).WithId(1u);
        var meat = ProductCategory.Create(1, "MEAT", "Ət", ProductType.Food, food.Id, food.Path).WithId(2u);
        categories.Categories.AddRange([food, meat]);

        var handler = new UpdateCategoryCommandHandler(new FakeMasterDataUnitOfWork(), categories, new FakeTenantContext());
        var result = await handler.HandleAsync(
            new UpdateCategoryCommand(1, RowVersion: 1, ParentId: 2, "Qida", DefaultIssueStrategy: null, IsActive: true, ProductType: null),
            None);

        Assert.True(result.IsFailure);
        Assert.Equal("CATEGORY_CYCLE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public async Task Moving_a_category_re_paths_its_descendants()
    {
        var categories = new FakeProductCategoryRepository();
        var food = ProductCategory.Create(1, "FOOD", "Qida", ProductType.Food).WithId(1u);
        var meat = ProductCategory.Create(1, "MEAT", "Ət", ProductType.Food).WithId(2u);
        var beef = ProductCategory.Create(1, "BEEF", "Mal əti", ProductType.Food, meat.Id, meat.Path).WithId(3u);
        categories.Categories.AddRange([food, meat, beef]);

        var handler = new UpdateCategoryCommandHandler(new FakeMasterDataUnitOfWork(), categories, new FakeTenantContext());
        var result = await handler.HandleAsync(
            new UpdateCategoryCommand(2, RowVersion: 1, ParentId: 1, "Ət", DefaultIssueStrategy: IssueStrategy.Fifo, IsActive: true, ProductType: null),
            None);

        Assert.True(result.IsSuccess);
        Assert.Equal("/FOOD/MEAT", meat.Path);
        Assert.Equal("/FOOD/MEAT/BEEF", beef.Path);
        Assert.Equal(IssueStrategy.Fifo, meat.DefaultIssueStrategy);
    }

    // ================================================================ locations

    [Theory]
    [InlineData(LocationType.CentralWarehouse, false)]
    [InlineData(LocationType.Restaurant, false)]
    [InlineData(LocationType.Shelf, false)]
    [InlineData(LocationType.InTransit, true)]
    [InlineData(LocationType.VSupplier, true)]
    [InlineData(LocationType.VWaste, true)]
    [InlineData(LocationType.VConsumption, true)]
    public void Is_virtual_is_derived_from_the_location_type(LocationType locationType, bool expected)
    {
        var location = Location.Create(1, "L1", "Lokasiya", locationType).Value;

        Assert.Equal(expected, location.IsVirtual);
    }

    // ================================================================ supplier certificates

    [Fact]
    public void A_certificate_is_expired_once_its_expiry_date_has_passed()
    {
        var certificate = SupplierCertificate.CreateChecked(1, "HACCP", "C-1", new DateOnly(2025, 1, 1), new DateOnly(2026, 9, 21), null).Value;

        Assert.True(certificate.IsExpiredOn(new DateOnly(2026, 9, 22)));
        Assert.False(certificate.IsExpiredOn(new DateOnly(2026, 9, 21)));
    }

    [Fact]
    public void A_certificate_cannot_expire_before_it_was_issued()
    {
        var result = SupplierCertificate.CreateChecked(1, "HACCP", null, new DateOnly(2026, 5, 1), new DateOnly(2026, 4, 1), null);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_CERTIFICATE", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    // ================================================================ currency rates

    [Fact]
    public async Task Upserting_an_existing_rate_re_rates_it_and_switches_the_source_to_manual()
    {
        var rates = new FakeCurrencyRateRepository();
        var existing = CurrencyRate.Create(1, "USD", new DateOnly(2026, 9, 22), 1.7000m).Value.WithId(11u);
        rates.Rates.Add(existing);
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new UpsertCurrencyRateCommandHandler(unitOfWork, rates, new FakeTenantContext());

        var result = await handler.HandleAsync(new UpsertCurrencyRateCommand("usd", new DateOnly(2026, 9, 22), 1.7500m), None);

        Assert.True(result.IsSuccess);
        Assert.Equal(1.7500m, result.Value.RateToBase);
        Assert.Equal("MANUAL", result.Value.Source);
        Assert.Single(rates.Rates);
        Assert.True(unitOfWork.Committed);
        Assert.Single(unitOfWork.AuditTrail.Entries);
    }

    [Fact]
    public async Task Upserting_a_missing_rate_inserts_it()
    {
        var rates = new FakeCurrencyRateRepository();
        var unitOfWork = new FakeMasterDataUnitOfWork();
        var handler = new UpsertCurrencyRateCommandHandler(unitOfWork, rates, new FakeTenantContext());

        var result = await handler.HandleAsync(new UpsertCurrencyRateCommand("EUR", new DateOnly(2026, 9, 22), 1.8500m), None);

        Assert.True(result.IsSuccess);
        Assert.Equal("EUR", result.Value.Currency);
        Assert.Single(rates.Rates);
    }

    [Fact]
    public void A_non_positive_rate_is_rejected()
    {
        var rate = CurrencyRate.Create(1, "USD", new DateOnly(2026, 9, 22), 1.7000m).Value;

        var result = rate.UpdateRate(0m, CurrencyRate.ManualSource);

        Assert.True(result.IsFailure);
        Assert.Equal("INVALID_CURRENCY_RATE", result.Error.Code);
        Assert.Equal(1.7000m, rate.RateToBase);
    }

    // ================================================================ number sequences

    [Fact]
    public void The_next_number_preview_does_not_consume_a_number()
    {
        var sequence = NumberSequence.Create(1, "PR", "PR", "2026");

        Assert.Equal("PR-2026-00001", sequence.PreviewNext());
        Assert.Equal(0u, sequence.LastNumber);

        Assert.Equal("PR-2026-00001", sequence.Next().Value);
        Assert.Equal("PR-2026-00002", sequence.PreviewNext());
        Assert.Equal(1u, sequence.LastNumber);
    }

    // ================================================================ enum wire format

    [Theory]
    [InlineData("WASTE", ReasonGroup.Waste)]
    [InlineData("adjustment", ReasonGroup.Adjustment)]
    [InlineData("RETURN", ReasonGroup.Return)]
    [InlineData("TRANSFER", ReasonGroup.Transfer)]
    public void Reason_group_query_values_bind_from_upper_snake(string raw, ReasonGroup expected)
    {
        Assert.True(EnumQuery.TryParse<ReasonGroup>(raw, out var parsed));
        Assert.Equal(expected, parsed);
    }

    [Fact]
    public void Multi_word_enum_query_values_bind_from_upper_snake()
    {
        Assert.True(EnumQuery.TryParse<ProductType>("NON_FOOD", out var productType));
        Assert.Equal(ProductType.NonFood, productType);

        Assert.True(EnumQuery.TryParse<LocationType>("CENTRAL_WAREHOUSE", out var locationType));
        Assert.Equal(LocationType.CentralWarehouse, locationType);

        Assert.True(EnumQuery.TryParse<LocationType>("V_SUPPLIER", out var virtualType));
        Assert.Equal(LocationType.VSupplier, virtualType);
    }

    [Fact]
    public void An_absent_enum_query_value_means_no_filter()
    {
        Assert.True(EnumQuery.TryParse<ReasonGroup>(null, out var none));
        Assert.Null(none);

        Assert.True(EnumQuery.TryParse<ReasonGroup>("  ", out var blank));
        Assert.Null(blank);
    }

    [Fact]
    public void An_unknown_enum_query_value_is_reported_rather_than_ignored()
    {
        Assert.False(EnumQuery.TryParse<ReasonGroup>("SHRINKAGE", out var parsed));
        Assert.Null(parsed);
        Assert.Contains("WASTE", EnumQuery.Invalid<ReasonGroup>("reasonGroup", "SHRINKAGE"), StringComparison.Ordinal);
    }
}
