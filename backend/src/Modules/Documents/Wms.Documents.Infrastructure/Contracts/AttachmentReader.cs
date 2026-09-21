using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using Wms.Documents.Application.Abstractions;
using Wms.Documents.Contracts;

namespace Wms.Documents.Infrastructure.Contracts;

/// <summary>In-process <see cref="IAttachmentReader"/>.</summary>
public sealed class AttachmentReader(IAttachmentQueries queries) : IAttachmentReader
{
    public Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken) =>
        queries.GetAsync(attachmentId, cancellationToken);
}

/// <summary>HTTP implementation used when Documents runs in another container (<c>ModuleTransport=Http</c>).</summary>
public sealed class HttpAttachmentReader(HttpClient httpClient) : IAttachmentReader
{
    public async Task<AttachmentDto?> GetAsync(long attachmentId, CancellationToken cancellationToken)
    {
        var url = DocumentsRoutes.InternalAttachment
            .Replace("{attachmentId}", attachmentId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AttachmentDto>(cancellationToken).ConfigureAwait(false);
    }
}
