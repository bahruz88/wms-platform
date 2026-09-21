namespace Wms.Common.Application.Abstractions;

/// <summary>Current principal resolved from Keycloak claims (spec §16).</summary>
public interface ICurrentUser
{
    bool IsAuthenticated { get; }

    /// <summary>Internal <c>iam_user.id</c> (0 when not resolved, e.g. background jobs).</summary>
    uint UserId { get; }

    /// <summary>Keycloak subject (<c>sub</c> claim).</summary>
    string ExternalId { get; }

    string Username { get; }

    IReadOnlyCollection<string> Roles { get; }

    /// <summary>Locations visible to a branch user (<c>iam_user_location</c>). Empty = unrestricted.</summary>
    IReadOnlyCollection<uint> LocationIds { get; }

    bool HasPermission(string permission);
}
