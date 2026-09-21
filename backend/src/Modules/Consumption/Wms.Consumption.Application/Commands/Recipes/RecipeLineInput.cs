using Wms.Consumption.Domain.Enums;

namespace Wms.Consumption.Application.Commands.Recipes;

/// <summary>Shape of <c>RecipeLineInput</c> in the contract; shared by create and update.</summary>
public sealed record RecipeComponentInput(
    ushort LineNo,
    ComponentType ComponentType,
    uint? ProductId,
    uint? SubMenuItemId,
    decimal QtyPerPortion,
    ushort UomId,
    decimal YieldPct,
    bool IsOptional,
    decimal AttachRatePct,
    string? Note);
