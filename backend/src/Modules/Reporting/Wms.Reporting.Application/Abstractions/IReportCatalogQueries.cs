using Wms.Common.Application.Paging;

namespace Wms.Reporting.Application.Abstractions;

public sealed record ReportDefinitionDto(ushort Id, string Code, string Name, string Category, bool SupportsExcelExport);

public interface IReportCatalogQueries
{
    Task<PagedResult<ReportDefinitionDto>> GetReportsAsync(PageRequest page, CancellationToken cancellationToken);
}
