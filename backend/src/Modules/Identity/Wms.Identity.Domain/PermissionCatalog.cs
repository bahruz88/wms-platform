using Wms.Common.Domain;

namespace Wms.Identity.Domain;

/// <summary>
/// The <c>iam_permission</c> catalogue (spec §7) and the default role → permission grants that seed
/// <c>iam_role_permission</c>.
/// </summary>
/// <remarks>
/// Authorization is permission based (spec §16) and the permission set of a principal is read from the
/// database, not from a compiled table. This class is the single place where the codes are declared, so
/// the catalogue, the seeder and the architecture test that compares it with every <c>x-permission</c> in
/// <c>contracts/openapi/</c> and every <c>.RequirePermission(...)</c> in the solution cannot drift apart.
/// The codes are literals on purpose: <c>Wms.Identity.Domain</c> may only reference <c>Wms.Common.Domain</c>
/// (ADR-001), so it cannot read the other modules' permission constants.
/// </remarks>
public static class PermissionCatalog
{
    public const string ModuleIdentity = "identity";
    public const string ModuleMasterData = "masterdata";
    public const string ModuleInventory = "inventory";
    public const string ModuleConsumption = "consumption";
    public const string ModuleProcurement = "procurement";
    public const string ModuleDocuments = "documents";
    public const string ModuleNotification = "notification";
    public const string ModuleReporting = "reporting";
    public const string ModuleIntegration = "integration";

