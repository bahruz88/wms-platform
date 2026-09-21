using Dapper;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;
using Wms.Consumption.Domain.Services;

namespace Wms.Consumption.Infrastructure.Persistence.Repositories;

public sealed class MenuItemRepository(ConsumptionDbContext db) : IMenuItemRepository
{
    public Task<MenuItem?> GetAsync(uint menuItemId, CancellationToken cancellationToken) =>
        db.MenuItems.FirstOrDefaultAsync(m => m.Id == menuItemId, cancellationToken);

    public Task<bool> CodeExistsAsync(uint tenantId, string code, uint? exceptId, CancellationToken cancellationToken) =>
        db.MenuItems.AsNoTracking().AnyAsync(m => m.TenantId == tenantId && m.Code == code && (exceptId == null || m.Id != exceptId), cancellationToken);

    public Task<bool> PosCodeExistsAsync(uint tenantId, string posCode, uint? exceptId, CancellationToken cancellationToken) =>
        db.MenuItems.AsNoTracking().AnyAsync(m => m.TenantId == tenantId && m.PosCode == posCode && (exceptId == null || m.Id != exceptId), cancellationToken);

    public async Task<IReadOnlyDictionary<string, uint>> ResolveByPosCodeAsync(
        uint tenantId,
        IReadOnlyCollection<string> posCodes,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(posCodes);
        if (posCodes.Count == 0)
        {
            return new Dictionary<string, uint>(StringComparer.OrdinalIgnoreCase);
        }

        var codes = posCodes.ToArray();
        var rows = await db.MenuItems.AsNoTracking()
            .Where(m => m.TenantId == tenantId && m.PosCode != null && codes.Contains(m.PosCode))
            .Select(m => new { m.PosCode, m.Id })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var map = new Dictionary<string, uint>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in rows)
        {
            map[row.PosCode!] = row.Id;
        }

        return map;
    }

    public async Task<IReadOnlyDictionary<uint, string>> GetNamesAsync(
        uint tenantId,
        IReadOnlyCollection<uint> menuItemIds,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(menuItemIds);
        if (menuItemIds.Count == 0)
        {
            return new Dictionary<uint, string>();
        }

        var ids = menuItemIds.ToArray();
        return await db.MenuItems.AsNoTracking()
            .Where(m => m.TenantId == tenantId && ids.Contains(m.Id))
            .ToDictionaryAsync(m => m.Id, m => m.Name, cancellationToken)
            .ConfigureAwait(false);
    }

    public void Add(MenuItem menuItem) => db.MenuItems.Add(menuItem);
}

public sealed class RecipeRepository(ConsumptionDbContext db) : IRecipeRepository
{
    public Task<Recipe?> GetAsync(uint recipeId, CancellationToken cancellationToken) =>
        db.Recipes.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == recipeId, cancellationToken);

    public async Task<IReadOnlyList<Recipe>> GetVersionsAsync(uint menuItemId, CancellationToken cancellationToken) =>
        await db.Recipes.AsNoTracking().Include(r => r.Lines)
            .Where(r => r.MenuItemId == menuItemId)
            .OrderByDescending(r => r.ValidFrom).ThenByDescending(r => r.VersionNo)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

    /// <summary>Invariant 4: the version in force on the sales date, never the current one.</summary>
    public Task<Recipe?> GetEffectiveAsync(uint menuItemId, DateOnly date, CancellationToken cancellationToken) =>
        db.Recipes.AsNoTracking().Include(r => r.Lines)
            .Where(r => r.MenuItemId == menuItemId
                && r.Status != RecipeStatus.Draft
                && r.ValidFrom <= date
                && (r.ValidTo == null || r.ValidTo >= date))
            .OrderByDescending(r => r.ValidFrom)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<IReadOnlyDictionary<uint, BomRecipe>> GetEffectiveBomAsync(uint tenantId, DateOnly date, CancellationToken cancellationToken)
    {
        var rows = await db.Recipes.AsNoTracking().Include(r => r.Lines)
            .Where(r => r.TenantId == tenantId
                && r.Status != RecipeStatus.Draft
                && r.ValidFrom <= date
                && (r.ValidTo == null || r.ValidTo >= date))
            .OrderBy(r => r.MenuItemId).ThenByDescending(r => r.ValidFrom).ThenByDescending(r => r.VersionNo)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var map = new Dictionary<uint, BomRecipe>();
        foreach (var recipe in rows)
        {
            // Ordered newest-first: the first row per menu item is the effective one.
            if (map.ContainsKey(recipe.MenuItemId) || recipe.Lines.Count == 0)
            {
                continue;
            }

            map[recipe.MenuItemId] = new BomRecipe(
                recipe.Id,
                recipe.MenuItemId,
                recipe.YieldPortions,
                recipe.Lines
                    .OrderBy(l => l.LineNo)
                    .Select(l => new BomLine(
                        l.LineNo, l.ComponentType, l.ProductId, l.SubMenuItemId, l.QtyPerPortion, l.UomId, l.YieldPct, l.IsOptional, l.AttachRatePct))
                    .ToList());
        }

        return map;
    }

    public Task<Recipe?> GetActiveAsync(uint menuItemId, CancellationToken cancellationToken) =>
        db.Recipes.Include(r => r.Lines)
            .Where(r => r.MenuItemId == menuItemId && r.Status == RecipeStatus.Active)
            .OrderByDescending(r => r.ValidFrom)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<ushort> NextVersionNoAsync(uint menuItemId, CancellationToken cancellationToken)
    {
        var max = await db.Recipes.AsNoTracking()
            .Where(r => r.MenuItemId == menuItemId)
            .Select(r => (int?)r.VersionNo)
            .MaxAsync(cancellationToken)
            .ConfigureAwait(false);
        return (ushort)((max ?? 0) + 1);
    }

    public void Add(Recipe recipe) => db.Recipes.Add(recipe);
}

