namespace Wms.Common.Domain;

/// <summary>Mandatory audit columns (spec §6.2). Stamped by the DbContext, never by handlers.</summary>
public interface IAuditable
{
    DateTimeOffset CreatedAt { get; }

    uint CreatedBy { get; }

    DateTimeOffset? UpdatedAt { get; }

    uint? UpdatedBy { get; }

    void MarkCreated(DateTimeOffset at, uint by);

    void MarkUpdated(DateTimeOffset at, uint by);
}
