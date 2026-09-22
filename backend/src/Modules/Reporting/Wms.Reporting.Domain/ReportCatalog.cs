using Wms.Reporting.Domain.Entities;
using Wms.Reporting.Domain.Enums;

namespace Wms.Reporting.Domain;

/// <summary>One report of the catalogue, as code declares it before it is written into <c>rpt_report_definition</c>.</summary>
public sealed record ReportCatalogEntry(
    string Code,
    string Name,
    string Description,
    ReportCategory Category,
    string? TorRef,
    bool RequiresCostPermission,
    IReadOnlyList<ExportFormat> SupportedFormats,
    IReadOnlyList<ReportParameterDefinition> Parameters,
    IReadOnlyList<ReportColumnDefinition> Columns);

/// <summary>
/// The report catalogue (TOR §29). The tender's list of 24 reports is <b>not in this repository</b> — SPEC has
/// no §29 (it ends at §20 plus two appendices) and ROADMAP §3 states the list itself is missing. The reports
/// declared here are the ones the contract names by code in <c>reporting.v1.yaml</c>
/// (<c>ReportCode.description</c>) and that can be answered from the schemas that exist today. The three
/// remaining named codes — <c>PO_STATUS</c>, <c>PRICE_TREND</c>, <c>SUPPLIER_PERFORMANCE</c> — belong to
/// Procurement, whose write side and <c>proc_price_history</c> are Faza 2; they are deliberately not invented
/// here.
/// </summary>
/// <remarks>
/// The catalogue is code, the runtime source of truth is the table: the migrator upserts these rows on every
/// run (the same rule as the <c>iam</c> catalogue), and <c>listReports</c> / <c>getReportDefinition</c> read
/// only <c>rpt_report_definition</c>.
/// </remarks>
public static class ReportCatalog
{
    private static readonly ExportFormat[] SheetFormats = [ExportFormat.Xlsx, ExportFormat.Csv];

    public const string StockBalance = "STOCK_BALANCE";
    public const string StockByBatch = "STOCK_BY_BATCH";
    public const string Expiry = "EXPIRY";
    public const string StockCoverage = "STOCK_COVERAGE";
    public const string MovementLedger = "MOVEMENT_LEDGER";
    public const string BranchConsumption = "BRANCH_CONSUMPTION";
    public const string WasteSummary = "WASTE_SUMMARY";
    public const string CountVariance = "COUNT_VARIANCE";
    public const string ReceiptVariance = "RECEIPT_VARIANCE";

