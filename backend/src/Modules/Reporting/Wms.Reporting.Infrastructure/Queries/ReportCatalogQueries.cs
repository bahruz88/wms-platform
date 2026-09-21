using Wms.Common.Application.Paging;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Infrastructure.Persistence;

namespace Wms.Reporting.Infrastructure.Queries;

public sealed class ReportCatalogQueries(ReportingDbContext db) : IReportCatalogQueries
{
    public async Task<PagedResult<ReportDefinitionDto>> GetReportsAsync(PageRequest page, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(page);
        var query = db.ReportDefinitions.AsNoTracking().Where(r => r.IsActive);
        var total = await query.LongCountAsync(cancellationToken).ConfigureAwait(false);
        var items = await query
            .OrderBy(r => r.Category).ThenBy(r => r.Code)
            .Skip(page.Skip)
            .Take(page.Size)
            .Select(r => new ReportDefinitionDto(r.Id, r.Code, r.Name, r.Category, r.SupportsExcelExport))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return new PagedResult<ReportDefinitionDto>(items, page.Page, page.Size, total);
    }
}
