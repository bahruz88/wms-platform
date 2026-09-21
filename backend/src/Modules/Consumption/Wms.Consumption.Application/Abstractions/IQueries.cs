using Wms.Common.Application.Paging;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain.Enums;
using Wms.Common.Application.Security;

namespace Wms.Consumption.Application.Abstractions;

public sealed record MenuItemFilter(string? Search, bool? IsActive, bool? IsSubRecipe, bool? HasActiveRecipe);

public sealed record SalesImportFilter(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    SalesImportStatus? Status,
    SalesSource? Source,
    LocationScope VisibleLocations);

public sealed record ConsumptionRunFilter(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    ConsumptionRunStatus? Status,
    bool? HasShortfall,
    LocationScope VisibleLocations);

/// <summary>Read side of the module (<c>AsNoTracking</c>). Cost fields are dropped when <c>includeCost</c> is false (spec §16).</summary>
public interface IConsumptionQueries
{
    Task<PagedResult<MenuItemDto>> GetMenuItemsAsync(MenuItemFilter filter, PageRequest page, DateOnly today, CancellationToken cancellationToken);

    Task<MenuItemDetailDto?> GetMenuItemAsync(uint menuItemId, DateOnly today, CancellationToken cancellationToken);

    Task<IReadOnlyList<RecipeSummaryDto>> GetRecipeVersionsAsync(uint menuItemId, CancellationToken cancellationToken);

    Task<RecipeDto?> GetRecipeAsync(uint recipeId, CancellationToken cancellationToken);

    Task<PagedResult<SalesImportDto>> GetSalesImportsAsync(SalesImportFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<SalesImportDetailDto?> GetSalesImportAsync(long importId, DateOnly effectiveDate, CancellationToken cancellationToken);

    Task<PagedResult<ConsumptionRunDto>> GetRunsAsync(ConsumptionRunFilter filter, PageRequest page, CancellationToken cancellationToken);

    Task<ConsumptionRunDetailDto?> GetRunAsync(long runId, bool includeCost, CancellationToken cancellationToken);

    /// <summary>Portions sold per menu item over a period at a location — input of the portion-compliance report.</summary>
    Task<IReadOnlyList<(uint MenuItemId, string MenuItemName, decimal PortionsSold)>> GetPortionsSoldAsync(
        uint? locationId, uint? menuItemId, DateOnly periodFrom, DateOnly periodTo, CancellationToken cancellationToken);

    /// <summary>Theoretical consumption per product posted between two dates at a location.</summary>
    Task<IReadOnlyDictionary<(uint LocationId, uint ProductId), decimal>> GetTheoreticalConsumptionAsync(
        uint? locationId, uint? productId, DateOnly periodFrom, DateOnly periodTo, CancellationToken cancellationToken);
}
