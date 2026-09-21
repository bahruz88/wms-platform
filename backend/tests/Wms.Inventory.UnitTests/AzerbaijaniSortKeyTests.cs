using Wms.Common.Domain;

namespace Wms.Inventory.UnitTests;

/// <summary>Spec §6.4: Azerbaijani alphabet ordering is computed in the application, not by a MySQL collation.</summary>
public sealed class AzerbaijaniSortKeyTests
{
    [Fact]
    public void Sort_key_orders_e_before_schwa_before_f()
    {
        var names = new[] { "Fıstıq", "Ət", "Ev" };

        var sorted = names.OrderBy(AzerbaijaniSortKey.Create, StringComparer.Ordinal).ToList();

        // a b c ç d e ə f ...  → Ev, Ət, Fıstıq
        Assert.Equal(["Ev", "Ət", "Fıstıq"], sorted);
    }

    [Fact]
    public void Sort_key_orders_dotless_i_before_dotted_i()
    {
        var names = new[] { "İnək", "Ilıq" };

        var sorted = names.OrderBy(AzerbaijaniSortKey.Create, StringComparer.Ordinal).ToList();

        Assert.Equal(["Ilıq", "İnək"], sorted);
    }

    [Fact]
    public void Sort_key_is_case_insensitive_and_trims()
    {
        Assert.Equal(AzerbaijaniSortKey.Create("  Çörək "), AzerbaijaniSortKey.Create("çörək"));
    }

    [Fact]
    public void Sort_key_never_exceeds_the_column_length()
    {
        var key = AzerbaijaniSortKey.Create(new string('ə', 400));

        Assert.True(key.Length <= AzerbaijaniSortKey.MaxLength);
    }
}
