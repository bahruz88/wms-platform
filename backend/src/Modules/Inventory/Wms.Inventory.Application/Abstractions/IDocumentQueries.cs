using Wms.Common.Application.Paging;
using Wms.Inventory.Application.Dtos;
using Wms.Common.Application.Security;

namespace Wms.Inventory.Application.Abstractions;

/// <summary>
/// Shared filter of the document list endpoints. <c>VisibleLocations</c> carries the spec §16 location
/// restriction: a restricted scope with no ids matches nothing, it is never read as "every location".
/// </summary>
public sealed record DocumentFilter(
    string? Status,
    uint? LocationId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    string? Search,
    LocationScope VisibleLocations)
{
    /// <summary>Extra discriminators used by individual lists (issue type, supplier, product …).</summary>
    public string? Kind { get; init; }

    public uint? SecondaryLocationId { get; init; }

    public uint? SupplierId { get; init; }

    public uint? ProductId { get; init; }
}

public interface IStockRequestQueries
{
    Task<StockRequestDto?> GetAsync(long requestId, CancellationToken cancellationToken);

    Task<PagedResult<StockRequestSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken);
}

public interface IIssueQueries
{
    Task<IssueDto?> GetAsync(long issueId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<IssueSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken);
}

public interface IWasteQueries
{
    Task<WasteDto?> GetAsync(long wasteId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<WasteSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken);
}

public interface ISampleQueries
{
    Task<SampleDto?> GetAsync(long sampleId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<SampleSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, CancellationToken cancellationToken);
}

public interface IReturnToVendorQueries
{
    Task<ReturnToVendorDto?> GetAsync(long returnId, bool includeCost, CancellationToken cancellationToken);

    Task<PagedResult<ReturnToVendorSummaryDto>> ListAsync(DocumentFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken);
}

/// <summary>
/// Filters of <c>GET /inventory/batches</c>. A batch row itself carries no location, but the DTO breaks the
/// quantity down per location, so the spec §16 scope still applies: a restricted principal sees only the
/// batches that sit in one of its own locations, and only those locations in the breakdown.
/// </summary>
public sealed record BatchFilter(
    uint? ProductId,
    uint? SupplierId,
    string? Status,
    DateOnly? ExpiryBefore,
    string? BatchNo,
    LocationScope VisibleLocations);

public interface IBatchQueries
{
    Task<BatchDto?> GetAsync(long batchId, LocationScope visibleLocations, CancellationToken cancellationToken);

    Task<PagedResult<BatchDto>> ListAsync(BatchFilter filter, PageRequest page, CancellationToken cancellationToken);
}

/// <summary>Filters of <c>GET /inventory/movements</c>.</summary>
public sealed record MovementFilter(
    uint? ProductId,
    uint? LocationId,
    long? BatchId,
    string? DocType,
    long? GroupId,
    DateOnly? DateFrom,
    DateOnly? DateTo,
    LocationScope VisibleLocations);

public interface IMovementQueries
{
    Task<PagedResult<MovementDto>> ListAsync(MovementFilter filter, PageRequest page, bool includeCost, CancellationToken cancellationToken);

    Task<MovementGroupDto?> GetGroupAsync(long groupId, bool includeCost, CancellationToken cancellationToken);
}