    /// <summary>Every permission code the platform knows, with the module that owns it.</summary>
    public static IReadOnlyList<PermissionDefinition> All { get; } =
    [
        // --- identity -------------------------------------------------------
        new("iam.me.view", ModuleIdentity, "Öz kontekstini görmək"),
        new("iam.user.view", ModuleIdentity, "İstifadəçiləri görmək"),
        new("iam.user.manage", ModuleIdentity, "İstifadəçi yaratmaq və dəyişmək"),
        new("iam.role.view", ModuleIdentity, "Rolları və icazə kataloqunu görmək"),
        new("iam.role.manage", ModuleIdentity, "Rol yaratmaq, rol icazələrini təyin etmək"),
        new("iam.delegation.view", ModuleIdentity, "Delegasiyaları görmək"),
        new("iam.delegation.create", ModuleIdentity, "Delegasiya yaratmaq və ləğv etmək"),
        new("iam.delegation.manage", ModuleIdentity, "Bütün istifadəçilər adından delegasiya"),
        new("iam.location.view_all", ModuleIdentity, "Bütün lokasiyaları görmək (lokasiya filtrini götürür)"),
        new("iam.audit.view", ModuleIdentity, "Audit jurnalını görmək"),

        // --- master data ----------------------------------------------------
        new("master.product.view", ModuleMasterData, "Məhsulları görmək"),
        new("master.product.manage", ModuleMasterData, "Məhsul yaratmaq və dəyişmək"),
        new("master.product.view_cost", ModuleMasterData, "Maya dəyəri sütunlarını görmək", IsCritical: true),
        new("master.category.view", ModuleMasterData, "Kateqoriyaları görmək"),
        new("master.category.manage", ModuleMasterData, "Kateqoriya yaratmaq və dəyişmək"),
        new("master.uom.view", ModuleMasterData, "Ölçü vahidlərini görmək"),
        new("master.uom.manage", ModuleMasterData, "Ölçü vahidi yaratmaq"),
        new("master.supplier.view", ModuleMasterData, "Təchizatçıları görmək"),
        new("master.supplier.manage", ModuleMasterData, "Təchizatçı yaratmaq və dəyişmək"),
        new("master.location.view", ModuleMasterData, "Lokasiyaları görmək"),
        new("master.location.manage", ModuleMasterData, "Lokasiya yaratmaq və dəyişmək"),
        new("master.currency.view", ModuleMasterData, "Məzənnələri görmək"),
        new("master.currency.manage", ModuleMasterData, "Məzənnə yazmaq"),
        new("master.reason.view", ModuleMasterData, "Səbəb kodlarını görmək"),
        new("master.reason.manage", ModuleMasterData, "Səbəb kodu yaratmaq və dəyişmək"),
        new("master.reason_code.manage", ModuleMasterData, "Səbəb kodu idarəetməsi (köhnə kod adı)"),
        new("master.sequence.view", ModuleMasterData, "Nömrə seriyalarını görmək"),

        // --- inventory ------------------------------------------------------
        new("inv.balance.view", ModuleInventory, "Qalıqları görmək"),
        new("inv.batch.view", ModuleInventory, "Partiyaları görmək"),
        new("inv.batch.manage", ModuleInventory, "Partiya statusunu dəyişmək"),
        new("inv.movement.view", ModuleInventory, "Ledger hərəkətlərini görmək"),
        new("inv.movement.reverse", ModuleInventory, "Hərəkət qrupunu storno etmək", IsCritical: true),
        new("inv.receipt.view", ModuleInventory, "Qəbulları görmək"),
        new("inv.receipt.create", ModuleInventory, "Qəbul yaratmaq"),
        new("inv.receipt.post", ModuleInventory, "Qəbulu post etmək"),
        new("inv.request.view", ModuleInventory, "Tələbləri görmək"),
        new("inv.request.create", ModuleInventory, "Tələb yaratmaq"),
        new("inv.request.submit", ModuleInventory, "Tələbi təsdiqə göndərmək"),
        new("inv.issue.view", ModuleInventory, "Məxaricləri görmək"),
        new("inv.issue.create", ModuleInventory, "Məxaric yaratmaq"),
        new("inv.issue.dispatch", ModuleInventory, "Məxarici yola salmaq"),
        new("inv.issue.confirm", ModuleInventory, "Məxarici qəbul etmək"),
        new("inv.count.view", ModuleInventory, "Sayımları görmək"),
        new("inv.count.create", ModuleInventory, "Sayım yaratmaq"),
        new("inv.count.freeze", ModuleInventory, "Sayımı dondurmaq"),
        new("inv.count.enter", ModuleInventory, "Sayım sətirlərini daxil etmək"),
        new("inv.count.post", ModuleInventory, "Sayımı post etmək"),
        new("inv.adjustment.approve", ModuleInventory, "Sayım fərqini təsdiqləmək", IsCritical: true),
        new("inv.waste.view", ModuleInventory, "Tullantıları görmək"),
        new("inv.waste.create", ModuleInventory, "Tullantı yaratmaq"),
        new("inv.waste.approve", ModuleInventory, "Tullantını təsdiqləmək", IsCritical: true),
        new("inv.waste.post", ModuleInventory, "Tullantını post etmək"),
        new("inv.sample.view", ModuleInventory, "Nümunələri görmək"),
        new("inv.sample.create", ModuleInventory, "Nümunə yaratmaq"),
        new("inv.sample.post", ModuleInventory, "Nümunəni post etmək"),
        new("inv.rtv.view", ModuleInventory, "Təchizatçıya qaytarmaları görmək"),
        new("inv.rtv.create", ModuleInventory, "Təchizatçıya qaytarma yaratmaq"),
        new("inv.rtv.post", ModuleInventory, "Təchizatçıya qaytarmanı təchizatçıya göndərmək"),
        new("inv.settings.view", ModuleInventory, "Anbar parametrlərini görmək"),
        new("inv.settings.manage", ModuleInventory, "Anbar parametrlərini dəyişmək", IsCritical: true),

        // --- consumption ----------------------------------------------------
        new("cons.recipe.view", ModuleConsumption, "Reseptləri görmək"),
        new("cons.recipe.manage", ModuleConsumption, "Resept yaratmaq və dəyişmək"),
        new("cons.sales.import", ModuleConsumption, "Satış datası yükləmək"),
        new("cons.run.calculate", ModuleConsumption, "İstehlak hesablamaq"),
        new("cons.run.post", ModuleConsumption, "İstehlakı post etmək"),
        new("cons.variance.view", ModuleConsumption, "Fərq hesabatını görmək"),

        // --- procurement ----------------------------------------------------
        new("proc.pr.view", ModuleProcurement, "Tələbnamələri görmək"),
        new("proc.pr.create", ModuleProcurement, "Tələbnamə yaratmaq"),
        new("proc.pr.submit", ModuleProcurement, "Tələbnaməni təsdiqə göndərmək"),
        new("proc.pr.reject", ModuleProcurement, "Tələbnaməni rədd etmək"),
        new("proc.rfq.view", ModuleProcurement, "RFQ-ları görmək"),
        new("proc.rfq.create", ModuleProcurement, "RFQ yaratmaq"),
        new("proc.quotation.view", ModuleProcurement, "Təklifləri görmək"),
        new("proc.quotation.create", ModuleProcurement, "Təklif daxil etmək"),
        new("proc.quotation.select", ModuleProcurement, "Təklif seçmək"),
        new("proc.po.view", ModuleProcurement, "Sifarişləri görmək"),
        new("proc.po.view_for_receipt", ModuleProcurement, "Qəbul üçün sifarişi görmək"),
        new("proc.po.create", ModuleProcurement, "Sifariş yaratmaq"),
        new("proc.po.submit", ModuleProcurement, "Sifarişi təsdiqə göndərmək"),
        new("proc.po.approve", ModuleProcurement, "Sifarişi təsdiqləmək", IsCritical: true),
        new("proc.po.send", ModuleProcurement, "Sifarişi təchizatçıya göndərmək"),
        new("proc.po.close", ModuleProcurement, "Sifarişi bağlamaq"),
        new("proc.approval.view", ModuleProcurement, "Təsdiq zəncirini görmək"),
        new("proc.approval.decide", ModuleProcurement, "Təsdiq qərarı vermək", IsCritical: true),
        new("proc.approval_rule.view", ModuleProcurement, "Təsdiq qaydalarını görmək"),
        new("proc.approval_rule.manage", ModuleProcurement, "Təsdiq qaydalarını dəyişmək"),

        // --- documents ------------------------------------------------------
        new("doc.attachment.view", ModuleDocuments, "Əlavələri görmək"),
        new("doc.attachment.upload", ModuleDocuments, "Əlavə yükləmək"),
        new("doc.attachment.delete", ModuleDocuments, "Əlavə silmək"),
        new("doc.attachment.manage", ModuleDocuments, "Əlavələri idarə etmək"),

        // --- notification ---------------------------------------------------
        new("notif.inbox.view", ModuleNotification, "Bildiriş qutusunu görmək"),
        new("notif.message.view", ModuleNotification, "Bildiriş mesajlarını görmək"),
        new("notif.rule.view", ModuleNotification, "Bildiriş qaydalarını görmək"),
        new("notif.rule.manage", ModuleNotification, "Bildiriş qaydalarını dəyişmək"),

        // --- reporting ------------------------------------------------------
        new("rpt.report.view", ModuleReporting, "Hesabatları görmək"),
        new("rpt.report.export", ModuleReporting, "Hesabat ixrac etmək"),
        new("rpt.dashboard.view", ModuleReporting, "Dashboard-u görmək"),
        new("rpt.export.create", ModuleReporting, "İxrac tapşırığı yaratmaq"),

        // --- integration ----------------------------------------------------
        new("intg.outbound.view", ModuleIntegration, "Çıxış mesajlarını görmək"),
        new("intg.endpoint.manage", ModuleIntegration, "İnteqrasiya endpoint-lərini idarə etmək"),
        new("intg.sync.trigger", ModuleIntegration, "Sinxronizasiya başlatmaq"),
    ];

