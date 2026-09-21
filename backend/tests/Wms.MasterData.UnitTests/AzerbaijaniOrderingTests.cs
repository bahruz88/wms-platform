using Wms.MasterData.Domain.Entities;

namespace Wms.MasterData.UnitTests;

/// <summary>
/// Spec §6.4: MySQL has no <c>az</c> collation, so <c>GET /masterdata/products</c> orders by the precomputed
/// <c>name_sort_key</c>. These tests pin the alphabet the key encodes:
/// a b c ç d e ə f g ğ h x ı i j k q l m n o ö p r s ş t u ü v y z.
/// </summary>
public sealed class AzerbaijaniOrderingTests
{
    private static readonly DateOnly ValidFrom = new(2026, 1, 1);

    private static Product Named(string name, string sku) =>
        Product.Create(1, sku, name, categoryId: 7, baseUomId: 1, ValidFrom).Value;

    [Fact]
    public void Products_sort_in_the_azerbaijani_alphabet_not_in_ordinal_order()
    {
        var products = new[]
        {
            Named("Zeytun", "P1"),
            Named("Çay", "P2"),
            Named("Ət", "P3"),
            Named("Alma", "P4"),
            Named("Kartof", "P5"),
            Named("Ərik", "P6"),
            Named("Şəkər", "P7"),
            Named("Süd", "P8"),
        };

        var ordered = products.OrderBy(p => p.NameSortKey, StringComparer.Ordinal).Select(p => p.Name).ToList();

        // a < ç < ə < k < s < ş < z, and inside 'ə' the second letter decides: r < t.
        Assert.Equal<string>(["Alma", "Çay", "Ərik", "Ət", "Kartof", "Süd", "Şəkər", "Zeytun"], ordered);
    }

    [Fact]
    public void The_sort_key_is_recomputed_on_rename()
    {
        var product = Named("Zeytun", "P1");
        var before = product.NameSortKey;

        Assert.True(product.Rename("Alma").IsSuccess);

        Assert.NotEqual(before, product.NameSortKey);
        Assert.True(string.CompareOrdinal(product.NameSortKey, before) < 0);
    }

    [Fact]
    public void The_name_is_trimmed_on_creation_and_rename()
    {
        var product = Named("   Toyuq döşü   ", "P1");

        Assert.Equal("Toyuq döşü", product.Name);

        Assert.True(product.Rename("  Toyuq budu  ").IsSuccess);
        Assert.Equal("Toyuq budu", product.Name);
    }

    [Fact]
    public void Digits_sort_before_letters()
    {
        var digit = Named("7UP", "P1");
        var letter = Named("Alma", "P2");

        Assert.True(string.CompareOrdinal(digit.NameSortKey, letter.NameSortKey) < 0);
    }
}
