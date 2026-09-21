using Hangfire;
using Wms.Common.Infrastructure.Jobs;

namespace Wms.Consumption.Infrastructure.Jobs;

public sealed class ConsumptionJobSchedule : IJobSchedule
{
    public void Register(IRecurringJobManager manager)
    {
        ArgumentNullException.ThrowIfNull(manager);
        var options = new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc };
        manager.AddOrUpdate<ConsumptionRunnerJob>(ConsumptionRunnerJob.JobId, job => job.RunAsync(CancellationToken.None), ConsumptionRunnerJob.Cron, options);
        manager.AddOrUpdate<SalesImportReminderJob>(SalesImportReminderJob.JobId, job => job.RunAsync(CancellationToken.None), SalesImportReminderJob.Cron, options);
    }
}
