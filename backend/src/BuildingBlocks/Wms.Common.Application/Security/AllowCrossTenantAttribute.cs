namespace Wms.Common.Application.Security;

/// <summary>
/// Marks the only places where <c>IgnoreQueryFilters()</c> is allowed (spec §12.9). The justification
/// must explain how tenant isolation is still guaranteed (e.g. tenant_id bound in raw SQL).
/// </summary>
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, Inherited = false)]
public sealed class AllowCrossTenantAttribute(string justification) : Attribute
{
    public string Justification { get; } = justification;
}
