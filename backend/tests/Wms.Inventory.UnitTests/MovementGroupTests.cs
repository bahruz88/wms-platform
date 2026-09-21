using Wms.Inventory.Domain.Entities;
using Wms.Inventory.Domain.Enums;

namespace Wms.Inventory.UnitTests;

/// <summary>ADR-003 / spec §12.3: every document balances to zero.</summary>
public sealed class MovementGroupTests
{
    private const uint TenantId = 1;
    private const uint SupplierLocation = 900;
    private const uint Warehouse = 10;
    private const uint ProductId = 55;
    private const ushort BaseUom = 1;

    private static MovementGroupHeader Header(DocType docType = DocType.Receipt) => new(
        TenantId,
        docType,
        "GR-2026-00001",
        new DateOnly(2026, 9, 21),
        new DateTimeOffset(2026, 9, 21, 10, 0, 0, TimeSpan.Zero),
        PostedBy: 7,
        IdempotencyKey: Guid.Parse("11111111-1111-1111-1111-111111111111"));

    private static MovementLineInput Line(uint locationId, decimal enteredQty, decimal rate = 1m, long? batchId = null, decimal? unitCost = null) =>
        new(ProductId, locationId, batchId, enteredQty, BaseUom, rate, BaseUom, 3, unitCost);

    [Fact]
    public void Create_accepts_a_balanced_receipt()
    {
        var result = MovementGroup.Create(Header(), [Line(SupplierLocation, -100m), Line(Warehouse, 100m)]);

        Assert.True(result.IsSuccess);
        Assert.Equal(0m, result.Value.SumQtyBase());
        Assert.Equal(2, result.Value.Lines.Count);
        Assert.Equal((ushort)1, result.Value.Lines[0].LineNo);
        Assert.Equal((ushort)2, result.Value.Lines[1].LineNo);
    }

    [Fact]
    public void Create_rejects_an_unbalanced_group()
    {
        var result = MovementGroup.Create(Header(), [Line(SupplierLocation, -100m), Line(Warehouse, 90m)]);

        Assert.True(result.IsFailure);
        Assert.Equal("UNBALANCED_MOVEMENT_GROUP", result.Error.Code);
        Assert.Equal(422, result.Error.Status);
    }

    [Fact]
    public void Create_rejects_a_group_with_fewer_than_two_lines()
    {
        var result = MovementGroup.Create(Header(), [Line(Warehouse, 100m)]);

        Assert.True(result.IsFailure);
        Assert.Equal("EMPTY_MOVEMENT_GROUP", result.Error.Code);
    }

    [Fact]
    public void Create_rejects_a_line_that_rounds_to_zero()
    {
        // 0.0001 × 0.001 = 0.0000001 → rounds to 0.000 at 3 decimals.
        var result = MovementGroup.Create(Header(), [Line(SupplierLocation, -0.0001m, 0.001m), Line(Warehouse, 0.0001m, 0.001m)]);

        Assert.True(result.IsFailure);
        Assert.Equal("ZERO_QUANTITY_LINE", result.Error.Code);
    }

    [Fact]
    public void Create_balances_after_rounding_not_before()
    {
        // Both sides are rounded identically, so the group still sums to zero.
        var result = MovementGroup.Create(Header(), [Line(SupplierLocation, -2m, 0.3333m), Line(Warehouse, 2m, 0.3333m)]);

        Assert.True(result.IsSuccess);
        Assert.Equal(0m, result.Value.SumQtyBase());
        Assert.Equal(-0.667m, result.Value.Lines[0].QtyBase);
        Assert.Equal(0.667m, result.Value.Lines[1].QtyBase);
    }

    [Fact]
    public void Create_freezes_the_conversion_rate_on_each_line()
    {
        var result = MovementGroup.Create(Header(), [Line(SupplierLocation, -3m, 12m), Line(Warehouse, 3m, 12m)]);

        Assert.True(result.IsSuccess);
        Assert.All(result.Value.Lines, line => Assert.Equal(12m, line.ConversionRate));
        Assert.All(result.Value.Lines, line => Assert.Equal(3m, Math.Abs(line.EnteredQty)));
        Assert.Equal(36m, result.Value.Lines[1].QtyBase);
    }

    [Fact]
    public void Create_requires_an_idempotency_key()
    {
        var header = Header() with { IdempotencyKey = Guid.Empty };

        var result = MovementGroup.Create(header, [Line(SupplierLocation, -1m), Line(Warehouse, 1m)]);

        Assert.True(result.IsFailure);
    }

    [Fact]
    public void BuildReversal_inverts_every_line_and_still_balances()
    {
        var original = MovementGroup.Create(Header(), [Line(SupplierLocation, -100m), Line(Warehouse, 100m)]).Value;

        var reversal = original.BuildReversal(
            "GR-2026-00001-R",
            new DateOnly(2026, 9, 22),
            new DateTimeOffset(2026, 9, 22, 8, 0, 0, TimeSpan.Zero),
            postedBy: 7,
            idempotencyKey: Guid.Parse("22222222-2222-2222-2222-222222222222"),
            reasonCodeId: 4,
            note: "wrong supplier");

        Assert.True(reversal.IsSuccess);
        Assert.Equal(DocType.Reversal, reversal.Value.DocType);
        Assert.Equal(0m, reversal.Value.SumQtyBase());
        Assert.Equal(100m, reversal.Value.Lines[0].QtyBase);
        Assert.Equal(-100m, reversal.Value.Lines[1].QtyBase);
        Assert.Equal((ushort)4, reversal.Value.ReasonCodeId);
    }

    [Theory]
    [InlineData(DocType.Waste)]
    [InlineData(DocType.Sample)]
    [InlineData(DocType.CountAdjust)]
    [InlineData(DocType.Transfer)]
    public void Every_document_type_obeys_the_same_zero_sum_rule(DocType docType)
    {
        // Spec §12.3: waste and AQTA samples are ledger entries, not columns outside the calculation.
        var result = MovementGroup.Create(Header(docType), [Line(Warehouse, -5m), Line(SupplierLocation, 5m)]);

        Assert.True(result.IsSuccess);
        Assert.Equal(0m, result.Value.SumQtyBase());
    }
}
