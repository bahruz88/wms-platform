using Wms.Common.Domain;

namespace Wms.MasterData.Domain;

public static class MasterDataErrors
{
    public static Error InvalidProduct(string reason) => new("INVALID_PRODUCT", reason, 422);

    public static Error InvalidUom(string reason) => new("INVALID_UOM", reason, 422);

    public static Error InvalidLocation(string reason) => new("INVALID_LOCATION", reason, 422);

    public static Error InvalidSupplier(string reason) => new("INVALID_SUPPLIER", reason, 422);

    public static Error InvalidFactor(string reason) => new("INVALID_FACTOR", reason, 422);

    public static Error ProductNotFound(uint productId) => new("PRODUCT_NOT_FOUND", $"Product {productId} was not found.", 404);

    public static Error LocationNotFound(uint locationId) => new("LOCATION_NOT_FOUND", $"Location {locationId} was not found.", 404);

    public static Error NumberSequenceExhausted(string docType) =>
        new("NUMBER_SEQUENCE_EXHAUSTED", $"Number sequence for '{docType}' exceeded its padding width.", 409);
}
