namespace Wms.Common.Application.Abstractions;

/// <summary>What the bearer token says about the caller, before the <c>iam</c> schema is consulted.</summary>
/// <param name="TenantId">From the mandatory <c>tenant_id</c> claim.</param>
/// <param name="ExternalId">Keycloak <c>sub</c> — the natural key of <c>iam_user.external_id</c>.</param>
/// <param name="Username">Keycloak <c>preferred_username</c>.</param>
/// <param name="FullName">Keycloak <c>name</c>, falling back to the username.</param>
/// <param name="Email">Keycloak <c>email</c>, if the token carries one.</param>
/// <param name="RealmRoles">Keycloak <c>realm_access.roles</c> — mirrored into <c>iam_user_role</c> on first sight.</param>
public sealed record PrincipalClaims(
    uint TenantId,
    string ExternalId,
    string Username,
    string FullName,
    string? Email,
    IReadOnlyList<string> RealmRoles);

/// <summary>
/// The caller as the <c>iam</c> schema knows them. Produced once per request by the principal resolution
/// middleware and read synchronously afterwards through <see cref="ICurrentUser"/>.
/// </summary>
/// <param name="UserId">The real <c>iam_user.id</c> — what lands in <c>created_by</c>, <c>posted_by</c>,
/// <c>approved_by</c>, <c>uploaded_by</c> and <c>common_audit_log.user_id</c>.</param>
/// <param name="Permissions">Effective permission codes from <c>iam_user_role</c> → <c>iam_role_permission</c>.</param>
/// <param name="LocationIds">Rows of <c>iam_user_location</c>. Meaningful only together with the
/// <c>inv.location.view_all</c> permission: without it the principal sees exactly these locations and no others.</param>
public sealed record PrincipalSnapshot(
    uint UserId,
    uint TenantId,
    string ExternalId,
    string Username,
    string FullName,
    string? Email,
    IReadOnlyList<string> Roles,
    IReadOnlyList<string> Permissions,
    IReadOnlyList<uint> LocationIds,
    bool IsActive);

/// <summary>
/// Resolves a bearer token to its <c>iam_user</c> row, provisioning the row on first sight (spec §7).
/// Implemented in the Identity module; other processes reach it over the internal module transport.
/// </summary>
public interface IPrincipalDirectory
{
    /// <summary>
    /// Returns the caller's <c>iam</c> record, creating <c>iam_user</c> (and mirroring the realm roles into
    /// <c>iam_user_role</c>) when the Keycloak subject is seen for the first time.
    /// </summary>
    Task<PrincipalSnapshot?> ResolveAsync(PrincipalClaims claims, CancellationToken cancellationToken);
}

/// <summary>
/// Short-lived cache of <see cref="PrincipalSnapshot"/> so that a permission/location lookup does not cost a
/// database round-trip (or, in <c>ModuleTransport=Http</c> deployments, an inter-module call) on every request.
/// Identity's write endpoints invalidate the entry so a role or location change takes effect immediately.
/// </summary>
public interface IPrincipalCache
{
    Task<PrincipalSnapshot?> GetAsync(uint tenantId, string externalId, CancellationToken cancellationToken);

    Task SetAsync(PrincipalSnapshot snapshot, CancellationToken cancellationToken);

    Task InvalidateAsync(uint tenantId, string externalId, CancellationToken cancellationToken);
}
