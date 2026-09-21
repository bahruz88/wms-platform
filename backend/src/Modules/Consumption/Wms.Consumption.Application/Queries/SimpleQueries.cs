using FluentValidation;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Consumption.Application.Abstractions;
using Wms.Consumption.Application.Dtos;
using Wms.Consumption.Domain;

namespace Wms.Consumption.Application.Queries;

/// <summary><c>GET /menu-items</c> (operationId <c>listMenuItems</c>). Ordered by the Azerbaijani sort key.</summary>
public sealed record GetMenuItemsQuery(string? Search, bool? IsActive, bool? IsSubRecipe, bool? HasActiveRecipe, PageRequest Page)
    : IQuery<PagedResult<MenuItemDto>>;

public sealed class GetMenuItemsQueryHandler(IConsumptionQueries queries, IClock clock)
    : IQueryHandler<GetMenuItemsQuery, PagedResult<MenuItemDto>>
{
    public async Task<Result<PagedResult<MenuItemDto>>> HandleAsync(GetMenuItemsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new MenuItemFilter(query.Search, query.IsActive, query.IsSubRecipe, query.HasActiveRecipe);
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        return await queries.GetMenuItemsAsync(filter, query.Page, today, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /menu-items/{id}</c> (operationId <c>getMenuItem</c>).</summary>
public sealed record GetMenuItemQuery(uint MenuItemId) : IQuery<MenuItemDetailDto>;

public sealed class GetMenuItemQueryHandler(IConsumptionQueries queries, IClock clock)
    : IQueryHandler<GetMenuItemQuery, MenuItemDetailDto>
{
    public async Task<Result<MenuItemDetailDto>> HandleAsync(GetMenuItemQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var dto = await queries.GetMenuItemAsync(query.MenuItemId, today, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.MenuItemNotFound(query.MenuItemId) : Result.Success(dto);
    }
}

/// <summary><c>GET /menu-items/{id}/recipes</c> (operationId <c>listRecipeVersions</c>).</summary>
public sealed record GetRecipeVersionsQuery(uint MenuItemId) : IQuery<IReadOnlyList<RecipeSummaryDto>>;

public sealed class GetRecipeVersionsQueryHandler(IConsumptionQueries queries)
    : IQueryHandler<GetRecipeVersionsQuery, IReadOnlyList<RecipeSummaryDto>>
{
    public async Task<Result<IReadOnlyList<RecipeSummaryDto>>> HandleAsync(GetRecipeVersionsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return Result.Success(await queries.GetRecipeVersionsAsync(query.MenuItemId, cancellationToken).ConfigureAwait(false));
    }
}

/// <summary><c>GET /recipes/{id}</c> (operationId <c>getRecipe</c>).</summary>
public sealed record GetRecipeQuery(uint RecipeId) : IQuery<RecipeDto>;

public sealed class GetRecipeQueryHandler(IConsumptionQueries queries) : IQueryHandler<GetRecipeQuery, RecipeDto>
{
    public async Task<Result<RecipeDto>> HandleAsync(GetRecipeQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var dto = await queries.GetRecipeAsync(query.RecipeId, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RecipeNotFound(query.RecipeId) : Result.Success(dto);
    }
}

/// <summary><c>GET /sales-imports</c> (operationId <c>listSalesImports</c>). A branch user only sees its own locations.</summary>
public sealed record GetSalesImportsQuery(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    Domain.Enums.SalesImportStatus? Status,
    Domain.Enums.SalesSource? Source,
    PageRequest Page) : IQuery<PagedResult<SalesImportDto>>;

public sealed class GetSalesImportsQueryHandler(IConsumptionQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetSalesImportsQuery, PagedResult<SalesImportDto>>
{
    public async Task<Result<PagedResult<SalesImportDto>>> HandleAsync(GetSalesImportsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new SalesImportFilter(query.LocationId, query.DateFrom, query.DateTo, query.Status, query.Source, currentUser.LocationIds);
        return await queries.GetSalesImportsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /sales-imports/{id}</c> (operationId <c>getSalesImport</c>).</summary>
public sealed record GetSalesImportQuery(long SalesImportId) : IQuery<SalesImportDetailDto>;

public sealed class GetSalesImportQueryHandler(IConsumptionQueries queries, IClock clock)
    : IQueryHandler<GetSalesImportQuery, SalesImportDetailDto>
{
    public async Task<Result<SalesImportDetailDto>> HandleAsync(GetSalesImportQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var today = DateOnly.FromDateTime(clock.UtcNow.UtcDateTime);
        var dto = await queries.GetSalesImportAsync(query.SalesImportId, today, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.SalesImportNotFound(query.SalesImportId) : Result.Success(dto);
    }
}

/// <summary><c>GET /runs</c> (operationId <c>listConsumptionRuns</c>).</summary>
public sealed record GetConsumptionRunsQuery(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    Domain.Enums.ConsumptionRunStatus? Status,
    bool? HasShortfall,
    PageRequest Page) : IQuery<PagedResult<ConsumptionRunDto>>;

public sealed class GetConsumptionRunsQueryHandler(IConsumptionQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetConsumptionRunsQuery, PagedResult<ConsumptionRunDto>>
{
    public async Task<Result<PagedResult<ConsumptionRunDto>>> HandleAsync(GetConsumptionRunsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var filter = new ConsumptionRunFilter(query.LocationId, query.DateFrom, query.DateTo, query.Status, query.HasShortfall, currentUser.LocationIds);
        return await queries.GetRunsAsync(filter, query.Page, cancellationToken).ConfigureAwait(false);
    }
}

/// <summary><c>GET /runs/{id}</c> (operationId <c>getConsumptionRun</c>). Cost fields need <c>master.product.view_cost</c>.</summary>
public sealed record GetConsumptionRunQuery(long RunId) : IQuery<ConsumptionRunDetailDto>;

public sealed class GetConsumptionRunQueryHandler(IConsumptionQueries queries, ICurrentUser currentUser)
    : IQueryHandler<GetConsumptionRunQuery, ConsumptionRunDetailDto>
{
    public async Task<Result<ConsumptionRunDetailDto>> HandleAsync(GetConsumptionRunQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var includeCost = currentUser.HasPermission(ConsumptionPermissions.ViewCost);
        var dto = await queries.GetRunAsync(query.RunId, includeCost, cancellationToken).ConfigureAwait(false);
        return dto is null ? ConsumptionErrors.RunNotFound(query.RunId) : Result.Success(dto);
    }
}

public sealed class GetMenuItemsQueryValidator : AbstractValidator<GetMenuItemsQuery>
{
    public GetMenuItemsQueryValidator() => RuleFor(q => q.Page).NotNull();
}
