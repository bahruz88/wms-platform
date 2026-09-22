using System.Globalization;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.Common.Domain;
using Wms.Inventory.Contracts;
using Wms.Reporting.Application.Abstractions;
using Wms.Reporting.Application.Dtos;
using Wms.Reporting.Domain;
using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Infrastructure.Reports;

/// <summary>Rows of one report, keyed by column, before they are projected onto the visible column list.</summary>
internal sealed record ReportRows(IReadOnlyList<IReadOnlyDictionary<string, object?>> Rows, long Total);

/// <summary>
/// Executes a catalogue report. Every figure comes from another module's <c>*.Contracts</c> assembly — the
/// ledger and balance aggregations from <see cref="IInventoryReportingSource"/>, the labels from MasterData —
/// so Reporting never touches an <c>inv_</c> or <c>master_</c> table (spec §5, ADR-001).
/// </summary>
/// <remarks>
/// <para>
/// There is no <c>rpt_</c> projection behind these queries. At the volumes this system carries (SPEC §20.3 is
/// still open; the live database holds a few hundred balance rows and a few hundred ledger lines) a read model
/// maintained by <c>ReportingProjector</c> would add a minute of staleness and a second copy of the truth
/// without making a single query faster, so <c>dataAsOf</c> equals <c>generatedAt</c>: the answer is live.
/// </para>
/// <para>
/// <c>totals</c> is filled only for an export, where every matching row is in hand. A sum over one 200-row page
/// would read like a sum over the whole report and be wrong, so the synchronous page returns none.
/// </para>
/// </remarks>
public sealed class ReportRunner(
    IReportCatalogQueries catalogue,
    IInventoryReportingSource inventory,
    IReportReferenceLoader references,
    IClock clock) : IReportRunner
{
    public async Task<Result<ReportResultPageDto>> RunAsync(ReportRunFilter filter, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);

        var prepared = await PrepareAsync(filter, cancellationToken).ConfigureAwait(false);
        if (prepared.IsFailure)
        {
            return Result<ReportResultPageDto>.Failure(prepared.Error);
        }

        var (definition, columns, arguments) = prepared.Value;
        var size = Math.Clamp(filter.Size, 1, definition.MaxSyncRows);
        var slice = new ReportSlice((filter.Page - 1) * size, size, filter.SortKey, filter.SortDescending);

        var result = await ExecuteAsync(definition.Code, arguments, filter.VisibleLocations, slice, cancellationToken).ConfigureAwait(false);
        var now = clock.UtcNow;
        return new ReportResultPageDto(
            filter.Page,
            size,
            result.Total,
            definition.Code,
            columns,
            Project(result.Rows, columns),
            null,
            now,
            now);
    }

    public async Task<Result<ReportDataSet>> RenderAsync(ReportRunFilter filter, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(filter);

        var prepared = await PrepareAsync(filter, cancellationToken).ConfigureAwait(false);
        if (prepared.IsFailure)
        {
            return Result<ReportDataSet>.Failure(prepared.Error);
        }

        var (definition, columns, arguments) = prepared.Value;
        var slice = new ReportSlice(0, IReportRunner.ExportRowCap, filter.SortKey, filter.SortDescending);
        var result = await ExecuteAsync(definition.Code, arguments, filter.VisibleLocations, slice, cancellationToken).ConfigureAwait(false);
        var rows = Project(result.Rows, columns);
        return new ReportDataSet(definition.Code, definition.Name, columns, rows, Totals(result.Rows, columns), clock.UtcNow);
    }

    private async Task<Result<(ReportDefinitionDto Definition, IReadOnlyList<ReportColumnDefinition> Columns, ReportArguments Arguments)>> PrepareAsync(
        ReportRunFilter filter,
        CancellationToken cancellationToken)
    {
        var definition = await catalogue.GetAsync(filter.Code, cancellationToken).ConfigureAwait(false);
        if (definition is null || (definition.RequiresCostPermission && !filter.IncludeCost))
        {
            return ReportingErrors.ReportNotFound(filter.Code);
        }

        // Spec §16: a cost column is absent from the column list, not blanked out in the rows.
        IReadOnlyList<ReportColumnDefinition> columns = filter.IncludeCost
            ? definition.Columns
            : [.. definition.Columns.Where(c => !c.IsCost)];

        if (filter.SortKey is { } sortKey && !columns.Any(c => string.Equals(c.Key, sortKey, StringComparison.Ordinal)))
        {
            return CommonErrors.Validation(new Dictionary<string, string[]>(StringComparer.Ordinal)
            {
                ["sort"] = [$"'{sortKey}' bu hesabatın sütunu deyil."],
            });
        }

        var arguments = ReportArguments.Parse(definition, filter.Parameters, DateOnly.FromDateTime(clock.UtcNow.UtcDateTime));
        if (arguments.IsFailure)
        {
            return Result<(ReportDefinitionDto, IReadOnlyList<ReportColumnDefinition>, ReportArguments)>.Failure(arguments.Error);
        }

        if (arguments.Value.LocationId is { } locationId && !filter.VisibleLocations.Allows(locationId))
        {
            return CommonErrors.Forbidden(WmsPermissions.ViewAllLocations);
        }

        return (definition, columns, arguments.Value);
    }

    private static ReportingScope ToScope(LocationScope scope) =>
        scope.IsRestricted ? ReportingScope.RestrictedTo(scope.VisibleIds) : ReportingScope.Unrestricted;

    private static IReadOnlyList<IReadOnlyList<object?>> Project(
        IReadOnlyList<IReadOnlyDictionary<string, object?>> rows,
        IReadOnlyList<ReportColumnDefinition> columns)
    {
        var projected = new List<IReadOnlyList<object?>>(rows.Count);
        foreach (var row in rows)
        {
            var values = new object?[columns.Count];
            for (var i = 0; i < columns.Count; i++)
            {
                values[i] = row.TryGetValue(columns[i].Key, out var value) ? value : null;
            }

            projected.Add(values);
        }

        return projected;
    }

    /// <summary>Sums every numeric column of a complete result set (exports only — see the class remark).</summary>
    private static IReadOnlyDictionary<string, string>? Totals(
        IReadOnlyList<IReadOnlyDictionary<string, object?>> rows,
        IReadOnlyList<ReportColumnDefinition> columns)
    {
        var totals = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var column in columns.Where(c => c.Type is ReportColumnType.Decimal or ReportColumnType.Money))
        {
            var sum = 0m;
            var seen = false;
            foreach (var row in rows)
            {
                if (row.TryGetValue(column.Key, out var value)
                    && value is string text
                    && decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed))
                {
                    sum += parsed;
                    seen = true;
                }
            }

            if (seen)
            {
                totals[column.Key] = Cell.Decimal(sum)!;
            }
        }

        return totals.Count == 0 ? null : totals;
    }

    private async Task<ReportRows> ExecuteAsync(
        string code,
        ReportArguments arguments,
        LocationScope visibleLocations,
        ReportSlice slice,
        CancellationToken cancellationToken)
    {
        var scope = ToScope(visibleLocations);
        return code switch
        {
            ReportCatalog.StockBalance => await StockBalanceAsync(scope, arguments, slice, cancellationToken).ConfigureAwait(false),
            ReportCatalog.StockByBatch => await BatchStockAsync(scope, arguments, slice, expiryReport: false, cancellationToken).ConfigureAwait(false),
            ReportCatalog.Expiry => await BatchStockAsync(scope, arguments, slice, expiryReport: true, cancellationToken).ConfigureAwait(false),
            ReportCatalog.StockCoverage => await StockCoverageAsync(scope, arguments, slice, cancellationToken).ConfigureAwait(false),
            ReportCatalog.MovementLedger => await MovementLedgerAsync(scope, arguments, slice, cancellationToken).ConfigureAwait(false),
            ReportCatalog.BranchConsumption => await AggregateAsync(scope, arguments, slice, "CONSUMPTION", "qtyConsumed", cancellationToken).ConfigureAwait(false),
            ReportCatalog.WasteSummary => await AggregateAsync(scope, arguments, slice, "WASTE", "qtyWasted", cancellationToken).ConfigureAwait(false),
            ReportCatalog.CountVariance => await CountVarianceAsync(scope, arguments, slice, cancellationToken).ConfigureAwait(false),
            ReportCatalog.ReceiptVariance => await ReceiptVarianceAsync(scope, arguments, slice, cancellationToken).ConfigureAwait(false),
            _ => new ReportRows([], 0),
        };
    }

    private async Task<ReportRows> StockBalanceAsync(ReportingScope scope, ReportArguments arguments, ReportSlice slice, CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetStockBalancesAsync(new StockBalanceReportRequest(scope, arguments.LocationId, arguments.ProductId, arguments.IncludeZero, slice), cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(set.Rows.Select(r => r.ProductId), set.Rows.Select(r => r.LocationId), [], cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                ["qtyOnHand"] = Cell.Decimal(r.QtyOnHand),
                ["qtyReserved"] = Cell.Decimal(r.QtyReserved),
                ["qtyAvailable"] = Cell.Decimal(r.QtyAvailable),
                ["uom"] = refs.Uom(r.ProductId),
                ["batchCount"] = (long)r.BatchCount,
                ["avgUnitCost"] = Cell.Decimal(r.AvgUnitCost),
                ["totalValue"] = Cell.Decimal(r.TotalValue),
            })],
            set.Total);
    }

    private async Task<ReportRows> BatchStockAsync(
        ReportingScope scope,
        ReportArguments arguments,
        ReportSlice slice,
        bool expiryReport,
        CancellationToken cancellationToken)
    {
        var expiringBefore = expiryReport
            ? DateOnly.FromDateTime(clock.UtcNow.UtcDateTime).AddDays(arguments.WithinDays)
            : (DateOnly?)null;
        var effectiveSlice = expiryReport && slice.SortKey is null ? slice with { SortKey = "expiryDate" } : slice;

        var set = await inventory
            .GetBatchStockAsync(
                new BatchStockReportRequest(scope, arguments.LocationId, arguments.ProductId, expiringBefore, arguments.BatchStatus, arguments.IncludeZero, effectiveSlice),
                cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(
                set.Rows.Select(r => r.ProductId),
                set.Rows.Select(r => r.LocationId),
                set.Rows.Where(r => r.SupplierId is not null).Select(r => r.SupplierId!.Value),
                cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                ["batchNo"] = r.BatchNo,
                ["productionDate"] = Cell.Day(r.ProductionDate),
                ["expiryDate"] = Cell.Day(r.ExpiryDate),
                ["daysToExpiry"] = r.DaysToExpiry is { } days ? (long?)days : null,
                ["batchStatus"] = r.BatchStatus,
                ["supplierName"] = refs.SupplierName(r.SupplierId),
                ["qtyOnHand"] = Cell.Decimal(r.QtyOnHand),
                ["uom"] = refs.Uom(r.ProductId),
                ["avgUnitCost"] = Cell.Decimal(r.AvgUnitCost),
                ["totalValue"] = Cell.Decimal(r.TotalValue),
            })],
            set.Total);
    }

    private async Task<ReportRows> StockCoverageAsync(ReportingScope scope, ReportArguments arguments, ReportSlice slice, CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetStockCoverageAsync(new StockCoverageReportRequest(scope, arguments.LocationId, arguments.ProductId, arguments.WindowDays, slice), cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(set.Rows.Select(r => r.ProductId), set.Rows.Select(r => r.LocationId), [], cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r =>
            {
                // min_stock is MasterData's column, so the "below minimum" flag is computed here rather than
                // inside Inventory, which may not join master_product (spec §5).
                var minStock = refs.Product(r.ProductId)?.MinStock;
                return new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["locationCode"] = refs.LocationCode(r.LocationId),
                    ["locationName"] = refs.LocationName(r.LocationId),
                    ["sku"] = refs.Sku(r.ProductId),
                    ["productName"] = refs.ProductName(r.ProductId),
                    ["qtyOnHand"] = Cell.Decimal(r.QtyOnHand),
                    ["uom"] = refs.Uom(r.ProductId),
                    ["consumedQty"] = Cell.Decimal(r.ConsumedQty),
                    ["avgDailyConsumption"] = Cell.Decimal(r.AvgDailyConsumption),
                    ["coverageDays"] = Cell.Decimal(r.CoverageDays),
                    ["minStock"] = Cell.Decimal(minStock),
                    ["belowMin"] = minStock is { } min ? (bool?)(r.QtyOnHand < min) : null,
                    ["avgUnitCost"] = Cell.Decimal(r.AvgUnitCost),
                    ["totalValue"] = Cell.Decimal(r.TotalValue),
                };
            })],
            set.Total);
    }

    private async Task<ReportRows> MovementLedgerAsync(ReportingScope scope, ReportArguments arguments, ReportSlice slice, CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetMovementsAsync(
                new MovementReportRequest(scope, arguments.From, arguments.To, arguments.DocType, arguments.LocationId, arguments.ProductId, slice),
                cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(set.Rows.Select(r => r.ProductId), set.Rows.Select(r => r.LocationId), [], cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["postedAt"] = Cell.Moment(r.PostedAt),
                ["docDate"] = Cell.Day(r.DocDate),
                ["docType"] = r.DocType,
                ["docNo"] = r.DocNo,
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                ["batchNo"] = r.BatchNo,
                ["qtyBase"] = Cell.Decimal(r.QtyBase),
                ["uom"] = refs.Uom(r.ProductId),
                ["unitCost"] = Cell.Decimal(r.UnitCost),
                ["lineValue"] = Cell.Decimal(r.LineValue),
            })],
            set.Total);
    }

    private async Task<ReportRows> AggregateAsync(
        ReportingScope scope,
        ReportArguments arguments,
        ReportSlice slice,
        string docType,
        string quantityKey,
        CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetMovementAggregateAsync(
                new MovementAggregateReportRequest(scope, arguments.From, arguments.To, docType, arguments.LocationId, arguments.ProductId, slice),
                cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(set.Rows.Select(r => r.ProductId), set.Rows.Select(r => r.LocationId), [], cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                [quantityKey] = Cell.Decimal(r.QtyBase),
                ["uom"] = refs.Uom(r.ProductId),
                ["lineCount"] = (long)r.LineCount,
                ["firstDate"] = Cell.Day(r.FirstDate),
                ["lastDate"] = Cell.Day(r.LastDate),
                ["totalValue"] = Cell.Decimal(r.TotalValue),
            })],
            set.Total);
    }

    private async Task<ReportRows> CountVarianceAsync(ReportingScope scope, ReportArguments arguments, ReportSlice slice, CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetCountVariancesAsync(
                new CountVarianceReportRequest(scope, arguments.From, arguments.To, arguments.LocationId, arguments.OnlyVariances, slice),
                cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(set.Rows.Select(r => r.ProductId), set.Rows.Select(r => r.LocationId), [], cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["countDate"] = Cell.Day(r.CountDate),
                ["docNo"] = r.DocNo,
                ["status"] = r.Status,
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                ["batchNo"] = r.BatchNo,
                ["systemQty"] = Cell.Decimal(r.SystemQty),
                ["countedQty"] = Cell.Decimal(r.CountedQty),
                ["varianceQty"] = Cell.Decimal(r.VarianceQty),
                ["variancePct"] = Cell.Decimal(r.VariancePct),
                ["uom"] = refs.Uom(r.ProductId),
                ["unitCost"] = Cell.Decimal(r.UnitCost),
                ["varianceValue"] = Cell.Decimal(r.VarianceValue),
            })],
            set.Total);
    }

    private async Task<ReportRows> ReceiptVarianceAsync(ReportingScope scope, ReportArguments arguments, ReportSlice slice, CancellationToken cancellationToken)
    {
        var set = await inventory
            .GetReceiptVariancesAsync(
                new ReceiptVarianceReportRequest(scope, arguments.From, arguments.To, arguments.LocationId, arguments.SupplierId, arguments.OnlyVariances, slice),
                cancellationToken)
            .ConfigureAwait(false);

        var refs = await references
            .LoadAsync(
                set.Rows.Select(r => r.ProductId),
                set.Rows.Select(r => r.LocationId),
                set.Rows.Where(r => r.SupplierId is not null).Select(r => r.SupplierId!.Value),
                cancellationToken)
            .ConfigureAwait(false);

        return new ReportRows(
            [.. set.Rows.Select(r => new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["receiptDate"] = Cell.Day(r.ReceiptDate),
                ["docNo"] = r.DocNo,
                ["status"] = r.Status,
                ["locationCode"] = refs.LocationCode(r.LocationId),
                ["locationName"] = refs.LocationName(r.LocationId),
                ["supplierName"] = refs.SupplierName(r.SupplierId),
                ["sku"] = refs.Sku(r.ProductId),
                ["productName"] = refs.ProductName(r.ProductId),
                ["orderedQty"] = Cell.Decimal(r.OrderedQty),
                ["receivedQty"] = Cell.Decimal(r.ReceivedQty),
                ["acceptedQty"] = Cell.Decimal(r.AcceptedQty),
                ["rejectedQty"] = Cell.Decimal(r.RejectedQty),
                ["varianceQty"] = Cell.Decimal(r.VarianceQty),
                ["variancePct"] = Cell.Decimal(r.VariancePct),
                ["uom"] = refs.Uom(r.ProductId),
                ["unitCost"] = Cell.Decimal(r.UnitCost),
            })],
            set.Total);
    }
}

/// <summary>
/// Cell formatting of <c>ReportResultPage.rows</c>: DECIMAL, MONEY and PERCENT are always strings so no client
/// ever parses a quantity as a float (CONVENTIONS.md), dates are ISO and everything else is left alone.
/// </summary>
internal static class Cell
{
    public static string? Decimal(decimal? value) =>
        value?.ToString("0.0000", CultureInfo.InvariantCulture);

    public static string? Day(DateOnly? value) =>
        value?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    public static string Moment(DateTimeOffset value) =>
        value.UtcDateTime.ToString("yyyy-MM-dd'T'HH:mm:ss.fff'Z'", CultureInfo.InvariantCulture);
}
