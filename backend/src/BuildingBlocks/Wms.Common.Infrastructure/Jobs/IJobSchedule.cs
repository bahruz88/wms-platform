using Hangfire;

namespace Wms.Common.Infrastructure.Jobs;

/// <summary>Implemented by modules that own recurring jobs (spec §15). Invoked once at startup when <c>Jobs:Enabled=true</c>.</summary>
public interface IJobSchedule
{
    void Register(IRecurringJobManager manager);
}
