using Wms.Consumption.Application.Commands.Recipes;
using Wms.Consumption.Application.Commands.SalesImports;
using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Endpoints;

/// <summary>Query string of <c>GET /menu-items</c>.</summary>
public sealed record MenuItemsRequest(string? Search, bool? IsActive, bool? IsSubRecipe, bool? HasActiveRecipe, int? Page, int? Size);

/// <summary>Body of <c>POST /menu-items</c> (contract <c>MenuItemCreate</c>).</summary>
public sealed record MenuItemCreateRequest(string Code, string? PosCode, string Name, string? Category, bool? IsSubRecipe);

/// <summary>Body of <c>PUT /menu-items/{id}</c> (contract <c>MenuItemUpdate</c>).</summary>
public sealed record MenuItemUpdateRequest(
    string Code,
    string? PosCode,
    string Name,
    string? Category,
    bool? IsSubRecipe,
    bool? IsActive,
    uint RowVersion);

/// <summary>Contract <c>RecipeLineInput</c>. Defaults follow the contract: <c>yieldPct</c> and <c>attachRatePct</c> are 100.</summary>
public sealed record RecipeLineRequest(
    ushort LineNo,
    ComponentType ComponentType,
    uint? ProductId,
    uint? SubMenuItemId,
    decimal QtyPerPortion,
    ushort UomId,
    decimal? YieldPct,
    bool? IsOptional,
    decimal? AttachRatePct,
    string? Note)
{
    public RecipeComponentInput ToInput() => new(
        LineNo,
        ComponentType,
        ProductId,
        SubMenuItemId,
        QtyPerPortion,
        UomId,
        YieldPct ?? 100m,
        IsOptional ?? false,
        AttachRatePct ?? 100m,
        Note);
}

/// <summary>Body of <c>POST /menu-items/{id}/recipes</c> (contract <c>RecipeVersionCreate</c>).</summary>
public sealed record RecipeVersionCreateRequest(
    DateOnly ValidFrom,
    decimal? YieldPortions,
    uint? CopyFromRecipeId,
    string? Note,
    List<RecipeLineRequest>? Lines);

/// <summary>Body of <c>PUT /recipes/{id}</c> (contract <c>RecipeUpdate</c>).</summary>
public sealed record RecipeUpdateRequest(uint RowVersion, decimal? YieldPortions, string? Note, List<RecipeLineRequest>? Lines);

/// <summary>Body of <c>POST /recipes/{id}/activate</c> (contract <c>RecipeActivate</c>).</summary>
public sealed record RecipeActivateRequest(DateOnly ValidFrom, uint RowVersion);

/// <summary>Query string of <c>GET /recipes/{id}/explosion</c>.</summary>
public sealed record RecipeExplosionRequest(decimal? Portions, DateOnly? AsOfDate);

/// <summary>Contract <c>SalesLineInput</c>.</summary>
public sealed record SalesLineRequest(uint? MenuItemId, string? PosCode, decimal QtySold, decimal? GrossAmount)
{
    public SalesLineInput ToInput() => new(MenuItemId, PosCode, QtySold, GrossAmount);
}

/// <summary>Body of <c>POST /sales-imports</c> (contract <c>SalesImportCreate</c>).</summary>
public sealed record SalesImportCreateRequest(
    uint LocationId,
    DateOnly BusinessDate,
    SalesSource Source,
    string? ExternalRef,
    List<SalesLineRequest>? Lines);

/// <summary>Body of <c>PUT /sales-imports/{id}</c> (contract <c>SalesImportUpdate</c>).</summary>
public sealed record SalesImportUpdateRequest(uint RowVersion, List<SalesLineRequest>? Lines);

/// <summary>Query string of <c>GET /sales-imports</c>.</summary>
public sealed record SalesImportsRequest(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    SalesImportStatus? Status,
    SalesSource? Source,
    int? Page,
    int? Size);

/// <summary>Body of <c>POST /runs</c> (contract <c>ConsumptionRunCreate</c>).</summary>
public sealed record ConsumptionRunCreateRequest(long SalesImportId, bool? PostImmediately);

/// <summary>Query string of <c>GET /runs</c>.</summary>
public sealed record ConsumptionRunsRequest(
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    ConsumptionRunStatus? Status,
    bool? HasShortfall,
    int? Page,
    int? Size);

/// <summary>Contract <c>VersionedAction</c>.</summary>
public sealed record VersionedActionRequest(uint? RowVersion);

/// <summary>Contract <c>ReasonedAction</c>.</summary>
public sealed record ReasonedActionRequest(ushort ReasonCodeId, string? Note);

/// <summary>Query string of <c>GET /variance</c>.</summary>
public sealed record VarianceRequest(
    uint? LocationId,
    uint? ProductId,
    DateOnly PeriodFrom,
    DateOnly PeriodTo,
    decimal? MinAbsVariancePct,
    int? Page,
    int? Size);

/// <summary>Query string of <c>GET /portion-compliance</c>.</summary>
public sealed record PortionComplianceRequest(
    uint? LocationId,
    uint? MenuItemId,
    DateOnly PeriodFrom,
    DateOnly PeriodTo,
    int? Page,
    int? Size);
