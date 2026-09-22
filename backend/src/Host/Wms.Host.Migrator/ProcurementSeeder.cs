using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Wms.Identity.Domain;
using Wms.Identity.Infrastructure.Persistence;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Infrastructure.Persistence;
using Wms.Procurement.Domain.Entities;
using Wms.Procurement.Domain.Enums;
using Wms.Procurement.Domain.Services;
using Wms.Procurement.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>
/// Repeatable demo seed for the five procurement screens (requisitions, RFQs, quotations, approvals, price
/// history) and the dashboard's approval card.
/// </summary>
/// <remarks>
/// <para>Runs after <see cref="DemoSeeder"/> and after the dev users, because it reuses the products, UoMs,
/// suppliers, locations and currency rates the first one writes and needs real <c>iam_user.id</c> values for
/// <c>requested_by</c> — the approval inbox hides a document from the person who raised it (spec §12.6), so a
/// seeded approval only appears if it was requested by somebody other than the person looking.</para>
///
/// <para>Every step is an upsert on the natural key (document number, or the rule's
/// <c>(doc_type, product_type, step_no, min_amount_base)</c> tuple), so a second run changes nothing and a
/// partial database is completed rather than duplicated. Amounts follow the same path as production data:
/// the aggregates compute their own subtotals, VAT and base amounts from the frozen FX rate, and the price
/// history rows derive their difference and percentage from the previous row of the same pair.</para>
/// </remarks>
public sealed class ProcurementSeeder(
    MasterDataDbContext masterData,
    ProcurementDbContext procurement,
    IdentityDbContext identity,
    SeedContext context,
    ILogger<ProcurementSeeder> logger)
{
    private const uint Tenant = SeedContext.DefaultTenantId;

    /// <summary>The band where a second signature becomes necessary (AZN).</summary>
    private const decimal SecondSignatureFrom = 5_000m;

    /// <summary>Approval bands of <c>proc_approval_rule</c>: two signatures above 5 000 AZN.</summary>
    private static readonly ApprovalRuleSeed[] ApprovalRules =
    [
        new(ApprovalDocType.Po, ApprovalProductType.Any, 1, 0m, SecondSignatureFrom, SystemRoles.ProcurementManager),
        new(ApprovalDocType.Po, ApprovalProductType.Any, 1, SecondSignatureFrom + 0.0001m, null, SystemRoles.ProcurementManager),
        new(ApprovalDocType.Po, ApprovalProductType.Any, 2, SecondSignatureFrom + 0.0001m, null, SystemRoles.Admin),

        // Inventory raises these two document types against the same engine (contract: ApprovalDocType).
        new(ApprovalDocType.Waste, ApprovalProductType.Any, 1, 0m, null, SystemRoles.ProcurementManager),
        new(ApprovalDocType.CountAdjust, ApprovalProductType.Any, 1, 0m, null, SystemRoles.ProcurementManager),
    ];

    /// <summary>Requisitions from eight branches, covering six of the seven statuses.</summary>
    private static readonly RequisitionSeed[] Requisitions =
    [
        new("PR-2026-90101", "BR-NIZ", ProductType.Food, Priority.Normal, RequisitionStatus.Submitted,
            ["LETTUCE", "TOMATO", "CHICKEN"], "Həftəlik tərəvəz və ət tələbi"),
        new("PR-2026-90102", "BR-NRM", ProductType.Food, Priority.High, RequisitionStatus.InProcurement,
            ["CHEESE", "BUTTER", "MILK"], "Süd məhsulları — qiymət sorğusuna verilib"),
        new("PR-2026-90103", "BR-AZD", ProductType.NonFood, Priority.Low, RequisitionStatus.Draft,
            ["NAPKIN", "BAG-S", "BOX-SW"], "Qablaşdırma ehtiyatı"),
        new("PR-2026-90104", "BR-28M", ProductType.Food, Priority.Normal, RequisitionStatus.Submitted,
            ["BREAD-IT", "BREAD-WH"], "Çörək məmulatları"),
        new("PR-2026-90105", "BR-GNC", ProductType.NonFood, Priority.Normal, RequisitionStatus.Rejected,
            ["DETERGENT", "GLOVE"], "Təmizlik vasitələri"),
        new("PR-2026-90106", "BR-SHN", ProductType.Food, Priority.High, RequisitionStatus.ConvertedToPo,
            ["BEEF", "TURKEY"], "Ət sifarişinə çevrildi"),
        new("PR-2026-90107", "BR-ELM", ProductType.Food, Priority.Low, RequisitionStatus.Cancelled,
            ["MAYO", "KETCHUP"], "Filial tərəfindən ləğv edildi"),
        new("PR-2026-90108", "BR-ICR", ProductType.Food, Priority.Urgent, RequisitionStatus.Submitted,
            ["CHICKEN", "PEPPER", "ONION"], "Təcili — həftəsonu kampaniyası"),
    ];

    /// <summary>
    /// Four price requests. The first two are out with three suppliers each so the comparison matrix has a
    /// real spread to rank; the third is still a draft and the fourth is closed.
    /// </summary>
    private static readonly RfqSeed[] Rfqs =
    [
        new("RFQ-2026-90201", RfqStatus.Sent, ["SUP-01", "SUP-02", "SUP-04"],
            ["CHEESE", "BUTTER", "MILK"], "PR-2026-90102", "Süd məhsulları üzrə qiymət sorğusu"),
        new("RFQ-2026-90202", RfqStatus.Sent, ["SUP-01", "SUP-03", "SUP-04"],
            ["BEEF", "TURKEY"], null, "Ət qrupu — üç təchizatçı"),
        new("RFQ-2026-90203", RfqStatus.Draft, ["SUP-02", "SUP-03"],
            ["BREAD-IT", "BREAD-WH"], null, "Çörək — hazırlanır"),
        new("RFQ-2026-90204", RfqStatus.Closed, ["SUP-01", "SUP-04"],
            ["LETTUCE", "TOMATO"], null, "Tərəvəz — bağlanıb"),
    ];

    /// <summary>
    /// The offers. <c>PriceFactor</c> scales the reference price of every line, so one supplier is plainly the
    /// cheapest and the matrix has something to highlight. <c>Selected</c> marks the winner; when it is not the
    /// cheapest a selection note is mandatory (spec §10, <c>422 SELECTION_NOTE_REQUIRED</c>).
    /// </summary>
    private static readonly QuotationSeed[] Quotations =
    [
        new("RFQ-2026-90201", "SUP-01", "Q-2026-4471", 1.00m, 3, true, null),
        new("RFQ-2026-90201", "SUP-02", "Q-2026-1180", 1.12m, 5, false, null),
        new("RFQ-2026-90201", "SUP-04", "Q-2026-0903", 1.24m, 7, false, null),

        new("RFQ-2026-90202", "SUP-01", "Q-2026-4472", 1.15m, 2, true,
            "Ən ucuz deyil: iki gün çatdırılma və soyuq zəncir zəmanəti."),
        new("RFQ-2026-90202", "SUP-03", "Q-2026-7714", 1.00m, 9, false, null),
        new("RFQ-2026-90202", "SUP-04", "Q-2026-0904", 1.31m, 4, false, null),

        new("RFQ-2026-90204", "SUP-01", "Q-2026-4470", 1.00m, 2, true, null),
        new("RFQ-2026-90204", "SUP-04", "Q-2026-0901", 1.08m, 3, false, null),
    ];

    /// <summary>
    /// A purchase order in every state the contract names. <c>ApprovedSteps</c> drives the approval instance:
    /// 0 leaves the chain on step 1, 1 leaves a two-step chain waiting on the second approver — the mid-chain
    /// case the approvals screen and the dashboard card are built for.
    /// </summary>
    private static readonly PurchaseOrderSeed[] PurchaseOrders =
    [
        new("PO-2026-90301", "SUP-01", "WH-01", ProductType.Food, PurchaseOrderStatus.Draft,
            ["CHEESE", "BUTTER"], 1.00m, 0, null),
        new("PO-2026-90302", "SUP-02", "WH-01", ProductType.Food, PurchaseOrderStatus.PendingApproval,
            ["LETTUCE", "TOMATO", "CUCUMBER"], 1.00m, 0, null),
        new("PO-2026-90303", "SUP-01", "WH-02", ProductType.Food, PurchaseOrderStatus.PendingApproval,
            ["BEEF", "TURKEY", "CHICKEN", "HAM"], 4.00m, 1, null),
        new("PO-2026-90304", "SUP-03", "WH-01", ProductType.Food, PurchaseOrderStatus.Approved,
            ["MAYO", "KETCHUP"], 1.00m, 1, null),
        new("PO-2026-90305", "SUP-04", "WH-01", ProductType.Food, PurchaseOrderStatus.Rejected,
            ["ONION", "PEPPER"], 1.00m, 0, "Qiymət bazar səviyyəsindən yüksəkdir, yenidən danışıqlar aparın."),
        new("PO-2026-90306", "SUP-01", "WH-02", ProductType.Food, PurchaseOrderStatus.SentToSupplier,
            ["MILK", "YOGHURT"], 1.50m, 1, null),
        new("PO-2026-90307", "SUP-02", "WH-01", ProductType.Food, PurchaseOrderStatus.PartiallyReceived,
            ["BREAD-IT", "BREAD-WH", "BREAD-STK"], 1.00m, 1, null),
        new("PO-2026-90308", "SUP-03", "WH-01", ProductType.Food, PurchaseOrderStatus.FullyReceived,
            ["OIL", "SALT"], 1.00m, 1, null),
        new("PO-2026-90309", "SUP-05", "WH-01", ProductType.NonFood, PurchaseOrderStatus.Closed,
            ["NAPKIN", "BAG-S", "BOX-SW"], 1.00m, 1, null),
        new("PO-2026-90310", "SUP-06", "WH-01", ProductType.NonFood, PurchaseOrderStatus.Cancelled,
            ["DETERGENT", "GLOVE"], 1.00m, 0, "Büdcə ilinin sonu — sifariş ləğv edildi."),
    ];

    /// <summary>
    /// Price history with real movement. Each entry is one purchase of a product from a supplier; the multipliers
    /// are walked in order so the trend line rises, falls and settles instead of being flat.
    /// </summary>
    private static readonly PriceTrendSeed[] PriceTrends =
    [
        new("CHEESE", "SUP-01", 12.40m, [1.00m, 1.04m, 1.03m, 1.11m, 1.18m, 1.16m]),
        new("BUTTER", "SUP-01", 18.90m, [1.00m, 1.02m, 1.09m, 1.07m, 1.05m, 1.12m]),
        new("MILK", "SUP-02", 1.85m, [1.00m, 0.97m, 0.95m, 1.01m, 1.06m, 1.04m]),
        new("BEEF", "SUP-03", 21.50m, [1.00m, 1.06m, 1.13m, 1.22m, 1.19m, 1.27m]),
        new("CHICKEN", "SUP-01", 7.60m, [1.00m, 0.98m, 1.03m, 1.10m, 1.08m, 1.02m]),
        new("TOMATO", "SUP-04", 3.20m, [1.00m, 1.15m, 1.34m, 1.21m, 0.96m, 0.88m]),
        new("LETTUCE", "SUP-04", 4.10m, [1.00m, 1.09m, 1.18m, 1.07m, 0.99m, 0.94m]),
        new("BREAD-IT", "SUP-02", 0.95m, [1.00m, 1.00m, 1.05m, 1.05m, 1.11m, 1.11m]),
        new("NAPKIN", "SUP-05", 0.12m, [1.00m, 1.03m, 1.03m, 1.08m, 1.14m, 1.14m]),
        new("DETERGENT", "SUP-06", 6.40m, [1.00m, 1.07m, 1.02m, 0.98m, 1.04m, 1.09m]),
    ];

    /// <summary>Reference net unit price per SKU, in the product's purchase UoM. Base for every seeded amount.</summary>
    private static readonly Dictionary<string, decimal> ReferencePrices = new(StringComparer.Ordinal)
    {
        ["LETTUCE"] = 4.10m, ["TOMATO"] = 3.20m, ["CUCUMBER"] = 2.80m, ["ONION"] = 1.40m, ["PEPPER"] = 5.30m,
        ["CHICKEN"] = 7.60m, ["BEEF"] = 21.50m, ["TURKEY"] = 14.20m, ["HAM"] = 17.80m,
        ["CHEESE"] = 12.40m, ["BUTTER"] = 18.90m, ["MILK"] = 1.85m, ["YOGHURT"] = 3.60m,
        ["BREAD-IT"] = 0.95m, ["BREAD-WH"] = 1.10m, ["BREAD-STK"] = 0.70m,
        ["OIL"] = 9.80m, ["MAYO"] = 6.20m, ["KETCHUP"] = 4.90m, ["SALT"] = 0.85m,
        ["NAPKIN"] = 0.12m, ["BAG-S"] = 0.08m, ["BOX-SW"] = 0.35m, ["GLOVE"] = 0.22m, ["DETERGENT"] = 6.40m,
    };

    public async Task<int> RunAsync(CancellationToken cancellationToken)
    {
        var products = await masterData.Products
            .Include(p => p.Uoms)
            .ToDictionaryAsync(p => p.Sku, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var suppliers = await masterData.Suppliers
            .ToDictionaryAsync(s => s.Code, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var locations = await masterData.Locations
            .ToDictionaryAsync(l => l.Code, l => l.Id, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        if (products.Count == 0 || suppliers.Count == 0 || locations.Count == 0)
        {
            logger.LogWarning("Procurement seed skipped: master data is empty, run the demo seeder first.");
            return 0;
        }

        var users = await identity.Users
            .ToDictionaryAsync(u => u.Username, u => u.Id, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var roles = await identity.Roles
            .ToDictionaryAsync(r => r.Code, r => r.Id, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);

        // The buyer raises every document; the manager and the admin are the two approvers. Spec §12.6 keeps
        // the requester out of their own inbox, so these must be three different people.
        var buyerId = users.GetValueOrDefault("procurement", context.UserId);

        var rules = await SeedApprovalRulesAsync(roles, cancellationToken).ConfigureAwait(false);
        var requisitions = await SeedRequisitionsAsync(products, locations, cancellationToken).ConfigureAwait(false);
        var rfqs = await SeedRfqsAsync(products, suppliers, requisitions, cancellationToken).ConfigureAwait(false);
        await SeedQuotationsAsync(products, suppliers, rfqs, cancellationToken).ConfigureAwait(false);
        await SeedPurchaseOrdersAsync(products, suppliers, locations, rules, users, buyerId, cancellationToken).ConfigureAwait(false);
        await SeedPriceHistoryAsync(products, suppliers, cancellationToken).ConfigureAwait(false);

        logger.LogInformation(
            "Procurement seed complete: {Rules} approval rules, {Prs} requisitions, {Rfqs} RFQs, {Pos} purchase orders.",
            rules.Count,
            requisitions.Count,
            rfqs.Count,
            PurchaseOrders.Length);
        return 0;
    }

    // ================================================================ approval rules

    private async Task<List<ApprovalRule>> SeedApprovalRulesAsync(
        Dictionary<string, uint> roles,
        CancellationToken cancellationToken)
    {
        var existing = await procurement.ApprovalRules.ToListAsync(cancellationToken).ConfigureAwait(false);

        foreach (var seed in ApprovalRules)
        {
            var already = existing.Exists(r =>
                r.DocType == seed.DocType
                && r.ProductType == seed.ProductType
                && r.StepNo == seed.StepNo
                && r.MinAmountBase == seed.MinAmountBase);
            if (already)
            {
                continue;
            }

            if (!roles.TryGetValue(seed.RoleCode, out var roleId))
            {
                throw new InvalidOperationException($"Seed approval rule: role '{seed.RoleCode}' is missing from iam_role.");
            }

            var rule = ApprovalRule.Create(
                Tenant, seed.DocType, seed.StepNo, roleId, seed.RoleCode,
                seed.MinAmountBase, seed.MaxAmountBase, seed.ProductType);
            if (rule.IsFailure)
            {
                throw new InvalidOperationException($"Seed approval rule (step {seed.StepNo}): {rule.Error.Message}");
            }

            procurement.ApprovalRules.Add(rule.Value);
            existing.Add(rule.Value);
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    // ================================================================ requisitions

    private async Task<Dictionary<string, Requisition>> SeedRequisitionsAsync(
        Dictionary<string, Product> products,
        Dictionary<string, uint> locations,
        CancellationToken cancellationToken)
    {
        var existing = await procurement.Requisitions
            .Include(r => r.Lines)
            .ToDictionaryAsync(r => r.DocNo, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        var index = 0;
        var created = new List<(Requisition Requisition, RequisitionSeed Seed)>();

        foreach (var seed in Requisitions)
        {
            index++;
            if (existing.ContainsKey(seed.DocNo))
            {
                continue;
            }

            if (!locations.TryGetValue(seed.BranchCode, out var branchId))
            {
                throw new InvalidOperationException($"Seed requisition '{seed.DocNo}': location '{seed.BranchCode}' is missing.");
            }

            var docDate = today.AddDays(-index * 2);
            var requisition = Requisition.CreateDraft(
                Tenant, seed.DocNo, docDate, branchId, seed.ProductType, seed.Priority,
                docDate.AddDays(5), seed.Note);
            Ensure(requisition, seed.DocNo);

            var lines = seed.Skus
                .Select(sku => new RequisitionLineDraft(Product(products, sku).Id, LineQty(sku), PurchaseUom(products, sku).UomId, null))
                .ToList();
            Ensure(requisition.Value.ReplaceLines(lines), seed.DocNo);

            procurement.Requisitions.Add(requisition.Value);
            created.Add((requisition.Value, seed));
            existing[seed.DocNo] = requisition.Value;
        }

        // Saved before the transitions: RegisterConversion addresses a line by id, and every line of a brand
        // new aggregate still has id 0 until the database hands out the identities.
        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var (requisition, seed) in created)
        {
            MoveRequisitionTo(requisition, seed.Status, seed.DocNo);
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    /// <summary>Walks a fresh draft through the real transitions until it reaches the seeded status.</summary>
    private static void MoveRequisitionTo(Requisition requisition, RequisitionStatus target, string docNo)
    {
        switch (target)
        {
            case RequisitionStatus.Draft:
                break;

            case RequisitionStatus.Submitted:
                Ensure(requisition.Submit(), docNo);
                break;

            case RequisitionStatus.InProcurement:
                Ensure(requisition.Submit(), docNo);
                Ensure(requisition.MarkInProcurement(), docNo);
                break;

            case RequisitionStatus.ConvertedToPo:
                Ensure(requisition.Submit(), docNo);
                Ensure(requisition.MarkInProcurement(), docNo);
                foreach (var line in requisition.Lines)
                {
                    Ensure(requisition.RegisterConversion(line.Id, line.Qty), docNo);
                }

                break;

            case RequisitionStatus.Rejected:
                Ensure(requisition.Submit(), docNo);
                Ensure(requisition.Reject("Büdcə limiti aşılır — kəmiyyəti azaldın."), docNo);
                break;

            case RequisitionStatus.Cancelled:
                Ensure(requisition.Submit(), docNo);
                Ensure(requisition.Cancel("Filial tələbi geri götürdü."), docNo);
                break;

            default:
                throw new InvalidOperationException($"Seed requisition '{docNo}': status {target} is not seeded.");
        }
    }

    // ================================================================ RFQs

    private async Task<Dictionary<string, Rfq>> SeedRfqsAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        Dictionary<string, Requisition> requisitions,
        CancellationToken cancellationToken)
    {
        var existing = await procurement.Rfqs
            .Include(r => r.Lines)
            .Include(r => r.Suppliers)
            .ToDictionaryAsync(r => r.DocNo, StringComparer.Ordinal, cancellationToken)
            .ConfigureAwait(false);
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        var index = 0;

        foreach (var seed in Rfqs)
        {
            index++;
            if (existing.ContainsKey(seed.DocNo))
            {
                continue;
            }

            var docDate = today.AddDays(-index * 3);
            var rfq = Rfq.CreateDraft(Tenant, seed.DocNo, docDate, docDate.AddDays(7), seed.Note);
            Ensure(rfq, seed.DocNo);

            // When the request was assembled from a requisition, each line keeps the PR line it came from.
            var sourceLines = seed.RequisitionDocNo is { } prDocNo && requisitions.TryGetValue(prDocNo, out var pr)
                ? pr.Lines.ToDictionary(l => l.ProductId, l => l.Id)
                : [];

            var lines = seed.Skus
                .Select(sku =>
                {
                    var product = Product(products, sku);
                    return new RfqLineDraft(
                        product.Id,
                        LineQty(sku),
                        PurchaseUom(products, sku).UomId,
                        sourceLines.GetValueOrDefault(product.Id) is var lineId && lineId != 0 ? lineId : null,
                        null);
                })
                .ToList();
            Ensure(rfq.Value.ReplaceLines(lines), seed.DocNo);
            Ensure(rfq.Value.ReplaceSuppliers(seed.SupplierCodes.Select(code => Supplier(suppliers, code).Id)), seed.DocNo);

            if (seed.Status is RfqStatus.Sent or RfqStatus.Closed)
            {
                Ensure(rfq.Value.Send(), seed.DocNo);
            }

            if (seed.Status == RfqStatus.Closed)
            {
                Ensure(rfq.Value.Close(), seed.DocNo);
            }

            procurement.Rfqs.Add(rfq.Value);
            existing[seed.DocNo] = rfq.Value;
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    // ================================================================ quotations

    private async Task SeedQuotationsAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        Dictionary<string, Rfq> rfqs,
        CancellationToken cancellationToken)
    {
        var existingQuoteNos = await procurement.Quotations
            .Select(q => q.QuoteNo)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        var seen = new HashSet<string>(existingQuoteNos.Where(n => n is not null)!, StringComparer.Ordinal);

        // The winner is applied after every offer of an RFQ exists, so "cheapest" is decided against the
        // whole field rather than against whatever happened to be inserted first.
        var pending = new List<(Quotation Quotation, QuotationSeed Seed)>();

        foreach (var seed in Quotations)
        {
            if (seed.QuoteNo is { } quoteNo && !seen.Add(quoteNo))
            {
                continue;
            }

            if (!rfqs.TryGetValue(seed.RfqDocNo, out var rfq))
            {
                throw new InvalidOperationException($"Seed quotation '{seed.QuoteNo}': RFQ '{seed.RfqDocNo}' is missing.");
            }

            var supplier = Supplier(suppliers, seed.SupplierCode);

            // The supplier quotes in its own currency; the rate of the quote date is frozen onto the offer
            // (spec §12.5) so the comparison can rank every column in AZN.
            var fxRate = await RateOnAsync(supplier.Currency, rfq.DocDate, cancellationToken).ConfigureAwait(false);
            var quotation = Quotation.Create(
                Tenant, rfq.Id, supplier.Id, seed.QuoteNo, rfq.DocDate.AddDays(1), rfq.DocDate.AddDays(21),
                supplier.Currency, fxRate, seed.DeliveryDays, "30 gün ödəniş");
            Ensure(quotation, seed.QuoteNo ?? seed.SupplierCode);

            var lines = rfq.Lines
                .OrderBy(l => l.LineNo)
                .Select(line =>
                {
                    var sku = SkuOf(products, line.ProductId);
                    var uom = PurchaseUom(products, sku);

                    // Priced in the supplier's currency: the AZN reference divided by the frozen rate.
                    var unitPrice = Round2(ReferencePrices[sku] * seed.PriceFactor / fxRate);
                    return new QuotationLineDraft(line.ProductId, line.Qty, uom.UomId, unitPrice, uom.FactorToBase, line.Id, null);
                })
                .ToList();
            Ensure(quotation.Value.ReplaceLines(lines), seed.QuoteNo ?? seed.SupplierCode);

            procurement.Quotations.Add(quotation.Value);
            pending.Add((quotation.Value, seed));
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        foreach (var group in pending.GroupBy(p => p.Seed.RfqDocNo, StringComparer.Ordinal))
        {
            var cheapestId = group.OrderBy(p => p.Quotation.TotalAmountBase).First().Quotation.Id;
            foreach (var (quotation, seed) in group.Where(p => p.Seed.Selected))
            {
                Ensure(
                    quotation.Select(isCheapest: quotation.Id == cheapestId, seed.SelectionNote),
                    seed.QuoteNo ?? seed.SupplierCode);
            }
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    // ================================================================ purchase orders

    private async Task SeedPurchaseOrdersAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        Dictionary<string, uint> locations,
        List<ApprovalRule> rules,
        Dictionary<string, uint> users,
        uint buyerId,
        CancellationToken cancellationToken)
    {
        var existing = await procurement.PurchaseOrders
            .Select(p => p.DocNo)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        var seen = new HashSet<string>(existing, StringComparer.Ordinal);
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        var now = context.UtcNow;
        var index = 0;

        foreach (var seed in PurchaseOrders)
        {
            index++;
            if (!seen.Add(seed.DocNo))
            {
                continue;
            }

            var supplier = Supplier(suppliers, seed.SupplierCode);
            if (!locations.TryGetValue(seed.WarehouseCode, out var warehouseId))
            {
                throw new InvalidOperationException($"Seed purchase order '{seed.DocNo}': location '{seed.WarehouseCode}' is missing.");
            }

            var docDate = today.AddDays(-index * 2);
            var fxRate = await RateOnAsync(supplier.Currency, docDate, cancellationToken).ConfigureAwait(false);
            var order = PurchaseOrder.CreateDraft(
                Tenant, seed.DocNo, docDate, supplier.Id, supplier.Currency, fxRate, warehouseId, seed.ProductType,
                docDate.AddDays(6), "DDP", "30 gün ödəniş", null);
            Ensure(order, seed.DocNo);

            var lines = seed.Skus
                .Select(sku =>
                {
                    var product = Product(products, sku);
                    var uom = PurchaseUom(products, sku);
                    var unitPrice = Round2(ReferencePrices[sku] * seed.PriceFactor / fxRate);
                    return new PurchaseOrderLineDraft(product.Id, LineQty(sku), uom.UomId, unitPrice, product.VatRate, null);
                })
                .ToList();
            Ensure(order.Value.ReplaceLines(lines), seed.DocNo);

            procurement.PurchaseOrders.Add(order.Value);

            // Saved before the transitions so the lines have identities: registering a receipt addresses a line by id.
            await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            var instance = MovePurchaseOrderTo(order.Value, seed, rules, users, buyerId, now);
            if (instance is not null)
            {
                procurement.ApprovalInstances.Add(instance);
            }

            await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }

    /// <summary>
    /// Drives one purchase order to its seeded status through the real transitions, opening and deciding an
    /// approval instance on the way. Returns the instance when one was created.
    /// </summary>
    private ApprovalInstance? MovePurchaseOrderTo(
        PurchaseOrder order,
        PurchaseOrderSeed seed,
        List<ApprovalRule> rules,
        Dictionary<string, uint> users,
        uint buyerId,
        DateTimeOffset now)
    {
        if (seed.Status == PurchaseOrderStatus.Draft)
        {
            return null;
        }

        if (seed.Status == PurchaseOrderStatus.Cancelled)
        {
            Ensure(order.Cancel(seed.Comment), seed.DocNo);
            return null;
        }

        Ensure(order.SubmitForApproval(), seed.DocNo);

        var chain = ApprovalRuleSelector.Match(
            rules, ApprovalDocType.Po, order.TotalAmountBase, ApprovalProductTypes.From(order.ProductType));
        var started = ApprovalInstance.Start(
            Tenant, ApprovalDocType.Po, order.Id, order.DocNo, order.TotalAmountBase, buyerId, chain, "procurement");
        Ensure(started, seed.DocNo);
        var instance = started.Value;

        if (seed.Status == PurchaseOrderStatus.Rejected)
        {
            var step = instance.CurrentPendingStep()!;
            Ensure(
                instance.Decide(
                    step.StepNo, ApprovalDecision.Rejected, Approver(users, step.ApproverRoleCode), now,
                    comment: seed.Comment, approverUsername: ApproverUsername(step.ApproverRoleCode)),
                seed.DocNo);
            Ensure(order.Reject(seed.Comment ?? "Rədd edildi."), seed.DocNo);
            return instance;
        }

        // Approve exactly as many steps as the seed asks for; the rest stay pending, which is what puts the
        // document into somebody's approval inbox.
        var approvedSteps = seed.Status == PurchaseOrderStatus.PendingApproval
            ? seed.ApprovedSteps
            : instance.Steps.Count;

        for (var i = 0; i < approvedSteps; i++)
        {
            var step = instance.CurrentPendingStep();
            if (step is null)
            {
                break;
            }

            Ensure(
                instance.Decide(
                    step.StepNo, ApprovalDecision.Approved, Approver(users, step.ApproverRoleCode), now,
                    comment: "Təsdiqləndi.", approverUsername: ApproverUsername(step.ApproverRoleCode)),
                seed.DocNo);
        }

        if (seed.Status == PurchaseOrderStatus.PendingApproval)
        {
            return instance;
        }

        Ensure(order.Approve(), seed.DocNo);
        if (seed.Status == PurchaseOrderStatus.Approved)
        {
            return instance;
        }

        Ensure(order.MarkSent(now.AddDays(-1)), seed.DocNo);
        if (seed.Status == PurchaseOrderStatus.SentToSupplier)
        {
            return instance;
        }

        switch (seed.Status)
        {
            case PurchaseOrderStatus.PartiallyReceived:
                // Only the first line arrives, and only part of it — the case the receipt screen exists for.
                var first = order.Lines[0];
                Ensure(order.RegisterReceipt(first.Id, Round4(first.Qty / 2m)), seed.DocNo);
                break;

            case PurchaseOrderStatus.FullyReceived:
            case PurchaseOrderStatus.Closed:
                foreach (var line in order.Lines)
                {
                    Ensure(order.RegisterReceipt(line.Id, line.Qty), seed.DocNo);
                }

                if (seed.Status == PurchaseOrderStatus.Closed)
                {
                    Ensure(order.Close("Tam qəbul edildi, sifariş bağlanır."), seed.DocNo);
                }

                break;

            default:
                throw new InvalidOperationException($"Seed purchase order '{seed.DocNo}': status {seed.Status} is not seeded.");
        }

        return instance;
    }

    /// <summary>The dev username behind one approval step's role — denormalised onto the step like the role code.</summary>
    private static string ApproverUsername(string roleCode) =>
        roleCode switch
        {
            SystemRoles.Admin => "admin",
            SystemRoles.ProcurementManager => "manager",
            _ => "seeder",
        };

    /// <summary>The dev user who holds the role of one approval step. Falls back to the seeder's own id.</summary>
    private uint Approver(Dictionary<string, uint> users, string roleCode) =>
        roleCode switch
        {
            SystemRoles.Admin => users.GetValueOrDefault("admin", context.UserId),
            SystemRoles.ProcurementManager => users.GetValueOrDefault("manager", context.UserId),
            _ => context.UserId,
        };

    // ================================================================ price history

    private async Task SeedPriceHistoryAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        CancellationToken cancellationToken)
    {
        // The newest price of a pair is attributed to a real received order when one exists for that product and
        // supplier; the older entries predate every seeded order and carry no po_id, exactly as a row imported
        // from history would.
        var received = await procurement.PurchaseOrders
            .Where(p => p.Status == PurchaseOrderStatus.PartiallyReceived
                || p.Status == PurchaseOrderStatus.FullyReceived
                || p.Status == PurchaseOrderStatus.Closed)
            .Select(p => new { p.Id, p.SupplierId, ProductIds = p.Lines.Select(l => l.ProductId).ToList() })
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        var now = context.UtcNow;

        foreach (var trend in PriceTrends)
        {
            var product = Product(products, trend.Sku);
            var supplier = Supplier(suppliers, trend.SupplierCode);

            var alreadySeeded = await procurement.PriceHistory
                .AnyAsync(e => e.ProductId == product.Id && e.SupplierId == supplier.Id, cancellationToken)
                .ConfigureAwait(false);
            if (alreadySeeded)
            {
                continue;
            }

            var uom = PurchaseUom(products, trend.Sku);
            decimal? previousBase = null;

            for (var step = 0; step < trend.Multipliers.Length; step++)
            {
                // One purchase every three weeks, ending a few days ago, so the trend covers about four months.
                var priceDate = today.AddDays(-(trend.Multipliers.Length - step) * 21 + 4);
                var fxRate = await RateOnAsync(supplier.Currency, priceDate, cancellationToken).ConfigureAwait(false);

                var unitPriceBase = Round4(trend.BasePrice * trend.Multipliers[step] / uom.FactorToBase);
                var unitPrice = Round4(trend.BasePrice * trend.Multipliers[step] / fxRate);

                var isLatest = step == trend.Multipliers.Length - 1;
                var poId = isLatest
                    ? received.Find(p => p.SupplierId == supplier.Id && p.ProductIds.Contains(product.Id))?.Id
                    : null;

                var entry = PriceHistoryEntry.Record(
                    Tenant, product.Id, supplier.Id, poId,
                    priceDate, unitPrice, supplier.Currency, unitPriceBase, previousBase, now, context.UserId);
                Ensure(entry, $"{trend.Sku}/{trend.SupplierCode}");

                procurement.PriceHistory.Add(entry.Value);
                previousBase = unitPriceBase;
            }
        }

        await procurement.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    // ================================================================ helpers

    /// <summary>The published rate of a currency on a date; AZN is the base and never needs one (spec §12.5).</summary>
    private async Task<decimal> RateOnAsync(string currency, DateOnly date, CancellationToken cancellationToken)
    {
        if (string.Equals(currency, "AZN", StringComparison.OrdinalIgnoreCase))
        {
            return 1m;
        }

        var rate = await masterData.CurrencyRates
            .Where(r => r.Currency == currency && r.RateDate <= date)
            .OrderByDescending(r => r.RateDate)
            .Select(r => (decimal?)r.RateToBase)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false);

        // The demo rates only cover the last 30 days; a document dated before that falls back to the oldest
        // published rate rather than to 1, which would silently price a EUR order as if it were AZN.
        return rate
            ?? await masterData.CurrencyRates
                .Where(r => r.Currency == currency)
                .OrderBy(r => r.RateDate)
                .Select(r => (decimal?)r.RateToBase)
                .FirstOrDefaultAsync(cancellationToken)
                .ConfigureAwait(false)
            ?? throw new InvalidOperationException($"Seed: no {currency} rate is published; run the demo seeder first.");
    }

    /// <summary>Order quantity in the purchase UoM: small for expensive packs, larger for consumables.</summary>
    private static decimal LineQty(string sku) => ReferencePrices.GetValueOrDefault(sku, 1m) switch
    {
        >= 10m => 20m,
        >= 3m => 50m,
        >= 0.5m => 120m,
        _ => 500m,
    };

    /// <summary>The product's purchase UoM and its factor to base, or the base UoM when none is defined.</summary>
    private static (ushort UomId, decimal FactorToBase) PurchaseUom(Dictionary<string, Product> products, string sku)
    {
        var product = Product(products, sku);
        var purchase = product.Uoms.FirstOrDefault(u => u.IsPurchaseDefault && u.IsOpen);
        return purchase is null ? (product.BaseUomId, 1m) : (purchase.UomId, purchase.FactorToBase);
    }

    private static Product Product(Dictionary<string, Product> products, string sku) =>
        products.TryGetValue(sku, out var product)
            ? product
            : throw new InvalidOperationException($"Seed: product '{sku}' is missing; run the demo seeder first.");

    private static Supplier Supplier(Dictionary<string, Supplier> suppliers, string code) =>
        suppliers.TryGetValue(code, out var supplier)
            ? supplier
            : throw new InvalidOperationException($"Seed: supplier '{code}' is missing; run the demo seeder first.");

    private static string SkuOf(Dictionary<string, Product> products, uint productId) =>
        products.Values.FirstOrDefault(p => p.Id == productId)?.Sku
        ?? throw new InvalidOperationException($"Seed: product {productId} is not in the catalogue.");

    private static decimal Round2(decimal value) => decimal.Round(value, 2, MidpointRounding.AwayFromZero);

    private static decimal Round4(decimal value) => decimal.Round(value, 4, MidpointRounding.AwayFromZero);

    private static void Ensure(Wms.Common.Domain.Result result, string docNo)
    {
        if (result.IsFailure)
        {
            throw new InvalidOperationException($"Seed '{docNo}': {result.Error.Message}");
        }
    }

    private static void Ensure<T>(Wms.Common.Domain.Result<T> result, string docNo)
    {
        if (result.IsFailure)
        {
            throw new InvalidOperationException($"Seed '{docNo}': {result.Error.Message}");
        }
    }

    private sealed record ApprovalRuleSeed(
        ApprovalDocType DocType,
        ApprovalProductType ProductType,
        byte StepNo,
        decimal MinAmountBase,
        decimal? MaxAmountBase,
        string RoleCode);

    private sealed record RequisitionSeed(
        string DocNo,
        string BranchCode,
        ProductType ProductType,
        Priority Priority,
        RequisitionStatus Status,
        string[] Skus,
        string Note);

    private sealed record RfqSeed(
        string DocNo,
        RfqStatus Status,
        string[] SupplierCodes,
        string[] Skus,
        string? RequisitionDocNo,
        string Note);

    private sealed record QuotationSeed(
        string RfqDocNo,
        string SupplierCode,
        string? QuoteNo,
        decimal PriceFactor,
        ushort DeliveryDays,
        bool Selected,
        string? SelectionNote);

    private sealed record PurchaseOrderSeed(
        string DocNo,
        string SupplierCode,
        string WarehouseCode,
        ProductType ProductType,
        PurchaseOrderStatus Status,
        string[] Skus,
        decimal PriceFactor,
        int ApprovedSteps,
        string? Comment);

    private sealed record PriceTrendSeed(string Sku, string SupplierCode, decimal BasePrice, decimal[] Multipliers);
}