    public static IReadOnlyList<ReportCatalogEntry> All { get; } =
    [
        new(
            StockBalance,
            "Cari qalıq",
            "Məhsul və lokasiya üzrə cari qalıq, ehtiyat və dəyər.",
            ReportCategory.Stock,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
                Boolean("includeZero", "Sıfır qalıqları da göstər", false),
            ],
            [
                Text("locationCode", "Lokasiya kodu", 120),
                Text("locationName", "Lokasiya", 180),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 260),
                Number("qtyOnHand", "Qalıq"),
                Number("qtyReserved", "Ehtiyat"),
                Number("qtyAvailable", "Əlçatan"),
                Text("uom", "Vahid", 80),
                Count("batchCount", "Partiya sayı"),
                Cost("avgUnitCost", "Orta maya"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            StockByBatch,
            "Partiya üzrə qalıq",
            "Hər partiyanın lokasiya üzrə qalığı, istehsal və son istifadə tarixi.",
            ReportCategory.Stock,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
                Enumeration("batchStatus", "Partiya statusu",
                [
                    new("ACTIVE", "Aktiv"),
                    new("BLOCKED", "Bloklanmış"),
                    new("EXPIRED", "Vaxtı keçmiş"),
                    new("QUARANTINE", "Karantin"),
                ]),
                Boolean("includeZero", "Sıfır qalıqları da göstər", false),
            ],
            [
                Text("locationCode", "Lokasiya kodu", 120),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Text("batchNo", "Partiya", 140),
                Day("productionDate", "İstehsal"),
                Day("expiryDate", "Son istifadə"),
                Count("daysToExpiry", "Qalan gün"),
                Enum("batchStatus", "Status"),
                Text("supplierName", "Təchizatçı", 200),
                Number("qtyOnHand", "Qalıq"),
                Text("uom", "Vahid", 80),
                Cost("avgUnitCost", "Orta maya"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            Expiry,
            "Son istifadə tarixi",
            "Verilmiş gün sayı ərzində vaxtı bitən partiyalar (inv_setting.expiry_warning_days defoltdur).",
            ReportCategory.Quality,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
                Integer("withinDays", "Gün sayı", 30),
            ],
            [
                Day("expiryDate", "Son istifadə"),
                Count("daysToExpiry", "Qalan gün"),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Text("batchNo", "Partiya", 140),
                Text("locationCode", "Lokasiya kodu", 120),
                Text("locationName", "Lokasiya", 180),
                Number("qtyOnHand", "Qalıq"),
                Text("uom", "Vahid", 80),
                Enum("batchStatus", "Status"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            StockCoverage,
            "Stok örtümü",
            "Cari qalıq ilə son dövrün orta gündəlik məxaricinin nisbəti — qalıq neçə günə çatır.",
            ReportCategory.Stock,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
                Integer("windowDays", "Baxılan dövr (gün)", 30),
            ],
            [
                Text("locationCode", "Lokasiya kodu", 120),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Number("qtyOnHand", "Qalıq"),
                Text("uom", "Vahid", 80),
                Number("consumedQty", "Dövr üzrə məxaric"),
                Number("avgDailyConsumption", "Gündəlik orta"),
                Number("coverageDays", "Örtüm (gün)"),
                Number("minStock", "Minimum"),
                Flag("belowMin", "Minimumdan aşağı"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            MovementLedger,
            "Hərəkət jurnalı",
            "Seçilmiş dövrün ledger sətirləri, sənəd tipi və partiya ilə birlikdə.",
            ReportCategory.Movement,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                DateRange("dateRange", "Dövr"),
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
                Enumeration("docType", "Sənəd tipi",
                [
                    new("RECEIPT", "Qəbul"),
                    new("ISSUE", "Məxaric"),
                    new("TRANSFER", "Transfer"),
                    new("COUNT_ADJUST", "Sayım düzəlişi"),
                    new("WASTE", "Tullantı"),
                    new("SAMPLE", "Nümunə"),
                    new("RETURN", "Qaytarma"),
                    new("OPENING", "Açılış"),
                    new("REVERSAL", "Storno"),
                    new("CONSUMPTION", "İstehlak"),
                ]),
            ],
            [
                Moment("postedAt", "Post vaxtı"),
                Day("docDate", "Sənəd tarixi"),
                Enum("docType", "Tip"),
                Text("docNo", "Sənəd №", 160),
                Text("locationCode", "Lokasiya", 120),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Text("batchNo", "Partiya", 140),
                Number("qtyBase", "Miqdar"),
                Text("uom", "Vahid", 80),
                Cost("unitCost", "Vahid maya"),
                Cost("lineValue", "Məbləğ"),
            ]),

        new(
            BranchConsumption,
            "Filial istehlakı",
            "Filial üzrə post edilmiş nəzəri istehlak (ADR-012), məhsul və lokasiya üzrə cəmlənmiş.",
            ReportCategory.Movement,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                DateRange("dateRange", "Dövr"),
                Location("locationId", "Filial"),
                Product("productId", "Məhsul"),
            ],
            [
                Text("locationCode", "Lokasiya kodu", 120),
                Text("locationName", "Filial", 200),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Number("qtyConsumed", "İstehlak"),
                Text("uom", "Vahid", 80),
                Count("lineCount", "Sətir sayı"),
                Day("firstDate", "İlk tarix"),
                Day("lastDate", "Son tarix"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            WasteSummary,
            "Tullantı xülasəsi",
            "Post edilmiş tullantı sənədlərinin məhsul və lokasiya üzrə cəmi.",
            ReportCategory.Quality,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                DateRange("dateRange", "Dövr"),
                Location("locationId", "Lokasiya"),
                Product("productId", "Məhsul"),
            ],
            [
                Text("locationCode", "Lokasiya kodu", 120),
                Text("locationName", "Lokasiya", 200),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Number("qtyWasted", "Tullantı"),
                Text("uom", "Vahid", 80),
                Count("lineCount", "Sətir sayı"),
                Day("firstDate", "İlk tarix"),
                Day("lastDate", "Son tarix"),
                Cost("totalValue", "Dəyər"),
            ]),

        new(
            CountVariance,
            "Sayım fərqi",
            "Sayım sətirlərində kitab qalığı ilə sayılmış miqdar arasındakı fərq (SPEC §12.7).",
            ReportCategory.Audit,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                DateRange("dateRange", "Dövr"),
                Location("locationId", "Lokasiya"),
                Boolean("onlyVariances", "Yalnız fərqli sətirlər", true),
            ],
            [
                Day("countDate", "Sayım tarixi"),
                Text("docNo", "Sənəd №", 160),
                Enum("status", "Status"),
                Text("locationCode", "Lokasiya", 120),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Text("batchNo", "Partiya", 140),
                Number("systemQty", "Kitab qalığı"),
                Number("countedQty", "Sayılmış"),
                Number("varianceQty", "Fərq"),
                Percentage("variancePct", "Fərq %"),
                Text("uom", "Vahid", 80),
                Cost("unitCost", "Vahid maya"),
                Cost("varianceValue", "Fərqin dəyəri"),
            ]),

        new(
            ReceiptVariance,
            "Qəbul fərqi",
            "Sifariş edilmiş, qəbul edilmiş və rədd edilmiş miqdarlar arasındakı fərq (SPEC §12.2).",
            ReportCategory.Procurement,
            null,
            RequiresCostPermission: false,
            SheetFormats,
            [
                DateRange("dateRange", "Dövr"),
                Location("locationId", "Lokasiya"),
                Supplier("supplierId", "Təchizatçı"),
                Boolean("onlyVariances", "Yalnız fərqli sətirlər", true),
            ],
            [
                Day("receiptDate", "Qəbul tarixi"),
                Text("docNo", "Sənəd №", 160),
                Enum("status", "Status"),
                Text("locationCode", "Lokasiya", 120),
                Text("supplierName", "Təchizatçı", 200),
                Text("sku", "SKU", 140),
                Text("productName", "Məhsul", 240),
                Number("orderedQty", "Sifariş"),
                Number("receivedQty", "Qəbul"),
                Number("acceptedQty", "Qəbul edilmiş"),
                Number("rejectedQty", "Rədd edilmiş"),
                Number("varianceQty", "Fərq"),
                Percentage("variancePct", "Fərq %"),
                Text("uom", "Vahid", 80),
                Cost("unitCost", "Vahid qiymət"),
            ]),
    ];

    public static IReadOnlyDictionary<string, ReportCatalogEntry> ByCode { get; } =
        All.ToDictionary(e => e.Code, StringComparer.Ordinal);

    private static ReportParameterDefinition Location(string name, string label) =>
        new(name, label, ReportParamType.Location, Required: false);

    private static ReportParameterDefinition Product(string name, string label) =>
        new(name, label, ReportParamType.Product, Required: false);

    private static ReportParameterDefinition Supplier(string name, string label) =>
        new(name, label, ReportParamType.Supplier, Required: false);

    /// <summary>Optional on purpose: an absent range means the trailing 30 days, so every report runs with <c>{}</c>.</summary>
    private static ReportParameterDefinition DateRange(string name, string label) =>
        new(name, label, ReportParamType.DateRange, Required: false);

    private static ReportParameterDefinition Boolean(string name, string label, bool defaultValue) =>
        new(name, label, ReportParamType.Boolean, Required: false, defaultValue);

    private static ReportParameterDefinition Integer(string name, string label, int defaultValue) =>
        new(name, label, ReportParamType.Int, Required: false, defaultValue);

    private static ReportParameterDefinition Enumeration(string name, string label, IReadOnlyList<ReportAllowedValue> values) =>
        new(name, label, ReportParamType.Enum, Required: false, null, values);

    private static ReportColumnDefinition Text(string key, string label, int width) =>
        new(key, label, ReportColumnType.String, Width: width);

    private static ReportColumnDefinition Number(string key, string label) =>
        new(key, label, ReportColumnType.Decimal, Width: 130, Align: ColumnAlign.Right);

    private static ReportColumnDefinition Count(string key, string label) =>
        new(key, label, ReportColumnType.Int, Width: 110, Align: ColumnAlign.Right);

    private static ReportColumnDefinition Percentage(string key, string label) =>
        new(key, label, ReportColumnType.Percent, Width: 110, Align: ColumnAlign.Right);

    private static ReportColumnDefinition Cost(string key, string label) =>
        new(key, label, ReportColumnType.Money, IsCost: true, Width: 140, Align: ColumnAlign.Right);

    private static ReportColumnDefinition Day(string key, string label) =>
        new(key, label, ReportColumnType.Date, Width: 120);

    private static ReportColumnDefinition Moment(string key, string label) =>
        new(key, label, ReportColumnType.Datetime, Width: 170);

    private static ReportColumnDefinition Enum(string key, string label) =>
        new(key, label, ReportColumnType.Enum, Width: 140);

    private static ReportColumnDefinition Flag(string key, string label) =>
        new(key, label, ReportColumnType.Boolean, Width: 120, Align: ColumnAlign.Center);
}
