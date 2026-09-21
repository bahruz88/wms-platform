using Microsoft.Extensions.DependencyInjection;
using Wms.Common.Application.DependencyInjection;

namespace Wms.Documents.Application;

public static class DocumentsApplicationExtensions
{
    public static IServiceCollection AddDocumentsApplication(this IServiceCollection services) =>
        services.AddWmsHandlersFromAssembly(typeof(DocumentsApplicationExtensions).Assembly);
}
