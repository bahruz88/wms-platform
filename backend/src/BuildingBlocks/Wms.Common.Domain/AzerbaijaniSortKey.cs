using System.Text;

namespace Wms.Common.Domain;

/// <summary>
/// Builds <c>master_product.name_sort_key</c>. MySQL has no <c>az</c> collation and the Turkish one mishandles <c>ə</c>
/// (spec §6.4), so each letter of the Azerbaijani alphabet is mapped to a two-character ordinal that sorts
/// byte-wise in the correct order: a b c ç d e ə f g ğ h x ı i j k q l m n o ö p r s ş t u ü v y z.
/// </summary>
public static class AzerbaijaniSortKey
{
    public const int MaxLength = 250;

    private static readonly string[] Alphabet =
    [
        "a", "b", "c", "ç", "d", "e", "ə", "f", "g", "ğ", "h", "x", "ı", "i", "j", "k", "q",
        "l", "m", "n", "o", "ö", "p", "r", "s", "ş", "t", "u", "ü", "v", "y", "z",
    ];

    private static readonly Dictionary<char, string> Order = BuildOrder();

    public static string Create(string name)
    {
        ArgumentNullException.ThrowIfNull(name);
        var builder = new StringBuilder(name.Length * 2);
        foreach (var rune in name.Trim().ToLowerInvariant())
        {
            if (Order.TryGetValue(rune, out var mapped))
            {
                builder.Append(mapped);
            }
            else if (char.IsAsciiDigit(rune))
            {
                // Digits sort before letters.
                builder.Append('0').Append(rune);
            }
            else if (char.IsWhiteSpace(rune))
            {
                builder.Append("  ");
            }

            if (builder.Length >= MaxLength)
            {
                break;
            }
        }

        var result = builder.ToString();
        return result.Length > MaxLength ? result[..MaxLength] : result;
    }

    private static Dictionary<char, string> BuildOrder()
    {
        var order = new Dictionary<char, string>();
        for (var i = 0; i < Alphabet.Length; i++)
        {
            // 'A' + index keeps the mapping inside printable ASCII and byte-comparable.
            var code = (char)('A' + i);
            var letter = Alphabet[i][0];
            order[letter] = string.Concat("A", code);
        }

        return order;
    }
}