public sealed class SalesImportRepository(ConsumptionDbContext db) : ISalesImportRepository
{
    public Task<SalesImport?> GetAsync(long importId, CancellationToken cancellationToken) =>
        db.SalesImports.Include(i => i.Lines).FirstOrDefaultAsync(i => i.Id == importId, cancellationToken);

    public Task<SalesImport?> FindByDayAsync(uint tenantId, uint locationId, DateOnly businessDate, CancellationToken cancellationToken) =>
        db.SalesImports.Include(i => i.Lines)
            .FirstOrDefaultAsync(i => i.TenantId == tenantId && i.LocationId == locationId && i.BusinessDate == businessDate, cancellationToken);

    public async Task<IReadOnlyList<uint>> LocationsMissingImportAsync(uint tenantId, DateOnly businessDate, CancellationToken cancellationToken)
    {
        // Locations that reported at least once before but not on this business date.
        var known = await db.SalesImports.AsNoTracking()
            .Where(i => i.TenantId == tenantId)
            .Select(i => i.LocationId)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var reported = await db.SalesImports.AsNoTracking()
            .Where(i => i.TenantId == tenantId && i.BusinessDate == businessDate && i.Status != SalesImportStatus.Cancelled)
            .Select(i => i.LocationId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return known.Except(reported).Order().ToList();
    }

    public void Add(SalesImport salesImport) => db.SalesImports.Add(salesImport);
}

public sealed class ConsumptionRunRepository(ConsumptionDbContext db) : IConsumptionRunRepository
{
    public Task<ConsumptionRun?> GetAsync(long runId, CancellationToken cancellationToken) =>
        db.Runs.Include(r => r.Lines).FirstOrDefaultAsync(r => r.Id == runId, cancellationToken);

    public Task<ConsumptionRun?> FindByDayAsync(uint tenantId, uint locationId, DateOnly businessDate, CancellationToken cancellationToken) =>
        db.Runs.Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.TenantId == tenantId && r.LocationId == locationId && r.BusinessDate == businessDate, cancellationToken);

    public Task<ConsumptionRun?> FindByImportAsync(uint tenantId, long importId, CancellationToken cancellationToken) =>
        db.Runs.Include(r => r.Lines).FirstOrDefaultAsync(r => r.TenantId == tenantId && r.ImportId == importId, cancellationToken);

    public async Task<DateOnly?> LastPostedBusinessDateForMenuItemAsync(uint tenantId, uint menuItemId, CancellationToken cancellationToken)
    {
        // The menu item itself, plus every menu item that reaches it through a SUB_RECIPE line (bounded by the
        // exploder's depth cap, so a malformed graph cannot loop here either).
        var affected = new HashSet<uint> { menuItemId };
        for (var depth = 0; depth < Wms.Consumption.Domain.Services.BomExploder.MaxDepth; depth++)
        {
            var current = affected.ToArray();
            var parents = await (from line in db.RecipeLines.AsNoTracking()
                                 join recipe in db.Recipes.AsNoTracking() on line.RecipeId equals recipe.Id
                                 where line.ComponentType == ComponentType.SubRecipe
                                       && line.SubMenuItemId != null
                                       && current.Contains(line.SubMenuItemId!.Value)
                                 select recipe.MenuItemId)
                .Distinct()
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

            if (parents.All(p => !affected.Add(p)))
            {
                break;
            }
        }

        var reachable = affected.ToArray();
        return await (from run in db.Runs.AsNoTracking()
                      join line in db.SalesLines.AsNoTracking() on run.ImportId equals line.ImportId
                      where run.TenantId == tenantId
                            && run.Status == ConsumptionRunStatus.Posted
                            && line.MenuItemId != null
                            && reachable.Contains(line.MenuItemId!.Value)
                      select (DateOnly?)run.BusinessDate)
            .MaxAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public async Task<IReadOnlyList<long>> PendingImportIdsAsync(uint tenantId, DateOnly businessDate, CancellationToken cancellationToken)
    {
        var withRun = db.Runs.AsNoTracking().Where(r => r.TenantId == tenantId).Select(r => r.ImportId);
        return await db.SalesImports.AsNoTracking()
            .Where(i => i.TenantId == tenantId
                && i.BusinessDate == businessDate
                && i.Status == SalesImportStatus.Submitted
                && !withRun.Contains(i.Id))
            .OrderBy(i => i.Id)
            .Select(i => i.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
    }

    public void Add(ConsumptionRun run) => db.Runs.Add(run);
}

/// <summary>Raw scan across tenants for the recurring jobs (no tenant context yet at that point).</summary>
public sealed class TenantScanner(ConsumptionDbContext db) : ITenantScanner
{
    public async Task<IReadOnlyList<uint>> GetActiveTenantsAsync(CancellationToken cancellationToken)
    {
        const string sql = "SELECT DISTINCT tenant_id FROM cons_sales_import ORDER BY tenant_id";
        var connection = db.Database.GetDbConnection();
        await db.Database.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            var rows = await connection
                .QueryAsync<uint>(new CommandDefinition(sql, cancellationToken: cancellationToken))
                .ConfigureAwait(false);
            return rows.ToList();
        }
        finally
        {
            await db.Database.CloseConnectionAsync().ConfigureAwait(false);
        }
    }
}
