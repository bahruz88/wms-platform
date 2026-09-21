namespace Wms.Consumption.Application.Dtos;

/// <summary>Mandatory audit columns of spec §6.2, shaped like <c>common.v1.yaml#/components/schemas/AuditFields</c>.</summary>
public sealed record AuditDto(DateTimeOffset CreatedAt, uint CreatedBy, DateTimeOffset? UpdatedAt, uint? UpdatedBy, uint RowVersion);

public sealed record MenuItemDto(
    uint Id,
    string Code,
    string? PosCode,
    string Name,
    string? Category,
    bool IsSubRecipe,
    bool IsActive,
    uint? ActiveRecipeId,
    uint RowVersion,
    AuditDto? Audit);

public sealed record MenuItemDetailDto(
    uint Id,
    string Code,
    string? PosCode,
    string Name,
    string? Category,
    bool IsSubRecipe,
    bool IsActive,
    uint? ActiveRecipeId,
    uint RowVersion,
    AuditDto? Audit,
    int RecipeVersionCount,
    IReadOnlyList<RecipeSummaryDto> UsedInRecipes);

public sealed record RecipeSummaryDto(
    uint Id,
    uint MenuItemId,
    string MenuItemName,
    ushort VersionNo,
    string Status,
    DateOnly ValidFrom,
    DateOnly? ValidTo,
    int LineCount);

public sealed record RecipeLineDto(
    ushort LineNo,
    string ComponentType,
    uint? ProductId,
    string? ProductSku,
    string? ProductName,
    uint? SubMenuItemId,
    string? SubMenuItemName,
    decimal QtyPerPortion,
    ushort UomId,
    string UomCode,
    decimal YieldPct,
    bool IsOptional,
    decimal AttachRatePct,
    string? Note);

public sealed record RecipeDto(
    uint Id,
    uint MenuItemId,
    string MenuItemName,
    ushort VersionNo,
    string Status,
    DateOnly ValidFrom,
    DateOnly? ValidTo,
    int LineCount,
    decimal YieldPortions,
    string? Note,
    IReadOnlyList<RecipeLineDto> Lines,
    uint RowVersion,
    AuditDto? Audit);

public sealed record RecipeExplosionLineDto(
    uint ProductId,
    string ProductSku,
    string ProductName,
    decimal RequiredQtyBase,
    ushort BaseUomId,
    string BaseUomCode,
    string? ViaSubRecipe,
    int Depth);

public sealed record RecipeExplosionDto(
    uint RecipeId,
    string MenuItemName,
    decimal Portions,
    int MaxDepth,
    IReadOnlyList<RecipeExplosionLineDto> Lines);

public sealed record SalesLineDto(
    long Id,
    uint? MenuItemId,
    string? MenuItemName,
    string? RawPosCode,
    bool IsMapped,
    bool HasRecipe,
    decimal QtySold,
    decimal? GrossAmount);

public sealed record SalesImportDto(
    long Id,
    uint LocationId,
    string LocationName,
    DateOnly BusinessDate,
    string Source,
    string? ExternalRef,
    string Status,
    int LineCount,
    int UnmappedCount,
    decimal? GrossAmount,
    DateTimeOffset ImportedAt,
    long? ConsumptionRunId,
    uint RowVersion);

public sealed record SalesImportDetailDto(
    long Id,
    uint LocationId,
    string LocationName,
    DateOnly BusinessDate,
    string Source,
    string? ExternalRef,
    string Status,
    int LineCount,
    int UnmappedCount,
    decimal? GrossAmount,
    DateTimeOffset ImportedAt,
    long? ConsumptionRunId,
    uint RowVersion,
    IReadOnlyList<SalesLineDto> Lines);

public sealed record CsvParseErrorDto(int RowNumber, string? RawLine, string Message);

public sealed record SalesImportParseResultDto(SalesImportDetailDto SalesImport, int ParsedRows, IReadOnlyList<CsvParseErrorDto> ParseErrors);

public sealed record ConsumptionRunLineDto(
    uint ProductId,
    string ProductSku,
    string ProductName,
    decimal TheoreticalQtyBase,
    decimal PostedQtyBase,
    decimal ShortfallQtyBase,
    ushort BaseUomId,
    string BaseUomCode,
    decimal? UnitCost,
    decimal? CostAmount);

public sealed record ConsumptionRunDto(
    long Id,
    string DocNo,
    uint LocationId,
    string LocationName,
    DateOnly BusinessDate,
    long SalesImportId,
    string Status,
    long? MovementGroupId,
    int ShortfallCount,
    int UnmappedCount,
    string? FailureReason,
    DateTimeOffset? CalculatedAt,
    DateTimeOffset? PostedAt,
    uint RowVersion);

public sealed record ConsumptionRunDetailDto(
    long Id,
    string DocNo,
    uint LocationId,
    string LocationName,
    DateOnly BusinessDate,
    long SalesImportId,
    string Status,
    long? MovementGroupId,
    int ShortfallCount,
    int UnmappedCount,
    string? FailureReason,
    DateTimeOffset? CalculatedAt,
    DateTimeOffset? PostedAt,
    uint RowVersion,
    IReadOnlyList<ConsumptionRunLineDto> Lines,
    decimal? TotalCostAmount);

public sealed record VarianceLineDto(
    uint ProductId,
    string ProductSku,
    string ProductName,
    uint LocationId,
    string LocationName,
    string BaseUomCode,
    decimal OpeningQty,
    decimal ReceivedQty,
    decimal TheoreticalConsumedQty,
    decimal WasteQty,
    decimal SampleQty,
    decimal TransferNetQty,
    decimal ExpectedQty,
    decimal CountedQty,
    decimal VarianceQty,
    decimal VariancePct,
    decimal? VarianceValue);

public sealed record VariancePageDto(
    IReadOnlyList<VarianceLineDto> Items,
    int Page,
    int Size,
    long Total,
    DateOnly PeriodFrom,
    DateOnly PeriodTo);

public sealed record PortionComplianceLineDto(
    uint MenuItemId,
    string MenuItemName,
    uint ProductId,
    string ProductName,
    string BaseUomCode,
    decimal PortionsSold,
    decimal RecipeQtyPerPortion,
    decimal ActualQtyPerPortion,
    decimal CompliancePct);
