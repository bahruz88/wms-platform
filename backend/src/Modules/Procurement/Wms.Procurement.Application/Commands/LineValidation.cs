using Wms.Common.Domain;
using Wms.MasterData.Contracts;
using Wms.Procurement.Domain;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Application.Commands;

/// <summary>Master-data checks every procurement document line goes through (spec §4.2 — always via contracts).</summary>
public static class LineValidation
{
    public static ProductType ToProductType(string masterDataProductType) =>
        string.Equals(masterDataProductType, "FOOD", StringComparison.OrdinalIgnoreCase) ? ProductType.Food : ProductType.NonFood;

    /// <summary>Loads every product of a document in one call and fails on an unknown or inactive one.</summary>
    public static async Task<Result<IReadOnlyDictionary<uint, ProductDto>>> LoadProductsAsync(
        IProductCatalog products,
        IReadOnlyCollection<uint> productIds,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(products);
        ArgumentNullException.ThrowIfNull(productIds);

        var distinct = productIds.Where(id => id != 0).Distinct().ToArray();
        if (distinct.Length == 0)
        {
            return Result.Success<IReadOnlyDictionary<uint, ProductDto>>(new Dictionary<uint, ProductDto>());
        }

        var loaded = (await products.GetManyAsync(distinct, cancellationToken).ConfigureAwait(false)).ToDictionary(p => p.Id);
        foreach (var id in distinct)
        {
            if (!loaded.TryGetValue(id, out var product) || !product.IsActive)
            {
                return ProcurementErrors.ProductNotFound(id);
            }
        }

        return Result.Success<IReadOnlyDictionary<uint, ProductDto>>(loaded);
    }

    /// <summary>A document carries one product type; every line must agree with it (contract: <c>422</c>).</summary>
    public static Result EnsureProductType(IReadOnlyDictionary<uint, ProductDto> products, ProductType expected)
    {
        ArgumentNullException.ThrowIfNull(products);

        foreach (var product in products.Values)
        {
            if (ToProductType(product.ProductType) != expected)
            {
                return ProcurementErrors.ProductTypeMismatch(product.Id, expected == ProductType.Food ? "FOOD" : "NON_FOOD");
            }
        }

        return Result.Success();
    }

    /// <summary>
    /// <c>master_product_uom.factor_to_base</c> per line, valid on the document date. A missing factor blocks the
    /// document rather than defaulting to 1 (spec §12.1).
    /// </summary>
    public static async Task<Result<IReadOnlyDictionary<(uint ProductId, ushort UomId), decimal>>> LoadUomFactorsAsync(
        IProductCatalog products,
        IEnumerable<(uint ProductId, ushort UomId)> pairs,
        DateOnly onDate,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(products);
        ArgumentNullException.ThrowIfNull(pairs);

        var factors = new Dictionary<(uint, ushort), decimal>();
        foreach (var pair in pairs.Distinct())
        {
            if (factors.ContainsKey(pair))
            {
                continue;
            }

            var factor = await products.GetUomFactorAsync(pair.ProductId, pair.UomId, onDate, cancellationToken).ConfigureAwait(false);
            if (factor is not > 0m)
            {
                return new Error(
                    "UOM_FACTOR_NOT_FOUND",
                    $"No conversion factor is defined for product {pair.ProductId} in UoM {pair.UomId} on {onDate:yyyy-MM-dd}.",
                    422);
            }

            factors[pair] = factor.Value;
        }

        return Result.Success<IReadOnlyDictionary<(uint, ushort), decimal>>(factors);
    }

    /// <summary>Resolves the FX rate of a document date, or fails with <c>409 FX_RATE_MISSING</c> (spec §12.5).</summary>
    public static async Task<Result<decimal>> ResolveFxRateAsync(
        ICurrencyRateReader currencyRates,
        string currency,
        DateOnly onDate,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(currencyRates);
        ArgumentException.ThrowIfNullOrWhiteSpace(currency);

        var rate = await currencyRates.GetRateToBaseAsync(currency, onDate, cancellationToken).ConfigureAwait(false);
        return rate is > 0m ? Result.Success(rate.Value) : ProcurementErrors.FxRateMissing(currency.ToUpperInvariant(), onDate);
    }
}
