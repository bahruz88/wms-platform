using System.Reflection;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Tenancy;
using Wms.Identity.Domain;

namespace Wms.ArchitectureTests;

/// <summary>
/// Spec §16: authorization is permission based and the effective set is read from <c>iam_role_permission</c>.
/// That only works if three lists stay in step — the codes the endpoints demand, the catalogue the seeder
/// writes into <c>iam_permission</c>, and the bootstrap map that fills a fresh database. ADR-001 forbids
/// BuildingBlocks from referencing the Identity module, so the bootstrap map has to duplicate the grants;
/// these tests are what stops the duplicate from drifting.
/// </summary>
public sealed class PermissionCatalogConsistencyTests
{
    /// <summary>Every code a <c>.RequirePermission(...)</c> can demand, collected from the module constant classes.</summary>
    public static TheoryData<string, string> DeclaredPermissionCodes()
    {
        var data = new TheoryData<string, string>();
        foreach (var (owner, code) in CollectDeclaredCodes())
        {
            data.Add(owner, code);
        }

        return data;
    }

    [Theory]
    [MemberData(nameof(DeclaredPermissionCodes))]
    public void Every_permission_a_module_declares_exists_in_the_catalogue(string owner, string code) =>
        Assert.True(
            PermissionCatalog.Codes.Contains(code),
            $"{owner} declares permission '{code}', which is missing from PermissionCatalog.All — "
            + "no role could ever be granted it, so every endpoint using it would answer 403.");

    [Fact]
    public void The_bootstrap_map_and_the_identity_catalogue_grant_exactly_the_same_patterns()
    {
        foreach (var role in SystemRoles.All)
        {
            var bootstrap = RolePermissionMap.Patterns(role);
            var catalogue = PermissionCatalog.DefaultRoleGrants[role];

            Assert.Equal(catalogue, bootstrap);
        }

        Assert.Equal(
            SystemRoles.All.Order(StringComparer.Ordinal),
            RolePermissionMap.Roles.Order(StringComparer.Ordinal));
        Assert.Equal(
            SystemRoles.All.Order(StringComparer.Ordinal),
            PermissionCatalog.DefaultRoleGrants.Keys.Order(StringComparer.Ordinal));
    }

    [Fact]
    public void The_platform_and_the_catalogue_agree_on_the_view_all_locations_code() =>
        Assert.Equal(Wms.Common.Application.Security.WmsPermissions.ViewAllLocations, PermissionCatalog.ViewAllLocations);

    [Fact]
    public void The_platform_and_the_catalogue_agree_on_the_cost_permission_code() =>
        Assert.Equal(SystemPermissions.ProductViewCost, PermissionCatalog.ProductViewCost);

    [Fact]
    public void Internal_paths_are_matched_on_whole_segments()
    {
        Assert.True(InternalApi.IsInternalPath("/api/v1/masterdata/internal/products"));
        Assert.True(InternalApi.IsInternalPath("/api/v1/inventory/internal/reversals"));
        Assert.True(InternalApi.IsInternalPath("/API/V1/IDENTITY/INTERNAL/tenants/1"));

        // A resource whose name merely contains "internal" is public and must not be swept up.
        Assert.False(InternalApi.IsInternalPath("/api/v1/masterdata/products/internal-code"));
        Assert.False(InternalApi.IsInternalPath("/api/v1/inventory/balances"));
        Assert.False(InternalApi.IsInternalPath("/health/live"));
    }

    [Fact]
    public void The_internal_secret_is_compared_as_a_whole_and_never_matches_when_unset()
    {
        Assert.True(InternalApi.Matches("s3cret", "s3cret"));
        Assert.False(InternalApi.Matches("s3cret", "s3cre"));
        Assert.False(InternalApi.Matches("s3cret", "S3CRET"));

        // Fail closed: with no configured key nothing is accepted, so a host that forgot the setting
        // refuses every internal call instead of serving them to anyone.
        Assert.False(InternalApi.Matches(null, "s3cret"));
        Assert.False(InternalApi.Matches("", "s3cret"));
        Assert.False(InternalApi.Matches("s3cret", null));
    }

    private static IEnumerable<(string Owner, string Code)> CollectDeclaredCodes()
    {
        foreach (var assembly in WmsAssemblies.All().Where(a => a.GetName().Name?.EndsWith(".Application", StringComparison.Ordinal) == true))
        {
            foreach (var type in assembly.GetTypes().Where(t => t.IsAbstract && t.IsSealed && t.Name.EndsWith("Permissions", StringComparison.Ordinal)))
            {
                foreach (var field in type.GetFields(BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy))
                {
                    if (field is { IsLiteral: true, IsInitOnly: false } && field.FieldType == typeof(string)
                        && field.GetRawConstantValue() is string code
                        && code.Contains('.', StringComparison.Ordinal))
                    {
                        yield return (type.FullName ?? type.Name, code);
                    }
                }
            }
        }
    }
}