    public static IReadOnlyCollection<string> Codes { get; } = All.Select(p => p.Code).ToHashSet(StringComparer.Ordinal);

    /// <summary>Spec §7.1: the warehouse keeper must never hold this one.</summary>
    public const string ProductViewCost = "master.product.view_cost";

    /// <summary>Lifts the spec §16 location filter. Kept in sync with <c>WmsPermissions.ViewAllLocations</c>.</summary>
    public const string ViewAllLocations = "iam.location.view_all";

    /// <summary>
    /// Role → permission patterns used to seed <c>iam_role_permission</c> for a new tenant. <c>*</c> stands for
    /// one or more whole segments, matching <c>RolePermissionMap</c> (README §8.12).
    /// </summary>
    public static IReadOnlyDictionary<string, string[]> DefaultRoleGrants { get; } =
        new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            [SystemRoles.Admin] = ["*"],
            [SystemRoles.ProcurementOfficer] =
            [
                "proc.pr.*", "proc.rfq.*", "proc.quotation.*", "proc.po.create", "proc.po.view",
                "proc.po.view_for_receipt", "proc.po.submit", "proc.po.send", "proc.approval.view",
                "master.product.view", "master.product.view_cost", "master.supplier.*", "master.location.view",
                "master.category.view", "master.uom.view", "master.currency.view", "master.reason.view",
                "inv.balance.view", "inv.batch.view", "inv.receipt.view", "rpt.*", "doc.*", "notif.*",
                "iam.me.view", "iam.delegation.view", "iam.delegation.create", ViewAllLocations,
            ],
            [SystemRoles.ProcurementManager] =
            [
                "proc.*", "master.*", "inv.*.view", "inv.balance.view", "inv.adjustment.approve",
                "inv.waste.approve", "inv.settings.view", "inv.movement.reverse", "rpt.*", "doc.*", "notif.*",
                "iam.me.view", "iam.user.view", "iam.role.view", "iam.delegation.view", "iam.delegation.create",
                "audit.view", "iam.audit.view", ViewAllLocations,
            ],
            [SystemRoles.WarehouseKeeper] =
            [
                // Deliberately WITHOUT master.product.view_cost (spec §7.1, TOR §3.1, §40).
                "inv.receipt.create", "inv.receipt.post", "inv.receipt.view", "inv.issue.create",
                "inv.issue.dispatch", "inv.issue.view", "inv.issue.confirm", "inv.count.create",
                "inv.count.freeze", "inv.count.enter", "inv.count.post", "inv.count.view",
                "inv.waste.create", "inv.waste.view", "inv.waste.post", "inv.sample.create",
                "inv.sample.view", "inv.sample.post", "inv.rtv.view", "inv.rtv.create", "inv.rtv.post",
                "inv.movement.view",
                "inv.batch.manage", "inv.batch.view", "inv.balance.view", "inv.request.view",
                "inv.settings.view", "master.product.view", "master.location.view", "master.supplier.view",
                "master.category.view", "master.uom.view", "master.reason.view", "master.sequence.view",
                "proc.po.view_for_receipt", "rpt.dashboard.view", "rpt.report.view", "rpt.export.create", "notif.*", "iam.me.view", ViewAllLocations,
            // Not doc.attachment.* : that also grants doc.attachment.manage, i.e. deleting somebody
            // else's upload. A keeper may delete only their own.
            "doc.attachment.view", "doc.attachment.upload", "doc.attachment.delete",
            ],
            [SystemRoles.BranchUser] =
            [
                // No iam.location.view_all: a branch user is confined to iam_user_location (spec §16).
                "inv.request.create", "inv.request.submit", "inv.request.view", "inv.issue.confirm",
                "inv.waste.create", "inv.waste.view", "inv.count.enter", "inv.count.view",
                "inv.issue.view", "inv.movement.view", "inv.balance.view", "inv.batch.view",
                "master.product.view", "master.location.view", "master.reason.view", "cons.recipe.view",
                "cons.sales.import", "cons.variance.view", "rpt.dashboard.view", "rpt.report.view", "notif.*", "iam.me.view",
            "doc.attachment.view", "doc.attachment.upload", "doc.attachment.delete",
            ],
            [SystemRoles.Auditor] =
            [
                "*.view", "*.view_cost", "rpt.*", "audit.view", "iam.audit.view", "notif.*", "iam.me.view", ViewAllLocations,
            ],
        };

    /// <summary>Expands the wildcard patterns of a role against the catalogue.</summary>
    public static IReadOnlyList<string> Expand(IEnumerable<string> patterns)
    {
        ArgumentNullException.ThrowIfNull(patterns);
        var granted = new SortedSet<string>(StringComparer.Ordinal);
        foreach (var pattern in patterns)
        {
            if (!pattern.Contains('*', StringComparison.Ordinal))
            {
                if (Codes.Contains(pattern))
                {
                    granted.Add(pattern);
                }

                continue;
            }

            foreach (var definition in All)
            {
                if (PermissionPattern.Matches(pattern, definition.Code))
                {
                    granted.Add(definition.Code);
                }
            }
        }

        return [.. granted];
    }

    public static IReadOnlyList<string> GrantsFor(string roleCode) =>
        DefaultRoleGrants.TryGetValue(roleCode, out var patterns) ? Expand(patterns) : [];
}

/// <param name="IsCritical">Spec §7.1 — shown with a warning in the UI.</param>
public sealed record PermissionDefinition(string Code, string Module, string? Description = null, bool IsCritical = false);
