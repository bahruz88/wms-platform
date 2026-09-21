using Wms.Common.Domain;

namespace Wms.Consumption.Domain.Entities;

/// <summary>
/// <c>cons_sales_line</c> — one menu item sold on the business date. An unrecognised POS code is NOT dropped:
/// it is kept in <see cref="RawPosCode"/> with a null <see cref="MenuItemId"/> and counted as unmapped (invariant 5).
/// </summary>
public sealed class SalesLine : Entity<long>, ITenantEntity
{
    public const int RawPosCodeMaxLength = 64;

    private SalesLine()
    {
    }

    public uint TenantId { get; private set; }

    public long ImportId { get; private set; }

    public uint? MenuItemId { get; private set; }

    public string? RawPosCode { get; private set; }

    public decimal QtySold { get; private set; }

    public decimal? GrossAmount { get; private set; }

    public bool IsMapped => MenuItemId is not null;

    public static Result<SalesLine> Create(uint tenantId, uint? menuItemId, string? rawPosCode, decimal qtySold, decimal? grossAmount)
    {
        if (qtySold <= 0m)
        {
            return ConsumptionErrors.InvalidSalesLine("qty_sold must be positive.");
        }

        if (menuItemId is null or 0 && string.IsNullOrWhiteSpace(rawPosCode))
        {
            return ConsumptionErrors.InvalidSalesLine("A sales line needs either a menu item or a POS code.");
        }

        var normalizedPos = string.IsNullOrWhiteSpace(rawPosCode) ? null : rawPosCode.Trim();
        if (normalizedPos is { Length: > RawPosCodeMaxLength })
        {
            normalizedPos = normalizedPos[..RawPosCodeMaxLength];
        }

        return new SalesLine
        {
            TenantId = tenantId,
            MenuItemId = menuItemId is 0 ? null : menuItemId,
            RawPosCode = normalizedPos,
            QtySold = qtySold,
            GrossAmount = grossAmount,
        };
    }
}
