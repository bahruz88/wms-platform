namespace Wms.Inventory.Application.Dtos;

/// <summary><c>CountSummary</c> of inventory.v1.yaml — the list-page row.</summary>
public sealed record CountSummaryDto(
    long Id,
    string DocNo,
    LocationRefDto Location,
    string CountType,
    string Status,
    DateTimeOffset? FrozenAt,
    bool RequiresApproval,
    int LineCount,
    int CountedLineCount,
    int VarianceLineCount,
    uint RowVersion);

/// <summary><c>CountLine</c> of inventory.v1.yaml. <c>VarianceValue</c> is null without <c>master.product.view_cost</c>.</summary>
public sealed record CountLineDto(
    long Id,
    ProductRefDto Product,
    BatchRefDto? Batch,
    decimal BookQty,
    string BaseUomCode,
    decimal? CountedQty,
    decimal? VarianceQty,
    decimal? VariancePct,
    decimal? VarianceValue,
    bool ExceedsThreshold,
    ushort? ReasonCodeId,
    string? Note,
    uint? CountedBy,
    DateTimeOffset? CountedAt);

/// <summary><c>Count</c> of inventory.v1.yaml — summary plus lines and audit.</summary>
public sealed record CountDto(
    long Id,
    string DocNo,
    LocationRefDto Location,
    string CountType,
    string Status,
    DateTimeOffset? FrozenAt,
    bool RequiresApproval,
    int LineCount,
    int CountedLineCount,
    int VarianceLineCount,
    uint RowVersion,
    uint? ApprovedBy,
    DateTimeOffset? ApprovedAt,
    long? AdjustGroupId,
    decimal? TotalVarianceValue,
    string? Note,
    IReadOnlyList<CountLineDto> Lines,
    AuditFieldsDto Audit);
