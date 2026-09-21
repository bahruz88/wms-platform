namespace Wms.Common.Application.Paging;

/// <summary>Paging input (spec §13.4). Size is clamped to <see cref="MaxSize"/>.</summary>
public sealed record PageRequest
{
    public const int DefaultSize = 50;
    public const int MaxSize = 200;

    public PageRequest(int page = 1, int size = DefaultSize)
    {
        Page = Math.Max(1, page);
        Size = Math.Clamp(size, 1, MaxSize);
    }

    public int Page { get; }

    public int Size { get; }

    public int Skip => (Page - 1) * Size;

    public static PageRequest Default => new();
}
