using Wms.Common.Application.Security;

namespace Wms.Common.Application.Abstractions;

/// <summary>Current principal: Keycloak claims joined with the <c>iam</c> row they resolve to (spec §7, §16).</summary>
public interface ICurrentUser
{
    bool IsAuthenticated { get; }

    /// <summary>Internal <c>iam_user.id</c> (0 when not resolved, e.g. background jobs).</summary>
    uint UserId { get; }

    /// <summary>Keycloak subject (<c>sub</c> claim).</summary>
    string ExternalId { get; }

    string Username { get; }

    string FullName { get; }

    IReadOnlyCollection<string> Roles { get; }

    /// <summary>Effective permission codes (<c>iam_role_permission</c>).</summary>
    IReadOnlyCollection<string> Permissions { get; }

    /// <summary>
    /// Which physical locations this principal may see (spec §16). An empty <b>restricted</b> scope means no
    /// locations at all — it is never read as "everything".
    /// </summary>
    LocationScope LocationScope { get; }

    /// <summary>Rows of <c>iam_user_location</c>; see <see cref="LocationScope"/> for how they are applied.</summary>
    IReadOnlyCollection<uint> LocationIds { get; }

    bool HasPermission(string permission);
}
