namespace Wms.Inventory.Domain.Enums;

/// <summary><c>master_product.issue_strategy</c> as consumed by the allocator (spec §12.4).</summary>
public enum IssueStrategy
{
    Fefo,
    Fifo,
}
