using Wms.Common.Application.Abstractions;

namespace Wms.MasterData.Application;

/// <summary>
/// Spec §16 / CONVENTIONS: a cost or price field is <b>omitted</b> from the response for a principal without
/// <c>master.product.view_cost</c> — never sent as <c>null</c>-masked or zeroed data, and never rendered by the
/// client. The host configures <c>JsonIgnoreCondition.WhenWritingNull</c>, so a nullable DTO property set to
/// <c>null</c> here does not appear in the payload at all.
/// <para>
/// MasterData itself stores no cost column: <c>masterdata.v1.yaml</c> states that cost-bearing fields live in
/// Inventory/Reporting responses. This gate exists so the first MasterData field that carries one is a single
/// <see cref="Gate{T}(bool, T?)"/> call away from being correct.
/// </para>
/// </summary>
public static class CostFieldVisibility
{
    public static bool CanViewCost(ICurrentUser currentUser)
    {
        ArgumentNullException.ThrowIfNull(currentUser);
        return currentUser.HasPermission(MasterDataPermissions.ProductViewCost);
    }

    /// <summary>Returns <paramref name="value"/> when the principal may see costs, otherwise <c>null</c> (⇒ omitted).</summary>
    public static T? Gate<T>(bool canViewCost, T? value)
        where T : struct
        => canViewCost ? value : null;

    /// <summary>Reference-typed overload (e.g. a Money DTO).</summary>
    public static T? GateRef<T>(bool canViewCost, T? value)
        where T : class
        => canViewCost ? value : null;
}
