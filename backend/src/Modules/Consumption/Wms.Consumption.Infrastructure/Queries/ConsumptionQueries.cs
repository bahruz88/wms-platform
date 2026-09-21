using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Common.Infrastructure.Persistence;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain.Entities;
using Wms.Consumption.Domain.Enums;
using Wms.Consumption.Infrastructure.Persistence;
using Wms.MasterData.Contracts;

namespace Wms.Consumption.Infrastructure.Queries;

/// <summary>Read side of the module. Every query is <c>AsNoTracking</c> (spec Əlavə A).</summary>
public sealed class ConsumptionQueries(ConsumptionDbContext db, IProductCatalog products, ILocationCatalog locations) : IConsumptionQueries
{
    public async Task<PagedResult<MenuItemDto>> GetMenuItemsAsync(
        MenuItemFilter filter,
        PageRequest page,
        DateOnly today,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.MenuItems.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(m => m.Name.Contains(search) || m.Code.Contains(search) || (m.PosCode != null && m.PosCode.Contains(search)));
        }

        if (filter.IsActive is { } isActive)
        {
            query = query.Where(m => m.IsActive == isActive);
        }

        if (filter.IsSubRecipe is { } isSubRecipe)
        {
            query = query.Where(m => m.IsSubRecipe == isSubRecipe);
        }

        var effectiveRecipes = db.Recipes.AsNoTracking()
            .Where(r => r.Status != RecipeStatus.Draft && r.ValidFrom <= today && (r.ValidTo == null || r.ValidTo >= today));

        if (filter.HasActiveRecipe is { } hasRecipe)
        {
            query = hasRecipe
                ? query.Where(m => effectiveRecipes.Any(r => r.MenuItemId == m.Id))
                : query.Where(m => !effectiveRecipes.Any(r => r.MenuItemId == m.Id));
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderBy(m => m.NameSortKey).ThenBy(m => m.Id)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(m => new
            {
                Item = m,
                ActiveRecipeId = effectiveRecipes.Where(r => r.MenuItemId == m.Id)
                    .OrderByDescending(r => r.ValidFrom)
                    .Select(r => (uint?)r.Id)
                    .FirstOrDefault(),
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = rows.Select(r => Map(r.Item, r.ActiveRecipeId)).ToList();
        return new PagedResult<MenuItemDto>(items, page.Page, page.Size, total);
    }

    public async Task<MenuItemDetailDto?> GetMenuItemAsync(uint menuItemId, DateOnly today, CancellationToken cancellationToken)
    {
        var item = await db.MenuItems.AsNoTracking().FirstOrDefaultAsync(m => m.Id == menuItemId, cancellationToken).ConfigureAwait(false);
        if (item is null)
        {
            return null;
        }

        var activeRecipeId = await db.Recipes.AsNoTracking()
            .Where(r => r.MenuItemId == menuItemId && r.Status != RecipeStatus.Draft && r.ValidFrom <= today && (r.ValidTo == null || r.ValidTo >= today))
            .OrderByDescending(r => r.ValidFrom)
            .Select(r => (uint?)r.Id)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        var versionCount = await db.Recipes.AsNoTracking().CountAsync(r => r.MenuItemId == menuItemId, cancellationToken).ConfigureAwait(false);

        var parentRecipeIds = await db.RecipeLines.AsNoTracking()
            .Where(l => l.ComponentType == ComponentType.SubRecipe && l.SubMenuItemId == menuItemId)
            .Select(l => l.RecipeId)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var usedIn = await LoadSummariesAsync(r => parentRecipeIds.Contains(r.Id), cancellationToken).ConfigureAwait(false);
        var basic = Map(item, activeRecipeId);

        return new MenuItemDetailDto(
            basic.Id, basic.Code, basic.PosCode, basic.Name, basic.Category, basic.IsSubRecipe, basic.IsActive,
            basic.ActiveRecipeId, basic.RowVersion, basic.Audit, versionCount, usedIn);
    }

    public Task<IReadOnlyList<RecipeSummaryDto>> GetRecipeVersionsAsync(uint menuItemId, CancellationToken cancellationToken) =>
        LoadSummariesAsync(r => r.MenuItemId == menuItemId, cancellationToken);

    public async Task<RecipeDto?> GetRecipeAsync(uint recipeId, CancellationToken cancellationToken)
    {
        var recipe = await db.Recipes.AsNoTracking().Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == recipeId, cancellationToken)
            .ConfigureAwait(false);
        if (recipe is null)
        {
            return null;
        }

        var menuItemName = await db.MenuItems.AsNoTracking()
            .Where(m => m.Id == recipe.MenuItemId)
            .Select(m => m.Name)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false) ?? string.Empty;

        var subIds = recipe.Lines.Where(l => l.SubMenuItemId is not null).Select(l => l.SubMenuItemId!.Value).Distinct().ToList();
        var subNames = subIds.Count == 0
            ? new Dictionary<uint, string>()
            : await db.MenuItems.AsNoTracking().Where(m => subIds.Contains(m.Id)).ToDictionaryAsync(m => m.Id, m => m.Name, cancellationToken).ConfigureAwait(false);

        var lines = new List<RecipeLineDto>(recipe.Lines.Count);
        foreach (var line in recipe.Lines.OrderBy(l => l.LineNo))
        {
            var product = line.ProductId is { } productId
                ? await products.GetAsync(productId, cancellationToken).ConfigureAwait(false)
                : null;

            lines.Add(new RecipeLineDto(
                line.LineNo,
                UpperSnakeCaseEnum.Format(line.ComponentType),
                line.ProductId,
                product?.Sku,
                product?.Name,
                line.SubMenuItemId,
                line.SubMenuItemId is { } subId ? subNames.GetValueOrDefault(subId) : null,
                line.QtyPerPortion,
                line.UomId,
                product is not null && product.BaseUomId == line.UomId ? product.BaseUomCode : string.Empty,
                line.YieldPct,
                line.IsOptional,
                line.AttachRatePct,
                line.Note));
        }

        return new RecipeDto(
            recipe.Id,
            recipe.MenuItemId,
            menuItemName,
            recipe.VersionNo,
            UpperSnakeCaseEnum.Format(recipe.Status),
            recipe.ValidFrom,
            recipe.ValidTo,
            recipe.Lines.Count,
            recipe.YieldPortions,
            recipe.Note,
            lines,
            recipe.RowVersion,
            new AuditDto(recipe.CreatedAt, recipe.CreatedBy, null, null, recipe.RowVersion));
    }

