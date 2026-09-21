using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;
using Wms.Inventory.Infrastructure.Persistence;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>
/// Repeatable demo seed for the warehouse screens (<c>dotnet run --project src/Host/Wms.Host.Migrator -- --seed</c>).
///
/// <para>Every step is an upsert keyed on the natural key (code / SKU / doc no), so running it twice changes nothing
/// and running it against a partly seeded database fills in only what is missing. Stock is never written straight
/// into <c>inv_balance</c>: opening quantities go through a real <c>OPENING</c> double-entry group, exactly as
/// ADR-004 requires, so the seeded data satisfies the same invariants as production data.</para>
/// </summary>
public sealed class DemoSeeder(
    MasterDataDbContext masterData,
    InventoryDbContext inventory,
    SeedContext context,
    ILogger<DemoSeeder> logger)
{
    private const uint Tenant = SeedContext.DefaultTenantId;

    /// <summary>The 15 branches of the TOR, plus the warehouses they are served from.</summary>
    private static readonly (string Code, string Name)[] Branches =
    [
        ("BR-ELM", "Elmlər filialı"),
        ("BR-NIZ", "Nizami filialı"),
        ("BR-28M", "28 May filialı"),
        ("BR-GNC", "Gənclik filialı"),
        ("BR-NRM", "Nərimanov filialı"),
        ("BR-SHN", "Şəhriyar filialı"),
        ("BR-AZD", "Azadlıq filialı"),
        ("BR-KRD", "Koroğlu filialı"),
        ("BR-HZI", "Həzi Aslanov filialı"),
        ("BR-MEM", "Memar Əcəmi filialı"),
        ("BR-ICR", "İçərişəhər filialı"),
        ("BR-SAH", "Sahil filialı"),
        ("BR-XTI", "Xətai filialı"),
        ("BR-ULD", "Ulduz filialı"),
        ("BR-BKI", "Bakıxanov filialı"),
    ];

    private static readonly (string Code, string Name, LocationType Type)[] Warehouses =
    [
        ("WH-01", "Mərkəzi anbar", LocationType.CentralWarehouse),
        ("WH-02", "Soyuducu anbar", LocationType.CentralWarehouse),
    ];

    private static readonly (string Code, string Name, LocationType Type)[] VirtualLocations =
    [
        ("V-SUP", "Təchizatçı (virtual)", LocationType.VSupplier),
        ("V-CONS", "İstehlak (virtual)", LocationType.VConsumption),
        ("V-ADJ", "Düzəliş (virtual)", LocationType.VAdjustment),
        ("V-WASTE", "Tullantı (virtual)", LocationType.VWaste),
        ("V-SAMPLE", "Nümunə (virtual)", LocationType.VSample),
        ("V-TRANSIT", "Yolda (virtual)", LocationType.InTransit),
    ];

    private static readonly (string Code, string Name, UomClass Class, byte Decimals)[] Uoms =
    [
        ("G", "qram", UomClass.Mass, 4),
        ("KG", "kiloqram", UomClass.Mass, 4),
        ("PRT", "porsiya", UomClass.Count, 4),
        ("PCS", "ədəd", UomClass.Count, 4),
        ("L", "litr", UomClass.Volume, 4),
        ("BOX", "qutu", UomClass.Count, 4),
    ];

    private static readonly (string Code, string Name, ProductType Type)[] Categories =
    [
        ("FOOD", "Qida", ProductType.Food),
        ("VEG", "Tərəvəz", ProductType.Food),
        ("MEAT", "Ət və toyuq", ProductType.Food),
        ("DAIRY", "Süd məhsulları", ProductType.Food),
        ("BAKERY", "Çörək məmulatları", ProductType.Food),
        ("PACK", "Qablaşdırma", ProductType.NonFood),
        ("CLEAN", "Təmizlik", ProductType.NonFood),
    ];

    /// <summary>Products with realistic batch/expiry behaviour: fresh goods need batches, dry goods do not.</summary>
    private static readonly SeedProduct[] Products =
    [
        new("LETTUCE", "Kahı", "VEG", "G", true, true, 7, 5000m, 40000m),
        new("TOMATO", "Pomidor", "VEG", "G", true, true, 10, 4000m, 30000m),
        new("CUCUMBER", "Xiyar", "VEG", "G", true, true, 10, 3000m, 25000m),
        new("ONION", "Soğan", "VEG", "G", false, false, null, 8000m, 60000m),
        new("PEPPER", "Bolqar bibəri", "VEG", "G", true, true, 12, 2000m, 15000m),
        new("CHICKEN", "Toyuq filesi", "MEAT", "G", true, true, 5, 10000m, 80000m),
        new("BEEF", "Mal əti", "MEAT", "G", true, true, 5, 8000m, 50000m),
        new("TURKEY", "Hind quşu", "MEAT", "G", true, true, 5, 4000m, 30000m),
        new("HAM", "Vetçina", "MEAT", "G", true, true, 21, 3000m, 20000m),
        new("CHEESE", "Pendir", "DAIRY", "G", true, true, 30, 5000m, 35000m),
        new("BUTTER", "Kərə yağı", "DAIRY", "G", true, true, 60, 2000m, 18000m),
        new("MILK", "Süd", "DAIRY", "L", true, true, 7, 50m, 400m),
        new("YOGHURT", "Qatıq", "DAIRY", "G", true, true, 14, 3000m, 20000m),
        new("BREAD-IT", "İtalyan çörəyi", "BAKERY", "PCS", true, true, 3, 200m, 1500m),
        new("BREAD-WH", "Tam buğda çörəyi", "BAKERY", "PCS", true, true, 3, 150m, 1200m),
        new("BREAD-STK", "Çörək çubuğu qara", "BAKERY", "PCS", true, true, 5, 100m, 900m),
        new("OIL", "Zeytun yağı", "FOOD", "L", false, false, null, 30m, 250m),
        new("MAYO", "Mayonez", "FOOD", "G", true, true, 90, 4000m, 30000m),
        new("KETCHUP", "Ketçup", "FOOD", "G", true, true, 90, 4000m, 30000m),
        new("SALT", "Duz", "FOOD", "G", false, false, null, 2000m, 15000m),
        new("NAPKIN", "Salfet", "PACK", "PCS", false, false, null, 500m, 5000m),
        new("BAG-S", "Kiçik paket", "PACK", "PCS", false, false, null, 1000m, 8000m),
        new("BOX-SW", "Sendviç qutusu", "PACK", "PCS", false, false, null, 800m, 6000m),
        new("GLOVE", "Birdəfəlik əlcək", "CLEAN", "PCS", false, false, null, 600m, 5000m),
        new("DETERGENT", "Yuyucu vasitə", "CLEAN", "L", false, false, null, 20m, 150m),
    ];

    private static readonly (string Code, string Name, bool FoodApproved, string Currency)[] Suppliers =
    [
        ("SUP-01", "Baku Food Supply MMC", true, "AZN"),
        ("SUP-02", "Azərsun Holding", true, "AZN"),
        ("SUP-03", "Gilan Qida", true, "AZN"),
        ("SUP-04", "Fresh Veg Azərbaycan", true, "AZN"),
        ("SUP-05", "Euro Packaging LLC", false, "EUR"),
        ("SUP-06", "CleanPro Kimya", false, "USD"),
    ];

    private static readonly (string Code, string Name, ReasonGroup Group, bool Approval, bool Photo)[] ReasonCodes =
    [
        ("ADJ-ERR", "Səhv sənəd — düzəliş", ReasonGroup.Adjustment, true, false),
        ("ADJ-COUNT", "Sayım fərqi", ReasonGroup.Adjustment, true, false),
        ("ADJ-FOUND", "Tapılmış mal", ReasonGroup.Adjustment, true, false),
        ("ADJ-LOST", "İtmiş mal", ReasonGroup.Adjustment, true, false),
        ("WST-EXP", "Vaxtı keçmiş", ReasonGroup.Waste, true, true),
        ("WST-DMG", "Zədələnmiş", ReasonGroup.Waste, true, true),
        ("WST-PREP", "Hazırlıq itkisi", ReasonGroup.Waste, false, false),
        ("WST-SPOIL", "Xarab olmuş", ReasonGroup.Waste, true, true),
        ("RET-QUAL", "Keyfiyyət uyğunsuzluğu", ReasonGroup.Return, true, true),
        ("RET-WRONG", "Səhv çatdırılma", ReasonGroup.Return, true, false),
        ("SMP-AQTA", "AQTA nümunəsi", ReasonGroup.Sample, false, false),
        ("SMP-LAB", "Laboratoriya analizi", ReasonGroup.Sample, false, false),
        ("TRF-SHORT", "Çatışmazlıq — transfer", ReasonGroup.Transfer, true, true),
        ("TRF-BATCH", "Partiya dəyişikliyi", ReasonGroup.Transfer, false, false),
    ];

    public async Task<int> RunAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("Seeding demo data for tenant {TenantId}", Tenant);

        var uoms = await SeedUomsAsync(cancellationToken).ConfigureAwait(false);
        var categories = await SeedCategoriesAsync(cancellationToken).ConfigureAwait(false);
        var locations = await SeedLocationsAsync(cancellationToken).ConfigureAwait(false);
        var suppliers = await SeedSuppliersAsync(cancellationToken).ConfigureAwait(false);
        await SeedReasonCodesAsync(cancellationToken).ConfigureAwait(false);
        await SeedCurrencyRatesAsync(cancellationToken).ConfigureAwait(false);
        await SeedNumberSequencesAsync(cancellationToken).ConfigureAwait(false);
        var products = await SeedProductsAsync(uoms, categories, suppliers, cancellationToken).ConfigureAwait(false);
        await SeedInventorySettingsAsync(cancellationToken).ConfigureAwait(false);

        var batches = await SeedBatchesAsync(products, suppliers, cancellationToken).ConfigureAwait(false);
        await SeedOpeningStockAsync(products, locations, batches, cancellationToken).ConfigureAwait(false);
        await SeedFrozenCountAsync(products, locations, batches, cancellationToken).ConfigureAwait(false);
        await SeedDispatchedIssuesAsync(products, locations, cancellationToken).ConfigureAwait(false);
        await SeedStockRequestsAsync(products, locations, cancellationToken).ConfigureAwait(false);

        logger.LogInformation("Demo seed complete");
        return 0;
    }

    // ================================================================ master data

    private async Task<Dictionary<string, Uom>> SeedUomsAsync(CancellationToken cancellationToken)
    {
        var existing = await masterData.Uoms.ToDictionaryAsync(u => u.Code, cancellationToken).ConfigureAwait(false);
        foreach (var (code, name, uomClass, decimals) in Uoms)
        {
            if (existing.ContainsKey(code))
            {
                continue;
            }

            var uom = Uom.Create(Tenant, code, name, uomClass, decimals);
            if (uom.IsFailure)
            {
                throw new InvalidOperationException($"Seed UoM '{code}': {uom.Error.Message}");
            }

            masterData.Uoms.Add(uom.Value);
            existing[code] = uom.Value;
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task<Dictionary<string, ProductCategory>> SeedCategoriesAsync(CancellationToken cancellationToken)
    {
        var existing = await masterData.Categories.ToDictionaryAsync(c => c.Code, cancellationToken).ConfigureAwait(false);
        foreach (var (code, name, type) in Categories)
        {
            if (existing.ContainsKey(code))
            {
                continue;
            }

            var category = ProductCategory.Create(Tenant, code, name, type);
            masterData.Categories.Add(category);
            existing[code] = category;
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task<Dictionary<string, Location>> SeedLocationsAsync(CancellationToken cancellationToken)
    {
        var existing = await masterData.Locations.ToDictionaryAsync(l => l.Code, cancellationToken).ConfigureAwait(false);

        void Add(string code, string name, LocationType type)
        {
            if (existing.ContainsKey(code))
            {
                return;
            }

            var location = Location.Create(Tenant, code, name, type);
            if (location.IsFailure)
            {
                throw new InvalidOperationException($"Seed location '{code}': {location.Error.Message}");
            }

            masterData.Locations.Add(location.Value);
            existing[code] = location.Value;
        }

        foreach (var (code, name, type) in Warehouses)
        {
            Add(code, name, type);
        }

        foreach (var (code, name) in Branches)
        {
            Add(code, name, LocationType.Restaurant);
        }

        foreach (var (code, name, type) in VirtualLocations)
        {
            Add(code, name, type);
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task<Dictionary<string, Supplier>> SeedSuppliersAsync(CancellationToken cancellationToken)
    {
        var existing = await masterData.Suppliers.ToDictionaryAsync(s => s.Code, cancellationToken).ConfigureAwait(false);
        foreach (var (code, name, foodApproved, currency) in Suppliers)
        {
            if (existing.TryGetValue(code, out var found))
            {
                if (foodApproved)
                {
                    found.ApproveAsFoodSupplier();
                }

                continue;
            }

            var supplier = Supplier.Create(Tenant, code, name, currency);
            if (supplier.IsFailure)
            {
                throw new InvalidOperationException($"Seed supplier '{code}': {supplier.Error.Message}");
            }

            if (foodApproved)
            {
                supplier.Value.ApproveAsFoodSupplier();
            }

            masterData.Suppliers.Add(supplier.Value);
            existing[code] = supplier.Value;
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task SeedReasonCodesAsync(CancellationToken cancellationToken)
    {
        var existing = await masterData.ReasonCodes.Select(r => r.Code).ToListAsync(cancellationToken).ConfigureAwait(false);
        foreach (var (code, name, group, approval, photo) in ReasonCodes)
        {
            if (existing.Contains(code, StringComparer.OrdinalIgnoreCase))
            {
                continue;
            }

            masterData.ReasonCodes.Add(ReasonCode.Create(Tenant, code, name, group, approval, photo));
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task SeedCurrencyRatesAsync(CancellationToken cancellationToken)
    {
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        (string Currency, decimal Rate)[] rates = [("USD", 1.70000000m), ("EUR", 1.85000000m), ("TRY", 0.05000000m)];

        // A month of history so the cost screens have something to plot.
        for (var offset = 0; offset < 30; offset++)
        {
            var date = today.AddDays(-offset);
            foreach (var (currency, rate) in rates)
            {
                var exists = await masterData.CurrencyRates
                    .AnyAsync(r => r.Currency == currency && r.RateDate == date, cancellationToken)
                    .ConfigureAwait(false);
                if (exists)
                {
                    continue;
                }

                // A small deterministic wobble; no randomness, so re-running produces identical rows.
                var drift = 1m + ((offset % 7) - 3) * 0.002m;
                var created = CurrencyRate.Create(Tenant, currency, date, decimal.Round(rate * drift, 8));
                if (created.IsSuccess)
                {
                    masterData.CurrencyRates.Add(created.Value);
                }
            }
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task SeedNumberSequencesAsync(CancellationToken cancellationToken)
    {
        var year = context.UtcNow.Year.ToString(System.Globalization.CultureInfo.InvariantCulture);
        string[] docTypes = ["GR", "SR", "IS", "IC", "WS", "SM", "RV", "PR", "PO", "CN", "REV"];

        foreach (var docType in docTypes)
        {
            var exists = await masterData.NumberSequences
                .AnyAsync(s => s.DocType == docType && s.Period == year, cancellationToken)
                .ConfigureAwait(false);
            if (!exists)
            {
                masterData.NumberSequences.Add(NumberSequence.Create(Tenant, docType, docType, year));
            }
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task<Dictionary<string, Product>> SeedProductsAsync(
        Dictionary<string, Uom> uoms,
        Dictionary<string, ProductCategory> categories,
        Dictionary<string, Supplier> suppliers,
        CancellationToken cancellationToken)
    {
        var existing = await masterData.Products.Include(p => p.Uoms).ToDictionaryAsync(p => p.Sku, cancellationToken).ConfigureAwait(false);
        var validFrom = new DateOnly(2026, 1, 1);
        var supplierList = suppliers.Values.Where(s => s.IsApprovedFoodSupplier).ToList();
        var index = 0;

        foreach (var seed in Products)
        {
            index++;
            if (existing.ContainsKey(seed.Sku))
            {
                continue;
            }

            var baseUom = uoms[seed.BaseUomCode];
            var category = categories[seed.CategoryCode];
            var product = Product.Create(
                Tenant, seed.Sku, seed.Name, category.Id, baseUom.Id, validFrom,
                seed.RequiresBatch, seed.RequiresExpiry);
            if (product.IsFailure)
            {
                throw new InvalidOperationException($"Seed product '{seed.Sku}': {product.Error.Message}");
            }

            product.Value.SetStockLevels(seed.MinStock, seed.MaxStock, seed.MinStock * 1.5m);
            product.Value.SetShelfLife(seed.ShelfLifeDays);
            if (supplierList.Count > 0)
            {
                product.Value.SetDefaultSupplier(supplierList[index % supplierList.Count].Id);
            }

            // A purchase UoM so the receipt screens have a realistic conversion to exercise (spec §12.1).
            if (seed.BaseUomCode == "G" && uoms.TryGetValue("KG", out var kg))
            {
                product.Value.AddOrReplaceUom(kg.Id, 1000m, validFrom, isPurchaseDefault: true);
            }
            else if (seed.BaseUomCode == "PCS" && uoms.TryGetValue("BOX", out var box))
            {
                product.Value.AddOrReplaceUom(box.Id, 24m, validFrom, isPurchaseDefault: true);
            }

            masterData.Products.Add(product.Value);
            existing[seed.Sku] = product.Value;
        }

        await masterData.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    private async Task SeedInventorySettingsAsync(CancellationToken cancellationToken)
    {
        var existing = await inventory.Settings.Select(s => s.Key).ToListAsync(cancellationToken).ConfigureAwait(false);
        foreach (var (key, value) in Wms.Inventory.Domain.InventorySettingKeys.Defaults)
        {
            if (!existing.Contains(key, StringComparer.Ordinal))
            {
                inventory.Settings.Add(InventorySetting.Create(Tenant, key, value));
            }
        }

        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    // ================================================================ inventory

    /// <summary>Batches spread across expiry stages: already expired, expiring this week, and comfortably fresh.</summary>
    private async Task<Dictionary<string, Batch>> SeedBatchesAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Supplier> suppliers,
        CancellationToken cancellationToken)
    {
        var existing = await inventory.Batches.ToDictionaryAsync(b => b.BatchNo, cancellationToken).ConfigureAwait(false);
        var today = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);
        var supplier = suppliers.Values.FirstOrDefault();
        var receivedBase = context.UtcNow.AddDays(-20);

        // Three tranches per batched product, so FEFO has something to choose between.
        (string Suffix, int ExpiryOffsetDays, int ReceivedOffsetDays)[] tranches =
        [
            ("A", -3, -18),   // already past its expiry date — must never be allocated (spec §12.4)
            ("B", 4, -10),    // inside the critical window
            ("C", 25, -2),    // fresh
        ];

        foreach (var seed in Products.Where(p => p.RequiresBatch))
        {
            var product = products[seed.Sku];
            foreach (var (suffix, expiryOffset, receivedOffset) in tranches)
            {
                var batchNo = $"{seed.Sku}-2026{suffix}";
                if (existing.ContainsKey(batchNo))
                {
                    continue;
                }

                var expiry = seed.RequiresExpiry ? today.AddDays(expiryOffset) : (DateOnly?)null;
                var batch = Batch.Create(
                    Tenant, product.Id, batchNo,
                    productionDate: today.AddDays(receivedOffset - 1),
                    expiryDate: expiry,
                    supplierId: supplier?.Id,
                    receivedAt: receivedBase.AddDays(receivedOffset));
                if (batch.IsFailure)
                {
                    throw new InvalidOperationException($"Seed batch '{batchNo}': {batch.Error.Message}");
                }

                inventory.Batches.Add(batch.Value);
                existing[batchNo] = batch.Value;
            }
        }

        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return existing;
    }

    /// <summary>
    /// Opening stock as a real <c>OPENING</c> ledger document (V_SUPPLIER − / location +), then the balance
    /// projection. Writing <c>inv_balance</c> directly would be a bug by ADR-004, seed data included.
    /// </summary>
    private async Task SeedOpeningStockAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Location> locations,
        Dictionary<string, Batch> batches,
        CancellationToken cancellationToken)
    {
        const string docNo = "OPEN-2026-00001";
        if (await inventory.MovementGroups.AnyAsync(g => g.DocNo == docNo, cancellationToken).ConfigureAwait(false))
        {
            logger.LogInformation("Opening stock {DocNo} already posted", docNo);
            return;
        }

        var supplierLocation = locations["V-SUP"];
        var now = context.UtcNow;
        var docDate = DateOnly.FromDateTime(now.UtcDateTime).AddDays(-20);

        // Central warehouse holds everything; four branches carry working stock so the screens are not all zeros.
        var stocked = new List<(Location Location, decimal Multiplier)>
        {
            (locations["WH-01"], 4m),
            (locations["WH-02"], 2m),
            (locations["BR-ELM"], 1m),
            (locations["BR-NIZ"], 1m),
            (locations["BR-28M"], 0.6m),
            (locations["BR-GNC"], 0.6m),
        };

        var inputs = new List<MovementLineInput>();
        foreach (var seed in Products)
        {
            var product = products[seed.Sku];
            var unitCost = UnitCostFor(seed.Sku);

            foreach (var (location, multiplier) in stocked)
            {
                var qty = decimal.Round(seed.MinStock * multiplier * 2m, 4);
                if (qty <= 0m)
                {
                    continue;
                }

                // A batched product splits its opening stock over the two non-expired tranches.
                var batchIds = seed.RequiresBatch
                    ? new long?[] { batches[$"{seed.Sku}-2026B"].Id, batches[$"{seed.Sku}-2026C"].Id }
                    : [null];

                var share = decimal.Round(qty / batchIds.Length, 4);
                foreach (var batchId in batchIds)
                {
                    inputs.Add(new MovementLineInput(
                        product.Id, supplierLocation.Id, batchId, -share, product.BaseUomId, 1m,
                        product.BaseUomId, BaseDecimals(product), unitCost));
                    inputs.Add(new MovementLineInput(
                        product.Id, location.Id, batchId, share, product.BaseUomId, 1m,
                        product.BaseUomId, BaseDecimals(product), unitCost));
                }
            }
        }

        var header = new MovementGroupHeader(
            Tenant, DocType.Opening, docNo, docDate, now, context.UserId,
            Guid.Parse("00000000-0000-0000-0000-00000000dead"),
            SourceDocType: "OPENING", SourceDocId: 0, Note: "Demo opening stock");

        var group = MovementGroup.Create(header, inputs);
        if (group.IsFailure)
        {
            throw new InvalidOperationException($"Opening stock group: {group.Error.Message}");
        }

        // The ledger document and the balance projection commit together, or neither does — a half-posted seed
        // leaves the database in a state no production code path could produce (ADR-004).
        await using var transaction = await inventory.Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        inventory.MovementGroups.Add(group.Value);
        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await ProjectBalancesAsync(group.Value, supplierLocation.Id, now, cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);

        logger.LogInformation("Opening stock posted: {Lines} ledger lines", group.Value.Lines.Count);
    }

    /// <summary>A FROZEN count on the central warehouse with counted lines and real variances, mid-workflow.</summary>
    private async Task SeedFrozenCountAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Location> locations,
        Dictionary<string, Batch> batches,
        CancellationToken cancellationToken)
    {
        const string docNo = "IC-2026-90001";
        if (await inventory.Counts.AnyAsync(c => c.DocNo == docNo, cancellationToken).ConfigureAwait(false))
        {
            return;
        }

        var location = locations["WH-02"];
        var now = context.UtcNow;

        var count = StockCount.CreateDraft(Tenant, docNo, location.Id, CountType.Full, [], [], "Həftəlik soyuducu anbar sayımı");
        if (count.IsFailure)
        {
            throw new InvalidOperationException($"Seed count: {count.Error.Message}");
        }

        var balances = await inventory.Balances
            .Where(b => b.LocationId == location.Id && b.QtyOnHand != 0m)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (balances.Count == 0)
        {
            logger.LogWarning("No stock at {Location}; skipping the demo count", location.Code);
            return;
        }

        var snapshot = balances
            .Select(b => new CountSnapshotRow(b.ProductId, b.BatchId, b.QtyOnHand, b.AvgUnitCost))
            .ToList();
        if (count.Value.Freeze(snapshot, now).IsFailure)
        {
            throw new InvalidOperationException("Seed count freeze failed");
        }

        // Count most lines clean and give three of them a variance, so the variance report has content.
        var adjCount = await masterData.ReasonCodes.FirstAsync(r => r.Code == "ADJ-COUNT", cancellationToken).ConfigureAwait(false);
        var adjLost = await masterData.ReasonCodes.FirstAsync(r => r.Code == "ADJ-LOST", cancellationToken).ConfigureAwait(false);

        var ordered = count.Value.Lines.OrderBy(l => l.ProductId).ThenBy(l => l.BatchId).ToList();
        for (var i = 0; i < ordered.Count; i++)
        {
            var line = ordered[i];
            var (counted, reason, note) = (i % 7) switch
            {
                1 => (decimal.Round(line.BookQty * 0.94m, 4), (ushort)adjLost.Id, "Rəfdə tapılmadı"),
                3 => (decimal.Round(line.BookQty * 1.03m, 4), (ushort)adjCount.Id, "Əvvəlki sayımda az yazılıb"),
                5 => (decimal.Round(line.BookQty * 0.985m, 4), (ushort)adjCount.Id, "Kiçik fərq"),
                _ => (line.BookQty, (ushort)0, null),
            };

            var applied = count.Value.CountLine(
                line.ProductId,
                line.BatchId,
                counted,
                reason == 0 ? null : reason,
                note,
                context.UserId,
                now);
            if (applied.IsFailure)
            {
                throw new InvalidOperationException($"Seed count line: {applied.Error.Message}");
            }
        }

        inventory.Counts.Add(count.Value);
        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        logger.LogInformation(
            "Demo count {DocNo} left in {Status} with {Variances} variance line(s) — the location is frozen",
            docNo,
            count.Value.Status,
            count.Value.Lines.Count(l => l.HasVariance));
    }

    /// <summary>Two issues dispatched to branches, waiting for the branch to confirm receipt.</summary>
    private async Task SeedDispatchedIssuesAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Location> locations,
        CancellationToken cancellationToken)
    {
        var inTransit = locations["V-TRANSIT"];
        var from = locations["WH-01"];
        var now = context.UtcNow;
        var docDate = DateOnly.FromDateTime(now.UtcDateTime).AddDays(-1);

        (string DocNo, string BranchCode, string[] Skus, Guid Key)[] plan =
        [
            ("IS-2026-90001", "BR-28M", ["ONION", "SALT", "NAPKIN"], Guid.Parse("00000000-0000-0000-0000-00000000i501".Replace('i', 'a'))),
            ("IS-2026-90002", "BR-GNC", ["OIL", "BAG-S"], Guid.Parse("00000000-0000-0000-0000-00000000a502")),
        ];

        foreach (var (docNo, branchCode, skus, key) in plan)
        {
            if (await inventory.Issues.AnyAsync(i => i.DocNo == docNo, cancellationToken).ConfigureAwait(false))
            {
                continue;
            }

            var to = locations[branchCode];

            // Only send what the warehouse can actually supply, so the seed never forces a negative balance.
            var availability = new Dictionary<uint, decimal>();
            foreach (var sku in skus)
            {
                var productId = products[sku].Id;
                availability[productId] = await inventory.Balances
                    .Where(b => b.LocationId == from.Id && b.ProductId == productId && b.BatchId == StockBalance.NoBatch)
                    .SumAsync(b => b.QtyOnHand - b.QtyReserved, cancellationToken)
                    .ConfigureAwait(false);
            }

            var sendable = skus.Where(sku => availability[products[sku].Id] >= 50m).ToArray();
            if (sendable.Length == 0)
            {
                logger.LogWarning("No batch-less stock at {From} for {DocNo}; skipping", from.Code, docNo);
                continue;
            }

            var issue = Issue.CreateDraft(Tenant, docNo, docDate, IssueType.BranchIssue, from.Id, to.Id, null, "Demo göndəriş");
            if (issue.IsFailure)
            {
                throw new InvalidOperationException($"Seed issue '{docNo}': {issue.Error.Message}");
            }

            var lines = sendable
                .Select(sku => new IssueLineInput(products[sku].Id, 50m, products[sku].BaseUomId))
                .ToList();
            if (issue.Value.ReplaceLines(lines).IsFailure)
            {
                throw new InvalidOperationException($"Seed issue lines '{docNo}'");
            }

            await using var transaction = await inventory.Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
            inventory.Issues.Add(issue.Value);
            await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            // Source −qty / IN_TRANSIT +qty, exactly what the dispatch endpoint writes.
            var inputs = new List<MovementLineInput>();
            var results = new List<PostedLineResult>();
            foreach (var line in issue.Value.Lines)
            {
                var product = products.Values.First(p => p.Id == line.ProductId);
                inputs.Add(new MovementLineInput(
                    line.ProductId, from.Id, null, -line.Qty, line.UomId, 1m,
                    product.BaseUomId, BaseDecimals(product), UnitCostFor(product.Sku)));
                inputs.Add(new MovementLineInput(
                    line.ProductId, inTransit.Id, null, line.Qty, line.UomId, 1m,
                    product.BaseUomId, BaseDecimals(product), UnitCostFor(product.Sku)));
                results.Add(new PostedLineResult(line.Id, line.Qty, null, null, UnitCostFor(product.Sku)));
            }

            var header = new MovementGroupHeader(
                Tenant, DocType.Transfer, docNo, docDate, now, context.UserId, key,
                SourceDocType: "ISSUE", SourceDocId: issue.Value.Id);
            var group = MovementGroup.Create(header, inputs);
            if (group.IsFailure)
            {
                throw new InvalidOperationException($"Seed issue group '{docNo}': {group.Error.Message}");
            }

            inventory.MovementGroups.Add(group.Value);
            await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

            await ProjectBalancesAsync(group.Value, inTransit.Id, now, cancellationToken).ConfigureAwait(false);

            if (issue.Value.RecordDispatch(results).IsFailure || issue.Value.MarkDispatched(group.Value.Id, now).IsFailure)
            {
                throw new InvalidOperationException($"Seed issue dispatch '{docNo}'");
            }

            await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            logger.LogInformation("Demo issue {DocNo} dispatched to {Branch}, awaiting confirmation", docNo, branchCode);
        }
    }

    /// <summary>A couple of branch requests, one still draft and one submitted and waiting to be picked.</summary>
    private async Task SeedStockRequestsAsync(
        Dictionary<string, Product> products,
        Dictionary<string, Location> locations,
        CancellationToken cancellationToken)
    {
        var from = locations["WH-01"];
        var docDate = DateOnly.FromDateTime(context.UtcNow.UtcDateTime);

        (string DocNo, string BranchCode, string[] Skus, bool Submit)[] plan =
        [
            ("SR-2026-90001", "BR-NRM", ["LETTUCE", "TOMATO", "CHICKEN"], true),
            ("SR-2026-90002", "BR-SHN", ["CHEESE", "BREAD-IT"], true),
            ("SR-2026-90003", "BR-AZD", ["MAYO", "KETCHUP", "NAPKIN"], false),
        ];

        foreach (var (docNo, branchCode, skus, submit) in plan)
        {
            if (await inventory.StockRequests.AnyAsync(r => r.DocNo == docNo, cancellationToken).ConfigureAwait(false))
            {
                continue;
            }

            var to = locations[branchCode];
            var request = StockRequest.CreateDraft(Tenant, docNo, docDate, from.Id, to.Id, docDate.AddDays(2), "Həftəlik tələb");
            if (request.IsFailure)
            {
                throw new InvalidOperationException($"Seed stock request '{docNo}': {request.Error.Message}");
            }

            var lines = skus
                .Select(sku => (products[sku].Id, 100m, products[sku].BaseUomId, (string?)null))
                .ToList();
            if (request.Value.ReplaceLines(lines).IsFailure)
            {
                throw new InvalidOperationException($"Seed stock request lines '{docNo}'");
            }

            if (submit && request.Value.Submit().IsFailure)
            {
                throw new InvalidOperationException($"Seed stock request submit '{docNo}'");
            }

            inventory.StockRequests.Add(request.Value);
        }

        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    // ================================================================ helpers

    /// <summary>Applies a posted group to <c>inv_balance</c> the same way the posting handlers do.</summary>
    private async Task ProjectBalancesAsync(MovementGroup group, uint virtualLocationId, DateTimeOffset now, CancellationToken cancellationToken)
    {
        // One group touches the same virtual counter-account once per line, so the rows resolved so far are cached:
        // re-querying would miss the instance already being tracked and EF would reject the duplicate key.
        var tracked = new Dictionary<(uint Product, uint Location, long Batch), StockBalance>();

        foreach (var movement in group.Lines)
        {
            var key = (movement.ProductId, movement.LocationId, movement.BatchId ?? StockBalance.NoBatch);
            if (!tracked.TryGetValue(key, out var balance))
            {
                balance = await inventory.Balances
                    .FirstOrDefaultAsync(
                        b => b.ProductId == key.Item1 && b.LocationId == key.Item2 && b.BatchId == key.Item3,
                        cancellationToken)
                    .ConfigureAwait(false);

                if (balance is null)
                {
                    balance = StockBalance.Open(Tenant, key.Item1, key.Item2, key.Item3, now);
                    inventory.Balances.Add(balance);
                }

                tracked[key] = balance;
            }

            var applied = balance.Apply(movement, allowNegativeStock: movement.LocationId == virtualLocationId, now);
            if (applied.IsFailure)
            {
                throw new InvalidOperationException($"Seed balance projection: {applied.Error.Message}");
            }
        }

        await inventory.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private static int BaseDecimals(Product product) => product.BaseUomId == 0 ? 4 : 4;

    /// <summary>Deterministic per-SKU cost so the value columns are plausible and the seed stays reproducible.</summary>
    private static decimal UnitCostFor(string sku)
    {
        var hash = sku.Aggregate(7, (acc, c) => (acc * 31) + c);
        return decimal.Round(0.0015m + Math.Abs(hash % 400) * 0.00005m, 4);
    }

    private sealed record SeedProduct(
        string Sku,
        string Name,
        string CategoryCode,
        string BaseUomCode,
        bool RequiresBatch,
        bool RequiresExpiry,
        ushort? ShelfLifeDays,
        decimal MinStock,
        decimal MaxStock);
}
