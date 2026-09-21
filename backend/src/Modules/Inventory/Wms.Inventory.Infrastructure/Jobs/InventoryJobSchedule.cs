using Hangfire;
using Wms.Common.Infrastructure.Jobs;

namespace Wms.Inventory.Infrastructure.Jobs;

public sealed class InventoryJobSchedule : IJobSchedule
{
    public void Register(IRecurringJobManager manager)
    {
        ArgumentNullException.ThrowIfNull(manager);
        var options = new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc };
        manager.AddOrUpdate<ExpiryScannerJob>(ExpiryScannerJob.JobId, job => job.RunAsync(CancellationToken.None), ExpiryScannerJob.Cron, options);
        manager.AddOrUpdate<BalanceReconciliationJob>(BalanceReconciliationJob.JobId, job => job.RunAsync(CancellationToken.None), BalanceReconciliationJob.Cron, options);
        manager.AddOrUpdate<DoubleEntryCheckJob>(DoubleEntryCheckJob.JobId, job => job.RunAsync(CancellationToken.None), DoubleEntryCheckJob.Cron, options);
    }
}
