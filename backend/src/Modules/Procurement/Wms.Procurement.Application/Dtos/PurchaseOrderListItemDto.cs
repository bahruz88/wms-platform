namespace Wms.Procurement.Application.Dtos;

public sealed record PurchaseOrderListItemDto(
    long Id,
    string DocNo,
    DateOnly DocDate,
    uint SupplierId,
    string Currency,
    decimal TotalAmount,
    decimal TotalAmountBase,
    string Status,
    uint DeliveryLocationId,
    DateOnly? ExpectedDate);
