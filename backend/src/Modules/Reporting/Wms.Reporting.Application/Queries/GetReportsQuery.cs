using Wms.Common.Application.Messaging;
using Wms.Common.Application.Paging;
using Wms.Common.Domain;
using Wms.Reporting.Application.Abstractions;

namespace Wms.Reporting.Application.Queries;

/// <summary><c>GET /api/v1/reporting/reports</c> — the report catalogue (TOR §29).</summary>
public sealed record GetReportsQuery(PageRequest Page) : IQuery<PagedResult<ReportDefinitionDto>>;

public sealed class GetReportsQueryHandler(IReportCatalogQueries queries) : IQueryHandler<GetReportsQuery, PagedResult<ReportDefinitionDto>>
{
    public async Task<Result<PagedResult<ReportDefinitionDto>>> HandleAsync(GetReportsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return await queries.GetReportsAsync(query.Page, cancellationToken).ConfigureAwait(false);
    }
}
