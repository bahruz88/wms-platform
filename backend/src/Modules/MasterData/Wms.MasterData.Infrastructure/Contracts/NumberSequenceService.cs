using System.Globalization;
using Wms.Common.Application.Abstractions;
using Wms.Common.Application.Security;
using Wms.MasterData.Contracts;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Infrastructure.Persistence;

namespace Wms.MasterData.Infrastructure.Contracts;

/// <summary>
/// In-process <see cref="INumberSequenceService"/> (spec Əlavə B): the counter row is taken with
/// <c>SELECT ... FOR UPDATE</c> so concurrent callers serialise. Gaps are accepted when a transaction rolls back.
/// </summary>
public sealed class NumberSequenceService(MasterDataDbContext db, ITenantContext tenantContext) : INumberSequenceService
{
    [AllowCrossTenant("tenant_id is bound as a parameter inside the raw SQL; IgnoreQueryFilters only keeps EF from wrapping the FOR UPDATE statement in a derived table.")]
    public async Task<string> NextAsync(string docType, DateOnly docDate, CancellationToken cancellationToken)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(docType);
        var tenantId = tenantContext.TenantId;
        var period = docDate.Year.ToString(CultureInfo.InvariantCulture);

        var ownsTransaction = db.Database.CurrentTransaction is null;
        var transaction = ownsTransaction ? await db.Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false) : null;
        try
        {
            var rows = await db.NumberSequences
                .FromSqlInterpolated($"""
                    SELECT * FROM master_number_sequence
                    WHERE tenant_id = {tenantId} AND doc_type = {docType} AND period = {period}
                    FOR UPDATE
                    """)
                .IgnoreQueryFilters()
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

            var sequence = rows.SingleOrDefault();
            if (sequence is null)
            {
                sequence = NumberSequence.Create(tenantId, docType, docType, period);
                db.NumberSequences.Add(sequence);
            }

            var next = sequence.Next();
            if (next.IsFailure)
            {
                throw new InvalidOperationException(next.Error.Message);
            }

            await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            if (transaction is not null)
            {
                await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
            }

            return next.Value;
        }
        finally
        {
            if (transaction is not null)
            {
                await transaction.DisposeAsync().ConfigureAwait(false);
            }
        }
    }
}
