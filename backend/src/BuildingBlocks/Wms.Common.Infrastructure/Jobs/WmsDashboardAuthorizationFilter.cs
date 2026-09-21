using Hangfire;
using Hangfire.Dashboard;
using Wms.Common.Infrastructure.Tenancy;

namespace Wms.Common.Infrastructure.Jobs;

/// <summary>Hangfire dashboard: open in Development, ADMIN role otherwise.</summary>
public sealed class WmsDashboardAuthorizationFilter(bool allowAnonymous) : IDashboardAuthorizationFilter
{
    public bool Authorize(DashboardContext context)
    {
        ArgumentNullException.ThrowIfNull(context);
        if (allowAnonymous)
        {
            return true;
        }

        var user = context.GetHttpContext().User;
        return user.Identity?.IsAuthenticated == true
            && (user.IsInRole(RolePermissionMap.Admin) || user.HasClaim(c => c.Type == ClaimNames.Roles && c.Value == RolePermissionMap.Admin));
    }
}
