using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Services;

namespace Wms.Consumption.Application.Abstractions;

public interface IMenuItemRepository
{
    Task<MenuItem?> GetAsync(uint menuItemId, CancellationToken cancellationToken);

    Task<bool> CodeExistsAsync(uint tenantId, string code, uint? exceptId, CancellationToken cancellationToken);

    Task<bool> PosCodeExistsAsync(uint tenantId, string posCode, uint? exceptId, CancellationToken cancellationToken);

    /// <summary>Maps POS codes to menu item ids in one round trip; unknown codes are simply absent (invariant 5).</summary>
    Task<IReadOnlyDictionary<string, uint>> ResolveByPosCodeAsync(uint tenantId, IReadOnlyCollection<string> posCodes, CancellationToken cancellationToken);

    Task<IReadOnlyDictionary<uint, string>> GetNamesAsync(uint tenantId, IReadOnlyCollection<uint> menuItemIds, CancellationToken cancellationToken);

    void Add(MenuItem menuItem);
}

public interface IRecipeRepository
{
    Task<Recipe?> GetAsync(uint recipeId, CancellationToken cancellationToken);

    Task<IReadOnlyList<Recipe>> GetVersionsAsync(uint menuItemId, CancellationToken cancellationToken);

    /// <summary>The version in force on <paramref name="date"/> — invariant 4: never the current one.</summary>
    Task<Recipe?> GetEffectiveAsync(uint menuItemId, DateOnly date, CancellationToken cancellationToken);

    /// <summary>All recipe versions effective on <paramref name="date"/>, keyed by menu item, for one BOM explosion pass.</summary>
    Task<IReadOnlyDictionary<uint, BomRecipe>> GetEffectiveBomAsync(uint tenantId, DateOnly date, CancellationToken cancellationToken);

    Task<Recipe?> GetActiveAsync(uint menuItemId, CancellationToken cancellationToken);

    Task<ushort> NextVersionNoAsync(uint menuItemId, CancellationToken cancellationToken);

    void Add(Recipe recipe);
}

public interface ISalesImportRepository
{
    Task<SalesImport?> GetAsync(long importId, CancellationToken cancellationToken);

    Task<SalesImport?> FindByDayAsync(uint tenantId, uint locationId, DateOnly businessDate, CancellationToken cancellationToken);

    /// <summary>Locations whose previous business day has no submitted/consumed import yet (SalesImportReminder job).</summary>
    Task<IReadOnlyList<uint>> LocationsMissingImportAsync(uint tenantId, DateOnly businessDate, CancellationToken cancellationToken);

    void Add(SalesImport salesImport);
}

public interface IConsumptionRunRepository
{
    Task<ConsumptionRun?> GetAsync(long runId, CancellationToken cancellationToken);

    Task<ConsumptionRun?> FindByDayAsync(uint tenantId, uint locationId, DateOnly businessDate, CancellationToken cancellationToken);

    Task<ConsumptionRun?> FindByImportAsync(uint tenantId, long importId, CancellationToken cancellationToken);

    /// <summary>
    /// Latest business date on which a POSTED run already consumed <paramref name="menuItemId"/> — directly, or
    /// through a recipe that uses it as a sub-recipe. Guards recipe activation with <c>409 PERIOD_CLOSED</c>
    /// (invariant 4): a posted day keeps the recipe it was calculated with.
    /// </summary>
    Task<DateOnly?> LastPostedBusinessDateForMenuItemAsync(uint tenantId, uint menuItemId, CancellationToken cancellationToken);

    /// <summary>Submitted sales imports of <paramref name="businessDate"/> that still have no run (ConsumptionRunner job).</summary>
    Task<IReadOnlyList<long>> PendingImportIdsAsync(uint tenantId, DateOnly businessDate, CancellationToken cancellationToken);

    void Add(ConsumptionRun run);
}

/// <summary>Tenants that own any consumption data — the entry point of the recurring jobs.</summary>
public interface ITenantScanner
{
    Task<IReadOnlyList<uint>> GetActiveTenantsAsync(CancellationToken cancellationToken);
}
