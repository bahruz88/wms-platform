namespace Wms.Common.Domain;

/// <summary>
/// Business error. <see cref="Code"/> is the machine readable RFC 7807 <c>code</c> extension
/// (e.g. <c>INSUFFICIENT_STOCK</c>), <see cref="Status"/> the HTTP status to map to.
/// </summary>
public sealed record Error(
    string Code,
    string Message,
    int Status,
    IReadOnlyDictionary<string, string[]>? Details = null)
{
    public static readonly Error None = new(string.Empty, string.Empty, 200);
}
