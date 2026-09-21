namespace Wms.Identity.Contracts;

/// <summary>Permission lookup backed by <c>iam_user_role</c> → <c>iam_role_permission</c> (spec §7, §16).</summary>
public interface IPermissionChecker
{
    Task<bool> HasPermissionAsync(uint userId, string permission, CancellationToken cancellationToken);

    Task<IReadOnlyCollection<string>> GetPermissionsAsync(uint userId, CancellationToken cancellationToken);
}
