using Wms.Common.Domain;
using Wms.MasterData.Domain.Entities;
using Wms.MasterData.Domain.Enums;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Batch and expiry tracking cannot be set independently.
///
/// The expiry date is stored on the batch row, and a goods receipt creates one only when a batch
/// number is supplied. So `requires_expiry` without `requires_batch` made posting demand a date it
/// then discarded: nothing reached <c>inv_batch</c>, the expiry scanner never saw the item, and
/// «days to expiry» stayed empty on a product whose whole point was that it expires.
/// </summary>
public sealed class ProductTests
{
    private static readonly DateOnly ValidFrom = new(2026, 1, 1);

    private static Result<Product> NewProduct(bool requiresBatch, bool requiresExpiry) =>
        Product.Create(
            1,
            "CHK-001",
            "Toyuq döşü",
            categoryId: 7,
            baseUomId: 3,
            ValidFrom,
            requiresBatch: requiresBatch,
            requiresExpiry: requiresExpiry);

    [Fact]
    public void Expiry_tracking_without_batch_tracking_is_refused_at_creation()
    {
        var result = NewProduct(requiresBatch: false, requiresExpiry: true);

        Assert.True(result.IsFailure);
        Assert.Equal("EXPIRY_NEEDS_BATCH", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Theory]
    [InlineData(false, false)]
    [InlineData(true, false)]
    [InlineData(true, true)]
    public void The_other_three_combinations_are_accepted(bool requiresBatch, bool requiresExpiry)
    {
        var result = NewProduct(requiresBatch, requiresExpiry);

        Assert.True(result.IsSuccess);
        Assert.Equal(requiresBatch, result.Value.RequiresBatch);
        Assert.Equal(requiresExpiry, result.Value.RequiresExpiry);
    }

    [Fact]
    public void Expiry_tracking_cannot_be_switched_on_without_batch_tracking()
    {
        var product = NewProduct(requiresBatch: true, requiresExpiry: true).Value;

        var result = product.SetTraceability(requiresBatch: false, requiresExpiry: true);

        Assert.True(result.IsFailure);
        Assert.Equal("EXPIRY_NEEDS_BATCH", result.Error.Code);
        // The refusal leaves the product as it was, rather than half-applying the change.
        Assert.True(product.RequiresBatch);
        Assert.True(product.RequiresExpiry);
    }

    [Fact]
    public void Dropping_both_together_is_allowed()
    {
        var product = NewProduct(requiresBatch: true, requiresExpiry: true).Value;

        var result = product.SetTraceability(requiresBatch: false, requiresExpiry: false);

        Assert.True(result.IsSuccess);
        Assert.False(product.RequiresBatch);
        Assert.False(product.RequiresExpiry);
    }
}