    public async Task<PagedResult<SalesImportDto>> GetSalesImportsAsync(SalesImportFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.SalesImports.AsNoTracking();
        if (filter.LocationId is { } locationId)
        {
            query = query.Where(i => i.LocationId == locationId);
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(i => visible.Contains(i.LocationId));
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(i => i.BusinessDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(i => i.BusinessDate <= to);
        }

        if (filter.Status is { } status)
        {
            query = query.Where(i => i.Status == status);
        }

        if (filter.Source is { } source)
        {
            query = query.Where(i => i.Source == source);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(i => i.BusinessDate).ThenBy(i => i.LocationId)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(i => new
            {
                Import = i,
                Unmapped = i.Lines.Count(l => l.MenuItemId == null),
                RunId = db.Runs.Where(r => r.ImportId == i.Id).Select(r => (long?)r.Id).FirstOrDefault(),
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = new List<SalesImportDto>(rows.Count);
        foreach (var row in rows)
        {
            items.Add(await MapImportAsync(row.Import, row.Unmapped, row.RunId, cancellationToken).ConfigureAwait(false));
        }

        return new PagedResult<SalesImportDto>(items, page.Page, page.Size, total);
    }

    public async Task<SalesImportDetailDto?> GetSalesImportAsync(long importId, DateOnly effectiveDate, CancellationToken cancellationToken)
    {
        var import = await db.SalesImports.AsNoTracking().Include(i => i.Lines)
            .FirstOrDefaultAsync(i => i.Id == importId, cancellationToken)
            .ConfigureAwait(false);
        if (import is null)
        {
            return null;
        }

        var date = import.BusinessDate;
        var withRecipe = await db.Recipes.AsNoTracking()
            .Where(r => r.Status != RecipeStatus.Draft && r.ValidFrom <= date && (r.ValidTo == null || r.ValidTo >= date))
            .Select(r => r.MenuItemId)
            .Distinct()
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var menuItemIds = import.Lines.Where(l => l.MenuItemId is not null).Select(l => l.MenuItemId!.Value).Distinct().ToList();
        var names = menuItemIds.Count == 0
            ? new Dictionary<uint, string>()
            : await db.MenuItems.AsNoTracking().Where(m => menuItemIds.Contains(m.Id)).ToDictionaryAsync(m => m.Id, m => m.Name, cancellationToken).ConfigureAwait(false);

        var lines = import.Lines
            .OrderBy(l => l.Id)
            .Select(l => new SalesLineDto(
                l.Id,
                l.MenuItemId,
                l.MenuItemId is { } id ? names.GetValueOrDefault(id) : null,
                l.RawPosCode,
                l.MenuItemId is not null,
                l.MenuItemId is { } mapped && withRecipe.Contains(mapped),
                l.QtySold,
                l.GrossAmount))
            .ToList();

        var unmapped = lines.Count(l => !l.IsMapped || !l.HasRecipe);
        var runId = await db.Runs.AsNoTracking().Where(r => r.ImportId == import.Id).Select(r => (long?)r.Id).FirstOrDefaultAsync(cancellationToken).ConfigureAwait(false);
        var header = await MapImportAsync(import, unmapped, runId, cancellationToken).ConfigureAwait(false);

        return new SalesImportDetailDto(
            header.Id, header.LocationId, header.LocationName, header.BusinessDate, header.Source, header.ExternalRef,
            header.Status, header.LineCount, header.UnmappedCount, header.GrossAmount, header.ImportedAt,
            header.ConsumptionRunId, header.RowVersion, lines);
    }

    public async Task<PagedResult<ConsumptionRunDto>> GetRunsAsync(ConsumptionRunFilter filter, PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);
        ArgumentNullException.ThrowIfNull(page);

        var query = db.Runs.AsNoTracking();
        if (filter.LocationId is { } locationId)
        {
            query = query.Where(r => r.LocationId == locationId);
        }

        if (filter.VisibleLocations.IsRestricted)
        {
            var visible = filter.VisibleLocations.VisibleIds;
            query = query.Where(r => visible.Contains(r.LocationId));
        }

        if (filter.DateFrom is { } from)
        {
            query = query.Where(r => r.BusinessDate >= from);
        }

        if (filter.DateTo is { } to)
        {
            query = query.Where(r => r.BusinessDate <= to);
        }

        if (filter.Status is { } status)
        {
            query = query.Where(r => r.Status == status);
        }

        if (filter.HasShortfall is { } hasShortfall)
        {
            query = hasShortfall ? query.Where(r => r.ShortfallCount > 0) : query.Where(r => r.ShortfallCount == 0);
        }

        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var rows = await query
            .OrderByDescending(r => r.BusinessDate).ThenBy(r => r.LocationId)
            .Skip(page.Skip)
            .Take(page.Size)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        var items = new List<ConsumptionRunDto>(rows.Count);
        foreach (var run in rows)
        {
            items.Add(await MapRunAsync(run, cancellationToken).ConfigureAwait(false));
        }

        return new PagedResult<ConsumptionRunDto>(items, page.Page, page.Size, total);
    }

    public async Task<ConsumptionRunDetailDto?> GetRunAsync(long runId, bool includeCost, CancellationToken cancellationToken)
    {
        var run = await db.Runs.AsNoTracking().Include(r => r.Lines)
            .FirstOrDefaultAsync(r => r.Id == runId, cancellationToken)
            .ConfigureAwait(false);
        if (run is null)
        {
            return null;
        }

        var header = await MapRunAsync(run, cancellationToken).ConfigureAwait(false);
        var lines = new List<ConsumptionRunLineDto>(run.Lines.Count);
        decimal? totalCost = includeCost ? 0m : null;

        foreach (var line in run.Lines.OrderBy(l => l.ProductId))
        {
            var product = await products.GetAsync(line.ProductId, cancellationToken).ConfigureAwait(false);
            decimal? costAmount = includeCost && line.UnitCost is { } unitCost
                ? Quantity.Round(line.PostedQtyBase * unitCost, Money.StorageDecimals)
                : null;
            if (includeCost && costAmount is { } amount)
            {
                totalCost += amount;
            }

            lines.Add(new ConsumptionRunLineDto(
                line.ProductId,
                product?.Sku ?? string.Empty,
                product?.Name ?? string.Empty,
                line.TheoreticalQtyBase,
                line.PostedQtyBase,
                line.ShortfallQtyBase,
                line.BaseUomId,
                product?.BaseUomCode ?? string.Empty,
                includeCost ? line.UnitCost : null,
                costAmount));
        }

        return new ConsumptionRunDetailDto(
            header.Id, header.DocNo, header.LocationId, header.LocationName, header.BusinessDate, header.SalesImportId,
            header.Status, header.MovementGroupId, header.ShortfallCount, header.UnmappedCount, header.FailureReason,
            header.CalculatedAt, header.PostedAt, header.RowVersion, lines, totalCost);
    }

    public async Task<IReadOnlyList<(uint MenuItemId, string MenuItemName, decimal PortionsSold)>> GetPortionsSoldAsync(
        uint? locationId,
        uint? menuItemId,
        DateOnly periodFrom,
        DateOnly periodTo,
        CancellationToken cancellationToken)
    {
        var query = from line in db.SalesLines.AsNoTracking()
                    join import in db.SalesImports.AsNoTracking() on line.ImportId equals import.Id
                    where import.BusinessDate >= periodFrom
                          && import.BusinessDate <= periodTo
                          && import.Status == SalesImportStatus.Consumed
                          && line.MenuItemId != null
                          && (locationId == null || import.LocationId == locationId)
                          && (menuItemId == null || line.MenuItemId == menuItemId)
                    group line by line.MenuItemId!.Value into g
                    select new { MenuItemId = g.Key, PortionsSold = g.Sum(l => l.QtySold) };

        var rows = await query.ToListAsync(cancellationToken).ConfigureAwait(false);
        if (rows.Count == 0)
        {
            return [];
        }

        var ids = rows.Select(r => r.MenuItemId).ToList();
        var names = await db.MenuItems.AsNoTracking()
            .Where(m => ids.Contains(m.Id))
            .ToDictionaryAsync(m => m.Id, m => m.Name, cancellationToken)
            .ConfigureAwait(false);

        return rows
            .Select(r => (r.MenuItemId, names.GetValueOrDefault(r.MenuItemId) ?? string.Empty, r.PortionsSold))
            .OrderBy(r => r.MenuItemId)
            .ToList();
    }

    public async Task<IReadOnlyDictionary<(uint LocationId, uint ProductId), decimal>> GetTheoreticalConsumptionAsync(
        uint? locationId,
        uint? productId,
        DateOnly periodFrom,
        DateOnly periodTo,
        CancellationToken cancellationToken)
    {
        var query = from line in db.RunLines.AsNoTracking()
                    join run in db.Runs.AsNoTracking() on line.RunId equals run.Id
                    where run.BusinessDate >= periodFrom
                          && run.BusinessDate <= periodTo
                          && run.Status == ConsumptionRunStatus.Posted
                          && (locationId == null || run.LocationId == locationId)
                          && (productId == null || line.ProductId == productId)
                    group line by new { run.LocationId, line.ProductId } into g
                    select new { g.Key.LocationId, g.Key.ProductId, Qty = g.Sum(l => l.TheoreticalQtyBase) };

        var rows = await query.ToListAsync(cancellationToken).ConfigureAwait(false);
        return rows.ToDictionary(r => (r.LocationId, r.ProductId), r => r.Qty);
    }

    private static MenuItemDto Map(MenuItem item, uint? activeRecipeId) => new(
        item.Id,
        item.Code,
        item.PosCode,
        item.Name,
        item.Category,
        item.IsSubRecipe,
        item.IsActive,
        activeRecipeId,
        item.RowVersion,
        new AuditDto(item.CreatedAt, item.CreatedBy, item.UpdatedAt, item.UpdatedBy, item.RowVersion));

    private async Task<IReadOnlyList<RecipeSummaryDto>> LoadSummariesAsync(
        System.Linq.Expressions.Expression<Func<Recipe, bool>> predicate,
        CancellationToken cancellationToken)
    {
        var rows = await db.Recipes.AsNoTracking()
            .Where(predicate)
            .OrderByDescending(r => r.ValidFrom).ThenByDescending(r => r.VersionNo)
            .Select(r => new
            {
                r.Id,
                r.MenuItemId,
                r.VersionNo,
                r.Status,
                r.ValidFrom,
                r.ValidTo,
                LineCount = r.Lines.Count,
                MenuItemName = db.MenuItems.Where(m => m.Id == r.MenuItemId).Select(m => m.Name).FirstOrDefault(),
            })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rows
            .Select(r => new RecipeSummaryDto(
                r.Id, r.MenuItemId, r.MenuItemName ?? string.Empty, r.VersionNo,
                UpperSnakeCaseEnum.Format(r.Status), r.ValidFrom, r.ValidTo, r.LineCount))
            .ToList();
    }

    private async Task<SalesImportDto> MapImportAsync(SalesImport import, int unmappedCount, long? runId, CancellationToken cancellationToken)
    {
        var location = await locations.GetAsync(import.LocationId, cancellationToken).ConfigureAwait(false);
        return new SalesImportDto(
            import.Id,
            import.LocationId,
            location?.Name ?? string.Empty,
            import.BusinessDate,
            UpperSnakeCaseEnum.Format(import.Source),
            import.ExternalRef,
            UpperSnakeCaseEnum.Format(import.Status),
            import.LineCount,
            unmappedCount,
            import.GrossAmount,
            import.ImportedAt,
            runId,
            import.RowVersion);
    }

    private async Task<ConsumptionRunDto> MapRunAsync(ConsumptionRun run, CancellationToken cancellationToken)
    {
        var location = await locations.GetAsync(run.LocationId, cancellationToken).ConfigureAwait(false);
        return new ConsumptionRunDto(
            run.Id,
            run.DocNo,
            run.LocationId,
            location?.Name ?? string.Empty,
            run.BusinessDate,
            run.ImportId,
            UpperSnakeCaseEnum.Format(run.Status),
            run.MovementGroupId,
            run.ShortfallCount,
            run.UnmappedCount,
            run.FailureReason,
            run.CalculatedAt,
            run.PostedAt,
            run.RowVersion);
    }
}
