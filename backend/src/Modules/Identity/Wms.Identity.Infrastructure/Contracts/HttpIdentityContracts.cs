using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using Wms.Identity.Contracts;

namespace Wms.Identity.Infrastructure.Contracts;

/// <summary>HTTP implementation used when Identity runs in another container (<c>ModuleTransport=Http</c>).</summary>
public sealed class HttpPermissionChecker(HttpClient httpClient) : IPermissionChecker
{
    public async Task<bool> HasPermissionAsync(uint userId, string permission, CancellationToken cancellationToken)
    {
        var permissions = await GetPermissionsAsync(userId, cancellationToken).ConfigureAwait(false);
        return permissions.Contains(permission);
    }

    public async Task<IReadOnlyCollection<string>> GetPermissionsAsync(uint userId, CancellationToken cancellationToken)
    {
        var url = IdentityRoutes.InternalPermissions
            .Replace("{userId}", userId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        var codes = await httpClient.GetFromJsonAsync<List<string>>(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        return codes is null ? [] : new HashSet<string>(codes, StringComparer.OrdinalIgnoreCase);
    }
}

public sealed class HttpTenantDirectory(HttpClient httpClient) : ITenantDirectory
{
    public async Task<TenantDto?> GetAsync(uint tenantId, CancellationToken cancellationToken)
    {
        var url = IdentityRoutes.InternalTenant
            .Replace("{tenantId}", tenantId.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal);
        using var response = await httpClient.GetAsync(new Uri(url, UriKind.Relative), cancellationToken).ConfigureAwait(false);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            return null;
        }

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<TenantDto>(cancellationToken).ConfigureAwait(false);
    }
}
