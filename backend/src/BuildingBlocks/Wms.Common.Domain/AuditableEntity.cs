namespace Wms.Common.Domain;

/// <summary>Entity with the mandatory audit + row_version columns of spec §6.2.</summary>
public abstract class AuditableEntity<TId> : Entity<TId>, IAuditable, IVersioned
    where TId : struct, IEquatable<TId>
{
    protected AuditableEntity()
    {
    }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    public DateTimeOffset? UpdatedAt { get; private set; }

    public uint? UpdatedBy { get; private set; }

    public uint RowVersion { get; private set; } = 1;

    public void MarkCreated(DateTimeOffset at, uint by)
    {
        CreatedAt = at;
        CreatedBy = by;
    }

    public void MarkUpdated(DateTimeOffset at, uint by)
    {
        UpdatedAt = at;
        UpdatedBy = by;
    }

    public void BumpVersion() => RowVersion++;
}

/// <summary>Aggregate root with the mandatory audit + row_version columns of spec §6.2.</summary>
public abstract class AuditableAggregateRoot<TId> : AggregateRoot<TId>, IAuditable, IVersioned
    where TId : struct, IEquatable<TId>
{
    protected AuditableAggregateRoot()
    {
    }

    public DateTimeOffset CreatedAt { get; private set; }

    public uint CreatedBy { get; private set; }

    public DateTimeOffset? UpdatedAt { get; private set; }

    public uint? UpdatedBy { get; private set; }

    public uint RowVersion { get; private set; } = 1;

    public void MarkCreated(DateTimeOffset at, uint by)
    {
        CreatedAt = at;
        CreatedBy = by;
    }

    public void MarkUpdated(DateTimeOffset at, uint by)
    {
        UpdatedAt = at;
        UpdatedBy = by;
    }

    public void BumpVersion() => RowVersion++;
}
