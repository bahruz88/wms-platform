using Hangfire;
using Wms.Common.Infrastructure.Jobs;

namespace Wms.Common.Infrastructure.Outbox;

public sealed class OutboxJobSchedule : IJobSchedule
{
    public void Register(IRecurringJobManager manager)
    {
        ArgumentNullException.ThrowIfNull(manager);
        manager.AddOrUpdate<OutboxPublisherJob>(
            OutboxPublisherJob.JobId,
            job => job.RunAsync(CancellationToken.None),
            OutboxPublisherJob.Cron,
            new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });
    }
}
