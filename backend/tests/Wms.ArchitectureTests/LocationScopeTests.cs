using System.Reflection;
using Wms.Common.Application.Security;

namespace Wms.ArchitectureTests;

/// <summary>
/// Spec §16 — the location filter is applied at query-filter level, not in the endpoint.
/// </summary>
/// <remarks>
/// The filter used to be a bare <c>IReadOnlyCollection&lt;uint&gt;</c> whose empty value meant
/// "unrestricted", so the whole restriction was fail-open and a branch token listed the central
/// warehouses. Every filter record that reaches location-scoped data now has to carry a
/// <see cref="LocationScope"/>, which cannot be read as "everything" by accident. A new list endpoint that
/// forgets it fails here rather than leaking in production.
/// </remarks>
public sealed class LocationScopeTests
{
    /// <summary>
    /// The modules that own location-scoped transactional rows. MasterData's filters read the shared
    /// catalogue (products, locations, suppliers, rates) which every role needs in order to label a
    /// document — "issue from WH-01 to BR-NIZ" is unreadable without the WH-01 row — so the catalogue is
    /// deliberately tenant-wide. Procurement joined the list when the module grew past its single read
    /// endpoint: a requisition names the branch that raised it and a purchase order names the location it is
    /// delivered to, so both lists are location-scoped.
    /// </summary>
    private static readonly string[] StockModules =
    [
        "Wms.Inventory.Application",
        "Wms.Consumption.Application",
        "Wms.Reporting.Application",
        "Wms.Procurement.Application",
    ];

    /// <summary>Filters inside those modules that genuinely touch nothing location-scoped.</summary>
    private static readonly HashSet<string> NotLocationScoped = new(StringComparer.Ordinal)
    {
        "MenuItemFilter", // cons_menu_item — a recipe catalogue, tenant-wide by definition

        // proc_rfq and proc_quotation carry no location: a price enquiry is raised centrally and names
        // suppliers, not branches. Both endpoints demand proc.rfq.view / proc.quotation.view, which no branch
        // role holds, so there is neither a column to filter on nor a principal to filter for.
        "RfqFilter",
        "QuotationFilter",

        // proc_price_history is product x supplier cost data with no location column, and listPriceHistory
        // demands master.product.view_cost — spec §7.1 denies that to the keeper and the branch user outright.
        "PriceHistoryFilter",

        // rpt_export_job rows belong to the user who asked for them ("Mənim export işlərim"), so the filter is
        // scoped by requestedBy. The location scope that applies to the report DATA is frozen onto the job row
        // at creation time, because the worker that renders it has no HTTP principal (README §8.17).
        "ExportJobFilter",
    };

    public static TheoryData<string, string> Filters()
    {
        var data = new TheoryData<string, string>();
        foreach (var assembly in WmsAssemblies.All()
                     .Where(a => StockModules.Contains(a.GetName().Name, StringComparer.Ordinal)))
        {
            foreach (var type in assembly.GetTypes()
                         .Where(t => t.IsClass && t.Name.EndsWith("Filter", StringComparison.Ordinal) && t.IsPublic))
            {
                data.Add(assembly.GetName().Name!, type.FullName!);
            }
        }

        return data;
    }

    [Theory]
    [MemberData(nameof(Filters))]
    public void A_query_filter_carries_a_LocationScope_or_is_listed_as_exempt(string assemblyName, string typeName)
    {
        var type = WmsAssemblies.Get(assemblyName).GetType(typeName)!;
        if (NotLocationScoped.Contains(type.Name))
        {
            return;
        }

        var carries = type
            .GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .Any(p => p.PropertyType == typeof(LocationScope));

        Assert.True(
            carries,
            $"{typeName} feeds a list of location-scoped rows but carries no LocationScope. Add one (and apply "
            + "it in the query), or add the type to NotLocationScoped with a reason.");
    }

    [Fact]
    public void No_filter_still_carries_the_old_fail_open_collection()
    {
        var offenders = WmsAssemblies.All()
            .Where(a => StockModules.Contains(a.GetName().Name, StringComparer.Ordinal))
            .SelectMany(a => a.GetTypes())
            .Where(t => t.IsClass && t.Name.EndsWith("Filter", StringComparison.Ordinal))
            .SelectMany(t => t.GetProperties(BindingFlags.Public | BindingFlags.Instance)
                .Where(p => p.Name.Contains("LocationIds", StringComparison.Ordinal)
                    && p.PropertyType != typeof(LocationScope))
                .Select(p => $"{t.FullName}.{p.Name}"))
            .ToList();

        Assert.True(
            offenders.Count == 0,
            $"these properties are back to the fail-open shape: {string.Join(", ", offenders)}");
    }
}
