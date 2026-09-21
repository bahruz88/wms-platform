using System.Text;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Wms.Common.Infrastructure.Persistence;

/// <summary>Maps C# PascalCase enum members to MySQL <c>ENUM('UPPER_SNAKE', ...)</c> values (spec §7-§11).</summary>
public static class UpperSnakeCaseEnum
{
    public static string ToUpperSnake(string pascalCase)
    {
        ArgumentNullException.ThrowIfNull(pascalCase);
        var builder = new StringBuilder(pascalCase.Length + 4);
        for (var i = 0; i < pascalCase.Length; i++)
        {
            var c = pascalCase[i];
            if (i > 0 && char.IsUpper(c))
            {
                builder.Append('_');
            }

            builder.Append(char.ToUpperInvariant(c));
        }

        return builder.ToString();
    }

    public static string Format<TEnum>(TEnum value)
        where TEnum : struct, Enum
        => Cache<TEnum>.ToName[value];

    public static TEnum Parse<TEnum>(string name)
        where TEnum : struct, Enum
        => Cache<TEnum>.FromName.TryGetValue(name, out var value)
            ? value
            : throw new ArgumentException($"'{name}' is not a value of {typeof(TEnum).Name}.", nameof(name));

    public static IReadOnlyList<string> Names<TEnum>()
        where TEnum : struct, Enum
        => Cache<TEnum>.Names;

    public static string ColumnType<TEnum>()
        where TEnum : struct, Enum
        => "enum(" + string.Join(",", Cache<TEnum>.Names.Select(n => "'" + n + "'")) + ")";

    private static class Cache<TEnum>
        where TEnum : struct, Enum
    {
        public static readonly Dictionary<TEnum, string> ToName =
            Enum.GetValues<TEnum>().ToDictionary(v => v, v => ToUpperSnake(v.ToString()));

        public static readonly Dictionary<string, TEnum> FromName =
            ToName.ToDictionary(kv => kv.Value, kv => kv.Key, StringComparer.Ordinal);

        public static readonly IReadOnlyList<string> Names = ToName.Values.ToList();
    }
}

public sealed class UpperSnakeCaseEnumConverter<TEnum>() : ValueConverter<TEnum, string>(
    value => UpperSnakeCaseEnum.Format(value),
    name => UpperSnakeCaseEnum.Parse<TEnum>(name))
    where TEnum : struct, Enum;

public static class MySqlEnumExtensions
{
    /// <summary>Stores the enum as a MySQL ENUM column with UPPER_SNAKE labels. Works for nullable enums as well.</summary>
    public static PropertyBuilder HasMySqlEnum<TEnum>(this PropertyBuilder builder)
        where TEnum : struct, Enum
    {
        ArgumentNullException.ThrowIfNull(builder);
        builder.HasConversion(new UpperSnakeCaseEnumConverter<TEnum>());
        builder.HasColumnType(UpperSnakeCaseEnum.ColumnType<TEnum>());
        return builder;
    }
}
