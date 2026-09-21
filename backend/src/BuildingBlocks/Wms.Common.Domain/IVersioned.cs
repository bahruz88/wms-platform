namespace Wms.Common.Domain;

/// <summary>Optimistic concurrency via <c>row_version</c> (spec §6.2, §13.5).</summary>
public interface IVersioned
{
    uint RowVersion { get; }

    void BumpVersion();
}
