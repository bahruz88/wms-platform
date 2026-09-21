using System.Globalization;
using Hangfire;
using Wms.Common.Application.Abstractions;
using Wms.Common.Infrastructure.Messaging;
using Wms.Common.Infrastructure.Persistence;

namespace Wms.Common.Infrastructure.Outbox;

/// <summary>
/// Hangfire recurring job (every 5 s, spec §15): locks a batch of unpublished <c>common_outbox</c> rows with
/// <c>FOR UPDATE SKIP LOCKED</c>, publishes them to RabbitMQ and stamps <c>processed_at</c> / <c>attempt_count</c>.
/// </summary>
public sealed class OutboxPublisherJob(CommonDbContext db, IEventBus eventBus, IClock clock, ILogger<OutboxPublisherJob> logger)
{
    public const string JobId = "outbox-publisher";
    public const string Cron = "*/5 * * * * *";
    public const int BatchSize = 100;
    public const int MaxAttempts = 10;

    [DisableConcurrentExecution(timeoutInSeconds: 60)]
    [AutomaticRetry(Attempts = 0)]
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);

        var pending = await db.Outbox
            .FromSqlRaw(
                "SELECT * FROM common_outbox WHERE processed_at IS NULL AND attempt_count < {0} ORDER BY id LIMIT {1} FOR UPDATE SKIP LOCKED",
                MaxAttempts,
                BatchSize)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (pending.Count == 0)
        {
            await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            return;
        }

        var published = 0;
        foreach (var message in pending)
        {
            try
            {
                var envelope = new EventEnvelope(
                    message.EventType,
                    message.TenantId,
                    message.Id.ToString(CultureInfo.InvariantCulture),
                    message.Payload,
                    message.OccurredAt);
                await eventBus.PublishAsync(envelope, cancellationToken).ConfigureAwait(false);
                message.MarkProcessed(clock.UtcNow);
                published++;
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                logger.LogWarning(ex, "Outbox message {OutboxId} ({EventType}) failed to publish (attempt {Attempt})", message.Id, message.EventType, message.AttemptCount + 1);
                message.MarkFailed(ex.ToString());
            }
        }

        await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
        logger.LogInformation("Outbox publisher processed {Count} messages, {Published} published", pending.Count, published);
    }
}
