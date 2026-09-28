using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Wms.Notification.Domain.Entities;
using Wms.Notification.Infrastructure.Persistence;

namespace Wms.Host.Migrator;

/// <summary>
/// Fills <c>notif_rule</c> with the platform's default delivery matrix (TOR §36).
/// </summary>
/// <remarks>
/// Reference data, not demo data: the consumer delivers an event only where a rule matches, so an
/// empty table means the inbox stays empty no matter what happens in the warehouse. It therefore
/// runs on every migrator invocation, like the iam and report catalogues.
///
/// Each row is seeded as a <b>system</b> rule, which a tenant may switch off or retarget but not
/// delete — the platform has to be able to switch it back on. A rule the tenant has already edited
/// is left alone: re-running the migrator must not undo somebody's configuration.
/// </remarks>
public sealed class NotificationRuleSeeder(NotificationDbContext notifications, SeedContext context, ILogger<NotificationRuleSeeder> logger)
{
    /// <summary>
    /// Event → who hears about it, and how loudly.
    ///
    /// Targets are <see cref="Wms.Identity.Domain.SystemRoles"/> only. A tenant role such as
    /// STOCKTAKER exists in one tenant and not the next, so a platform default aimed at one would
    /// deliver to nobody on a fresh tenant; those belong in rules the tenant adds itself through
    /// <c>createNotificationRule</c>.
    /// </summary>
    private static readonly (string EventType, string Role, NotificationSeverity Severity, string Channels)[] Defaults =
    [
        ("GoodsReceiptPosted", "WAREHOUSE_KEEPER", NotificationSeverity.Info, "IN_APP"),
        ("ReceiptVarianceDetected", "PROCUREMENT_MANAGER", NotificationSeverity.Warning, "IN_APP,EMAIL"),
        ("StockBelowMinimum", "PROCUREMENT_OFFICER", NotificationSeverity.Warning, "IN_APP"),
        ("StockOverMaximum", "WAREHOUSE_KEEPER", NotificationSeverity.Info, "IN_APP"),
        ("BatchNearExpiry", "WAREHOUSE_KEEPER", NotificationSeverity.Warning, "IN_APP"),
        ("BatchExpired", "WAREHOUSE_KEEPER", NotificationSeverity.Critical, "IN_APP,EMAIL"),
        ("PurchaseOrderApproved", "PROCUREMENT_OFFICER", NotificationSeverity.Info, "IN_APP"),
        ("PriceChanged", "PROCUREMENT_MANAGER", NotificationSeverity.Info, "IN_APP"),
        ("WastePosted", "PROCUREMENT_MANAGER", NotificationSeverity.Info, "IN_APP"),
        ("TransferCompleted", "WAREHOUSE_KEEPER", NotificationSeverity.Info, "IN_APP"),
        ("CountVarianceApproved", "WAREHOUSE_KEEPER", NotificationSeverity.Info, "IN_APP"),
        ("ConsumptionShortfallDetected", "BRANCH_USER", NotificationSeverity.Warning, "IN_APP"),
        ("SalesItemUnmapped", "BRANCH_USER", NotificationSeverity.Warning, "IN_APP"),
    ];

    public async Task<int> SeedAsync(CancellationToken cancellationToken)
    {
        var existing = await notifications.Rules
            .ToDictionaryAsync(r => (r.EventType, r.TargetRoleCode ?? string.Empty), cancellationToken)
            .ConfigureAwait(false);

        var inserted = 0;
        foreach (var (eventType, role, severity, channels) in Defaults)
        {
            if (existing.ContainsKey((eventType, role)))
            {
                continue;
            }

            var rule = NotificationRule.Create(
                context.TenantId,
                eventType,
                severity,
                channels.Split(','),
                targetRoleCode: role,
                targetUserIds: null,
                targetLocationScoped: true,
                digest: NotificationDigest.Immediate,
                isSystem: true);
            if (rule.IsFailure)
            {
                logger.LogError("Default notification rule {EventType}/{Role} is invalid: {Error}", eventType, role, rule.Error.Message);
                return 1;
            }

            notifications.Rules.Add(rule.Value);
            inserted++;
        }

        // A system rule the defaults no longer list is switched off, not deleted — the same rule the
        // report catalogue follows. Deleting it would lose the tenant's edits to it, and a rule that
        // returns to the defaults should come back on rather than be created afresh.
        var wanted = Defaults.Select(d => (d.EventType, d.Role)).ToHashSet();
        var retired = 0;
        foreach (var rule in existing.Values)
        {
            if (!rule.IsSystem || !rule.IsActive || wanted.Contains((rule.EventType, rule.TargetRoleCode ?? string.Empty)))
            {
                continue;
            }

            rule.Deactivate();
            retired++;
        }

        if (inserted > 0 || retired > 0)
        {
            await notifications.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }

        logger.LogInformation(
            "Notification rules: {Inserted} added, {Retired} deactivated, {Existing} already present.",
            inserted, retired, existing.Count);
        return 0;
    }
}
