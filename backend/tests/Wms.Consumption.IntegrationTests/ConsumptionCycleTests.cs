using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.Messaging;
using Wms.Consumption.Application.Commands.MenuItems;
using Wms.Consumption.Application.Commands.Recipes;
using Wms.Consumption.Application.Commands.Runs;
using Wms.Consumption.Application.Commands.SalesImports;
using Wms.Consumption.Domain.Enums;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.Consumption.IntegrationTests;

/// <summary>
/// The whole of ADR-012 against a real MySQL: products, balances and a versioned recipe with a sub-recipe and a
/// processing loss; sales in; calculate; post. Then the three invariants that matter most —
/// the ledger group sums to zero, the branch balance dropped by exactly what was posted and
/// <c>V_CONSUMPTION</c> rose by the same amount — plus a deliberate shortfall that must post what exists and
/// record the rest without driving stock negative.
/// </summary>
[Collection(ConsumptionCollection.Name)]
[Trait("Category", "Integration")]
public sealed class ConsumptionCycleTests(ConsumptionFixture fixture)
{
    private const uint TenantId = ConsumptionFixture.TenantId;

    [Fact]
    public async Task A_full_cycle_posts_a_balanced_group_and_moves_exactly_the_posted_quantity()
    {
        var cancellationToken = TestCancellation.Token;
        var seed = await SeedAsync("FULL", new DateOnly(2026, 9, 20), cancellationToken).ConfigureAwait(true);

        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        // 1. Menu items: a sold sandwich and the sauce prepared in the branch.
        var sandwich = await CreateMenuItemAsync(dispatcher, $"SW-{seed.Suffix}", $"PLU-{seed.Suffix}-1", "Italian BMT 15 sm", false, cancellationToken).ConfigureAwait(true);
        var sauce = await CreateMenuItemAsync(dispatcher, $"SC-{seed.Suffix}", $"PLU-{seed.Suffix}-2", "Chipotle sousu", true, cancellationToken).ConfigureAwait(true);

        // 2. The sauce: one preparation yields 10 portions from 500 g of oil.
        await CreateAndActivateRecipeAsync(
            dispatcher, sauce, yieldPortions: 10m, validFrom: new DateOnly(2026, 1, 1), cancellationToken,
            Ingredient(1, seed.OilId, 500m, seed.GramUomId));

        // 3. The sandwich: 20 g lettuce with an 8 % trim loss, 150 g chicken bought in kg, and 2 portions of sauce.
        await CreateAndActivateRecipeAsync(
            dispatcher, sandwich, yieldPortions: 1m, validFrom: new DateOnly(2026, 1, 1), cancellationToken,
            Ingredient(1, seed.LettuceId, 20m, seed.GramUomId, yieldPct: 92m),
            Ingredient(2, seed.ChickenId, 0.15m, seed.KilogramUomId),
            SubRecipe(3, sauce, 2m));

        // 4. A day of sales: 100 sandwiches.
        var import = await dispatcher.SendAsync(
            new CreateSalesImportCommand(seed.LocationId, seed.BusinessDate, SalesSource.Manual, "SHIFT-1",
                [new SalesLineInput(sandwich, null, 100m, 1200m)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(import.IsSuccess, Describe(import));
        Assert.True((await dispatcher.SendAsync(new SubmitSalesImportCommand(import.Value.Id, null), cancellationToken).ConfigureAwait(true)).IsSuccess);

        // 5. Calculate.
        var run = await dispatcher.SendAsync(
            new CreateConsumptionRunCommand(import.Value.Id, PostImmediately: false, Guid.NewGuid()), cancellationToken).ConfigureAwait(true);
        Assert.True(run.IsSuccess, Describe(run));
        Assert.Equal("CALCULATED", run.Value.Status);
        Assert.Equal(0, run.Value.UnmappedCount);

        var lettuce = run.Value.Lines.Single(l => l.ProductId == seed.LettuceId);
        var chicken = run.Value.Lines.Single(l => l.ProductId == seed.ChickenId);
        var oil = run.Value.Lines.Single(l => l.ProductId == seed.OilId);

        // 100 x 20 / 0.92 = 2173.9130 g; 100 x 0.15 kg x 1000 = 15000 g; 100 x 2 / 10 x 500 = 10000 g.
        Assert.Equal(2173.9130m, lettuce.TheoreticalQtyBase);
        Assert.Equal(15000.0000m, chicken.TheoreticalQtyBase);
        Assert.Equal(10000.0000m, oil.TheoreticalQtyBase);
        Assert.Equal(0, run.Value.ShortfallCount);

        // 6. Post.
        var posted = await dispatcher.SendAsync(
            new PostConsumptionRunCommand(run.Value.Id, null, Guid.NewGuid()), cancellationToken).ConfigureAwait(true);
        Assert.True(posted.IsSuccess, Describe(posted));
        Assert.Equal("POSTED", posted.Value.Status);
        Assert.NotNull(posted.Value.MovementGroupId);
        Assert.Equal(0, posted.Value.ShortfallCount);

        var groupId = posted.Value.MovementGroupId!.Value;

        await using var inventory = fixture.Inventory();

        // Invariant 1: the CONSUMPTION group is double entry, so it sums to zero.
        var group = await inventory.MovementGroups.AsNoTracking().SingleAsync(g => g.Id == groupId, cancellationToken).ConfigureAwait(true);
        Assert.Equal(DocType.Consumption, group.DocType);
        Assert.Equal(posted.Value.DocNo, group.DocNo);
        var groupSum = await inventory.Movements.AsNoTracking().Where(m => m.GroupId == groupId).SumAsync(m => m.QtyBase, cancellationToken).ConfigureAwait(true);
        Assert.Equal(0m, groupSum);

        // The branch balance fell by exactly the posted quantity and V_CONSUMPTION rose by the same amount.
        foreach (var line in posted.Value.Lines)
        {
            var opening = seed.Opening[line.ProductId];
            var branchQty = await BalanceAsync(inventory, line.ProductId, seed.LocationId, cancellationToken).ConfigureAwait(true);
            var consumedQty = await BalanceAsync(inventory, line.ProductId, seed.ConsumptionLocationId, cancellationToken).ConfigureAwait(true);

            Assert.Equal(opening - line.PostedQtyBase, branchQty);
            Assert.Equal(line.PostedQtyBase, consumedQty);
            Assert.Equal(line.TheoreticalQtyBase, line.PostedQtyBase);
        }

        // ADR-004: every balance equals SUM(inv_movement.qty_base) for the same key.
        var ledgerBranch = await inventory.Movements.AsNoTracking()
            .Where(m => m.ProductId == seed.LettuceId && m.LocationId == seed.LocationId)
            .SumAsync(m => m.QtyBase, cancellationToken).ConfigureAwait(true);
        Assert.Equal(await BalanceAsync(inventory, seed.LettuceId, seed.LocationId, cancellationToken).ConfigureAwait(true), ledgerBranch);

        // The sales import is now CONSUMED (one day, one document).
        await using var consumption = fixture.Consumption();
        var importRow = await consumption.SalesImports.AsNoTracking().SingleAsync(i => i.Id == import.Value.Id, cancellationToken).ConfigureAwait(true);
        Assert.Equal(SalesImportStatus.Consumed, importRow.Status);

        // The outbox carries the events of ADR-012 §8.
        var eventTypes = await consumption.Outbox.AsNoTracking()
            .Where(o => o.TenantId == TenantId)
            .Select(o => o.EventType)
            .ToListAsync(cancellationToken).ConfigureAwait(true);
        Assert.Contains("SalesImported", eventTypes);
        Assert.Contains("ConsumptionPosted", eventTypes);
    }

    [Fact]
    public async Task A_shortfall_posts_what_exists_and_records_the_rest_without_driving_stock_negative()
    {
        var cancellationToken = TestCancellation.Token;
        // Only 400 g of oil on hand, the recipe needs 1000 g.
        var seed = await SeedAsync("SHORT", new DateOnly(2026, 9, 19), cancellationToken, oilQty: 400m).ConfigureAwait(true);

        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        var soup = await CreateMenuItemAsync(dispatcher, $"SP-{seed.Suffix}", $"PLU-{seed.Suffix}-9", "Sup", false, cancellationToken).ConfigureAwait(true);
        await CreateAndActivateRecipeAsync(
            dispatcher, soup, yieldPortions: 1m, validFrom: new DateOnly(2026, 1, 1), cancellationToken,
            Ingredient(1, seed.OilId, 100m, seed.GramUomId),
            Ingredient(2, seed.LettuceId, 5m, seed.GramUomId));

        var import = await dispatcher.SendAsync(
            new CreateSalesImportCommand(seed.LocationId, seed.BusinessDate, SalesSource.Manual, null,
                [new SalesLineInput(soup, null, 10m, null), new SalesLineInput(null, "UNKNOWN-POS", 3m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(import.IsSuccess, Describe(import));
        Assert.True((await dispatcher.SendAsync(new SubmitSalesImportCommand(import.Value.Id, null), cancellationToken).ConfigureAwait(true)).IsSuccess);

        var run = await dispatcher.SendAsync(
            new CreateConsumptionRunCommand(import.Value.Id, PostImmediately: true, Guid.NewGuid()), cancellationToken).ConfigureAwait(true);
        Assert.True(run.IsSuccess, Describe(run));
        Assert.Equal("POSTED", run.Value.Status);

        // Invariant 5: the unrecognised POS code is counted, not dropped.
        Assert.Equal(1, run.Value.UnmappedCount);

        // Invariant 3: 1000 g wanted, 400 g available -> 400 posted, 600 recorded as a shortfall.
        var oil = run.Value.Lines.Single(l => l.ProductId == seed.OilId);
        Assert.Equal(1000.0000m, oil.TheoreticalQtyBase);
        Assert.Equal(400.0000m, oil.PostedQtyBase);
        Assert.Equal(600.0000m, oil.ShortfallQtyBase);
        Assert.Equal(1, run.Value.ShortfallCount);

        // The other product was fully covered, so a shortfall never blocks the rest of the document.
        var lettuce = run.Value.Lines.Single(l => l.ProductId == seed.LettuceId);
        Assert.Equal(50.0000m, lettuce.TheoreticalQtyBase);
        Assert.Equal(50.0000m, lettuce.PostedQtyBase);
        Assert.Equal(0m, lettuce.ShortfallQtyBase);

        await using var inventory = fixture.Inventory();

        // Stock is exactly zero, never negative.
        Assert.Equal(0m, await BalanceAsync(inventory, seed.OilId, seed.LocationId, cancellationToken).ConfigureAwait(true));
        Assert.Equal(400m, await BalanceAsync(inventory, seed.OilId, seed.ConsumptionLocationId, cancellationToken).ConfigureAwait(true));

        var noNegative = await inventory.Balances.AsNoTracking().AnyAsync(b => b.LocationId == seed.LocationId && b.QtyOnHand < 0m, cancellationToken).ConfigureAwait(true);
        Assert.False(noNegative);

        var groupSum = await inventory.Movements.AsNoTracking()
            .Where(m => m.GroupId == run.Value.MovementGroupId!.Value)
            .SumAsync(m => m.QtyBase, cancellationToken).ConfigureAwait(true);
        Assert.Equal(0m, groupSum);

        await using var consumption = fixture.Consumption();
        var eventTypes = await consumption.Outbox.AsNoTracking().Select(o => o.EventType).ToListAsync(cancellationToken).ConfigureAwait(true);
        Assert.Contains("ConsumptionShortfallDetected", eventTypes);
        Assert.Contains("SalesItemUnmapped", eventTypes);
    }

    [Fact]
    public async Task A_second_document_for_the_same_branch_day_is_refused()
    {
        var cancellationToken = TestCancellation.Token;
        var seed = await SeedAsync("DUP", new DateOnly(2026, 9, 18), cancellationToken).ConfigureAwait(true);

        using var scope = fixture.Services.CreateScope();
        var dispatcher = scope.ServiceProvider.GetRequiredService<IDispatcher>();

        var item = await CreateMenuItemAsync(dispatcher, $"DP-{seed.Suffix}", null, "Tək gün", false, cancellationToken).ConfigureAwait(true);
        var first = await dispatcher.SendAsync(
            new CreateSalesImportCommand(seed.LocationId, seed.BusinessDate, SalesSource.Manual, null, [new SalesLineInput(item, null, 1m, null)]),
            cancellationToken).ConfigureAwait(true);
        Assert.True(first.IsSuccess, Describe(first));

        var second = await dispatcher.SendAsync(
            new CreateSalesImportCommand(seed.LocationId, seed.BusinessDate, SalesSource.Manual, null, [new SalesLineInput(item, null, 2m, null)]),
            cancellationToken).ConfigureAwait(true);

        Assert.True(second.IsFailure);
        Assert.Equal("DUPLICATE_BUSINESS_DATE", second.Error.Code);
        Assert.Equal(409, second.Error.Status);
    }

    private static string Describe<T>(Wms.Common.Domain.Result<T> result) =>
        result.IsSuccess ? "ok" : $"{result.Error.Code}: {result.Error.Message}";

    private static RecipeLineInput Ingredient(ushort lineNo, uint productId, decimal qty, ushort uomId, decimal yieldPct = 100m) =>
        new(lineNo, ComponentType.FoodProduct, productId, null, qty, uomId, yieldPct, false, 100m);

    private static RecipeLineInput SubRecipe(ushort lineNo, uint subMenuItemId, decimal portions) =>
        new(lineNo, ComponentType.SubRecipe, null, subMenuItemId, portions, 3, 100m, false, 100m);

    private sealed record RecipeLineInput(
        ushort LineNo, ComponentType ComponentType, uint? ProductId, uint? SubMenuItemId,
        decimal QtyPerPortion, ushort UomId, decimal YieldPct, bool IsOptional, decimal AttachRatePct)
    {
        public RecipeComponentInput ToInput() =>
            new(LineNo, ComponentType, ProductId, SubMenuItemId, QtyPerPortion, UomId, YieldPct, IsOptional, AttachRatePct, null);
    }

    private static async Task<uint> CreateMenuItemAsync(
        IDispatcher dispatcher, string code, string? posCode, string name, bool isSubRecipe, CancellationToken cancellationToken)
    {
        var created = await dispatcher.SendAsync(new CreateMenuItemCommand(code, posCode, name, "Sandwich", isSubRecipe), cancellationToken).ConfigureAwait(true);
        Assert.True(created.IsSuccess, Describe(created));
        return created.Value.Id;
    }

    private static async Task CreateAndActivateRecipeAsync(
        IDispatcher dispatcher, uint menuItemId, decimal yieldPortions, DateOnly validFrom, CancellationToken cancellationToken, params RecipeLineInput[] lines)
    {
        var created = await dispatcher.SendAsync(
            new CreateRecipeVersionCommand(menuItemId, validFrom, yieldPortions, null, null, lines.Select(l => l.ToInput()).ToList()),
            cancellationToken).ConfigureAwait(true);
        Assert.True(created.IsSuccess, Describe(created));
        Assert.Equal("DRAFT", created.Value.Status);

        var activated = await dispatcher.SendAsync(
            new ActivateRecipeCommand(created.Value.Id, validFrom, created.Value.RowVersion), cancellationToken).ConfigureAwait(true);
        Assert.True(activated.IsSuccess, Describe(activated));
        Assert.Equal("ACTIVE", activated.Value.Status);
    }

    private static async Task<decimal> BalanceAsync(
        Wms.Inventory.Infrastructure.Persistence.InventoryDbContext db, uint productId, uint locationId, CancellationToken cancellationToken)
    {
        var rows = await db.Balances.AsNoTracking()
            .Where(b => b.ProductId == productId && b.LocationId == locationId)
            .Select(b => b.QtyOnHand)
            .ToListAsync(cancellationToken).ConfigureAwait(true);
        return rows.Sum();
    }

    private sealed record Seed(
        string Suffix,
        DateOnly BusinessDate,
        uint LocationId,
        uint ConsumptionLocationId,
        ushort GramUomId,
        ushort KilogramUomId,
        uint LettuceId,
        uint ChickenId,
        uint OilId,
        IReadOnlyDictionary<uint, decimal> Opening);

    /// <summary>Products, UoM factors, the branch, the V_CONSUMPTION counter-account and the opening balances.</summary>
    private async Task<Seed> SeedAsync(string suffix, DateOnly businessDate, CancellationToken cancellationToken, decimal oilQty = 50_000m)
    {
        await using var master = fixture.MasterData();

        var gram = Uom.Create(TenantId, $"G{suffix}", "qram", UomClass.Mass, decimals: 4).Value;
        var kilogram = Uom.Create(TenantId, $"KG{suffix}", "kiloqram", UomClass.Mass, decimals: 4).Value;
        var portion = Uom.Create(TenantId, $"PRT{suffix}", "porsiya", UomClass.Count, decimals: 4).Value;
        master.Uoms.AddRange(gram, kilogram, portion);

        var category = ProductCategory.Create(TenantId, $"FOOD{suffix}", "Qida", ProductType.Food);
        master.Categories.Add(category);
        await master.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

        var lettuce = MasterData.Domain.Entities.Product.Create(TenantId, $"LET-{suffix}", "Kahı", category.Id, gram.Id, new DateOnly(2026, 1, 1)).Value;
        var chicken = MasterData.Domain.Entities.Product.Create(TenantId, $"CHK-{suffix}", "Toyuq", category.Id, gram.Id, new DateOnly(2026, 1, 1)).Value;
        var oil = MasterData.Domain.Entities.Product.Create(TenantId, $"OIL-{suffix}", "Yağ", category.Id, gram.Id, new DateOnly(2026, 1, 1)).Value;
        Assert.True(chicken.AddOrReplaceUom(kilogram.Id, 1000m, new DateOnly(2026, 1, 1)).IsSuccess);
        master.Products.AddRange(lettuce, chicken, oil);

        var branch = Location.Create(TenantId, $"BR{suffix}", "Elmlər filialı", LocationType.Restaurant).Value;
        master.Locations.Add(branch);

        var consumptionLocation = await master.Locations
            .FirstOrDefaultAsync(l => l.LocationType == LocationType.VConsumption, cancellationToken).ConfigureAwait(true);
        if (consumptionLocation is null)
        {
            consumptionLocation = Location.Create(TenantId, "VCONS", "İstehlak (virtual)", LocationType.VConsumption).Value;
            master.Locations.Add(consumptionLocation);
        }

        // Opening stock is booked against V_ADJUSTMENT, never against V_CONSUMPTION: the test measures what the
        // consumption document alone puts on that counter-account.
        var openingCounter = await master.Locations
            .FirstOrDefaultAsync(l => l.LocationType == LocationType.VAdjustment, cancellationToken).ConfigureAwait(true);
        if (openingCounter is null)
        {
            openingCounter = Location.Create(TenantId, "VADJ", "Düzəliş (virtual)", LocationType.VAdjustment).Value;
            master.Locations.Add(openingCounter);
        }

        await master.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

        var opening = new Dictionary<uint, decimal>
        {
            [lettuce.Id] = 50_000m,
            [chicken.Id] = 50_000m,
            [oil.Id] = oilQty,
        };

        await using var inventory = fixture.Inventory();
        foreach (var (productId, qty) in opening)
        {
            var balance = StockBalance.Open(TenantId, productId, branch.Id, StockBalance.NoBatch, fixture.Clock.UtcNow);
            var openingGroup = MovementGroup.Create(
                new MovementGroupHeader(TenantId, DocType.Opening, $"OP-{suffix}-{productId}", new DateOnly(2026, 1, 1), fixture.Clock.UtcNow, 7, Guid.NewGuid()),
                [
                    new MovementLineInput(productId, openingCounter.Id, null, -qty, gram.Id, 1m, gram.Id, 4, 2.5m),
                    new MovementLineInput(productId, branch.Id, null, qty, gram.Id, 1m, gram.Id, 4, 2.5m),
                ]).Value;
            inventory.MovementGroups.Add(openingGroup);
            await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

            foreach (var movement in openingGroup.Lines.Where(m => m.LocationId == branch.Id))
            {
                Assert.True(balance.Apply(movement, allowNegativeStock: false, fixture.Clock.UtcNow).IsSuccess);
            }

            inventory.Balances.Add(balance);

            var counter = StockBalance.Open(TenantId, productId, openingCounter.Id, StockBalance.NoBatch, fixture.Clock.UtcNow);
            foreach (var movement in openingGroup.Lines.Where(m => m.LocationId == openingCounter.Id))
            {
                Assert.True(counter.Apply(movement, allowNegativeStock: true, fixture.Clock.UtcNow).IsSuccess);
            }

            inventory.Balances.Add(counter);
        }

        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(true);

        return new Seed(
            suffix, businessDate, branch.Id, consumptionLocation.Id, gram.Id, kilogram.Id,
            lettuce.Id, chicken.Id, oil.Id, opening);
    }
}
