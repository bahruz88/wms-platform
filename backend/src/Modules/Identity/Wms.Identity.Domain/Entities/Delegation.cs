using Wms.Common.Domain;

namespace Wms.Identity.Domain.Entities;

/// <summary><c>iam_delegation</c> — approval delegation for a date range (spec §7, §17.1).</summary>
public sealed class Delegation : Entity<uint>, ITenantEntity
{
    private Delegation()
    {
    }

    public uint TenantId { get; private set; }

    public uint FromUserId { get; private set; }

    public uint ToUserId { get; private set; }

    public DateOnly ValidFrom { get; private set; }

    public DateOnly ValidTo { get; private set; }

    public string? Reason { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    public static Result<Delegation> Create(uint tenantId, uint fromUserId, uint toUserId, DateOnly validFrom, DateOnly validTo, string? reason, DateTimeOffset now, uint createdBy)
    {
        if (fromUserId == toUserId)
        {
            return IdentityErrors.InvalidDelegation("A user cannot delegate to themselves.");
        }

        if (validTo < validFrom)
        {
            return IdentityErrors.InvalidDelegation("valid_to cannot be earlier than valid_from.");
        }

        return new Delegation
        {
            TenantId = tenantId,
            FromUserId = fromUserId,
            ToUserId = toUserId,
            ValidFrom = validFrom,
            ValidTo = validTo,
            Reason = reason,
            CreatedAt = now,
            CreatedBy = createdBy,
        };
    }

    public bool IsActiveOn(DateOnly date) => date >= ValidFrom && date <= ValidTo;

    /// <summary>
    /// Contract <c>revokeDelegation</c>: "pulls <c>validTo</c> back to today; the row is not deleted so the
    /// history survives". Revoking a delegation that has not started yet closes it before it opens.
    /// </summary>
    public void Revoke(DateOnly today) => ValidTo = today < ValidFrom ? ValidFrom.AddDays(-1) : today;

    public bool Overlaps(DateOnly from, DateOnly to) => from <= ValidTo && to >= ValidFrom;
}
