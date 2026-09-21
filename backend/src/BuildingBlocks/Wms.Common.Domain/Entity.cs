namespace Wms.Common.Domain;

/// <summary>Base class for entities identified by a surrogate key.</summary>
public abstract class Entity<TId> : IEquatable<Entity<TId>>
    where TId : struct, IEquatable<TId>
{
    protected Entity()
    {
    }

    protected Entity(TId id)
    {
        Id = id;
    }

    public TId Id { get; protected set; }

    /// <summary>True while the entity has not been persisted (no database-generated key yet).</summary>
    public bool IsTransient() => Id.Equals(default);

    public bool Equals(Entity<TId>? other)
    {
        if (other is null)
        {
            return false;
        }

        if (ReferenceEquals(this, other))
        {
            return true;
        }

        if (GetType() != other.GetType())
        {
            return false;
        }

        if (IsTransient() || other.IsTransient())
        {
            return false;
        }

        return Id.Equals(other.Id);
    }

    public override bool Equals(object? obj) => Equals(obj as Entity<TId>);

    public override int GetHashCode() => HashCode.Combine(GetType(), Id);
}
