using Wms.Common.Domain;

namespace Wms.Common.Application.Dtos;

/// <summary>
/// <c>Money</c> of common.v1.yaml: <c>{ "amount": "1250.0000", "currency": "AZN" }</c>.
/// </summary>
/// <remarks>
/// The amount is a <see cref="decimal"/> so <c>DecimalStringJsonConverter</c> puts it on the wire as a
/// string (CONVENTIONS.md: no float ever touches a quantity or an amount). Endpoints that used to send and
/// accept a bare decimal for a <c>Money</c> field broke both clients — reading <c>.amount</c> off a string
/// yields <c>undefined</c> — so every monetary field declared as <c>Money</c> goes through this type.
/// </remarks>
public sealed record MoneyDto(decimal Amount, string Currency)
{
    public static MoneyDto? From(decimal? amount, string currency) =>
        amount is { } value ? new MoneyDto(value, currency) : null;

    public static MoneyDto Of(Money money) => new(money.Amount, money.Currency);
}
