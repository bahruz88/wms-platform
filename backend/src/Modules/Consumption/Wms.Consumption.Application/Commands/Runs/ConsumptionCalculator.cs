using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Domain;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Services;
using Wms.Inventory.Contracts;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Application.Commands.Runs;

/// <summary>What one calculation produced: the per-product lines and how many sales lines produced nothing.</summary>
public sealed record CalculationOutcome(IReadOnlyList<ConsumptionRunLine> Lines, ushort UnmappedCount);

/// <summary>
/// The calculation sequence of branch-operations.md §5, shared by <c>createConsumptionRun</c> and
/// <c>calculateConsumptionRun</c>:
/// <list type="number">
/// <item>resolve the recipe version effective on the sales <c>businessDate</c> — not today's (invariant 4);</item>
/// <item>read the UoM factors from MasterData for that SAME date;</item>
/// <item>explode the BOM recursively (depth ≤ 5, cycles rejected) and aggregate per product;</item>
/// <item>read availability through <see cref="IStockBalanceReader"/> and set
/// <c>posted = min(theoretical, available)</c>, the rest is the shortfall (invariant 3).</item>
/// </list>
/// </summary>
public sealed class ConsumptionCalculator(
    IRecipeRepository recipes,
    IProductCatalog products,
    IStockBalanceReader balances)
{
    public async Task<Result<CalculationOutcome>> CalculateAsync(
        uint tenantId,
        SalesImport salesImport,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(salesImport);

        var businessDate = salesImport.BusinessDate;

        // 1. Recipe versions in force on the business date, keyed by menu item.
        var effective = await recipes.GetEffectiveBomAsync(tenantId, businessDate, cancellationToken).ConfigureAwait(false);
        var recipeSource = new InMemoryBomRecipeSource(effective);

        // 2. Product master data and conversion factors valid on the SAME date, resolved once.
        var productSource = await BuildProductSourceAsync(effective.Values, businessDate, cancellationToken).ConfigureAwait(false);

        // 3. Explode every mapped sales line that has a recipe; the rest are counted as unmapped (invariant 5).
        var totals = new Dictionary<uint, Accumulated>();
        var unmapped = 0;
        foreach (var line in salesImport.Lines)
        {
            if (line.MenuItemId is not { } menuItemId || !effective.ContainsKey(menuItemId))
            {
                unmapped++;
                continue;
            }

            var explosion = BomExploder.Explode(menuItemId, line.QtySold, recipeSource, productSource);
            if (explosion.IsFailure)
            {
                return explosion.Error;
            }

            foreach (var requirement in explosion.Value.Requirements)
            {
                if (totals.TryGetValue(requirement.ProductId, out var existing))
                {
                    totals[requirement.ProductId] = existing with { Qty = existing.Qty + requirement.RequiredQtyBase };
                    continue;
                }

                totals[requirement.ProductId] = new Accumulated(requirement.RequiredQtyBase, requirement.BaseUomId);
            }
        }

        // 4. Availability at the branch: posted = min(theoretical, available); the remainder is the shortfall.
        var lines = new List<ConsumptionRunLine>(totals.Count);
        foreach (var (productId, accumulated) in totals.OrderBy(kv => kv.Key))
        {
            var qty = Quantity.Round(accumulated.Qty, Quantity.StorageDecimals);
            if (qty <= 0m)
            {
                continue;
            }

            var runLine = ConsumptionRunLine.Create(tenantId, productId, qty, accumulated.BaseUomId);
            if (runLine.IsFailure)
            {
                return runLine.Error;
            }

            var level = await balances.GetAsync(productId, salesImport.LocationId, cancellationToken).ConfigureAwait(false);
            runLine.Value.Plan(level?.QtyAvailable ?? 0m);
            lines.Add(runLine.Value);
        }

        return new CalculationOutcome(lines, (ushort)Math.Min(unmapped, ushort.MaxValue));
    }

    private async Task<InMemoryBomProductSource> BuildProductSourceAsync(
        IEnumerable<BomRecipe> effectiveRecipes,
        DateOnly businessDate,
        CancellationToken cancellationToken)
    {
        var pairs = effectiveRecipes
            .SelectMany(r => r.Lines)
            .Where(l => l.ProductId is > 0)
            .Select(l => (ProductId: l.ProductId!.Value, l.UomId))
            .Distinct()
            .ToList();

        var productMap = new Dictionary<uint, BomProduct>();
        var factorMap = new Dictionary<(uint ProductId, ushort UomId), decimal>();

        foreach (var (productId, uomId) in pairs)
        {
            if (!productMap.ContainsKey(productId))
            {
                var product = await products.GetAsync(productId, cancellationToken).ConfigureAwait(false);
                if (product is not null)
                {
                    productMap[productId] = new BomProduct(product.Id, product.BaseUomId, product.BaseUomDecimals);
                }
            }

            // Frozen on the business date (invariant 4): a later factor change never rewrites history.
            var factor = await products.GetUomFactorAsync(productId, uomId, businessDate, cancellationToken).ConfigureAwait(false);
            if (factor is > 0m)
            {
                factorMap[(productId, uomId)] = factor.Value;
            }
        }

        return new InMemoryBomProductSource(productMap, factorMap);
    }

    private sealed record Accumulated(decimal Qty, ushort BaseUomId);
}
