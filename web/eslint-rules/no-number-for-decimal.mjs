/**
 * ADR-008 guard: quantity / money / rate fields arrive from the API as JSON strings
 * (`common.v1.yaml#/components/schemas/Decimal`) and are carried through the app as
 * `Decimal`-backed value objects. Typing such a field as `number` re-introduces exactly the
 * IEEE-754 rounding artefacts the contract exists to avoid (`-23.50999999999999`).
 *
 * The rule flags a TypeScript member declaration whose name contains a monetary or quantitative
 * word token when the annotation mentions `number` — directly, inside a union, or as an array
 * element type.
 *
 * Names are split into word tokens first, so `qtyBase`, `unit_price` and `totalAmount` are caught
 * while `lineCount`, `rateLimit` and a paging `total` are not: those are counts and limits, not
 * decimals.
 */

/** Word tokens that mark a decimal-carrying field. */
const DECIMAL_TOKENS = new Set([
  'qty',
  'quantity',
  'amount',
  'price',
  'cost',
  'subtotal',
  'vat',
  'balance',
  'rate',
  'fx',
]);

/** `value` and `total` are too generic on their own; they only count in these compounds. */
const COMPOUND_TOKENS = new Set(['value', 'total']);

/** Tokens that turn a match off: these names are counters or limits. */
const NEGATING_NEIGHBOURS = new Set(['count', 'limit', 'id', 'ids', 'pct', 'percent', 'days', 'no']);

function tokenize(name) {
  return name
    .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
    .replace(/[_-]+/g, ' ')
    .toLowerCase()
    .split(/\s+/)
    .filter(Boolean);
}

/** True when the member name denotes a decimal quantity or amount. */
export function isDecimalFieldName(name) {
  const tokens = tokenize(name);
  if (tokens.some((t) => NEGATING_NEIGHBOURS.has(t))) return false;
  if (tokens.some((t) => DECIMAL_TOKENS.has(t))) return true;
  // `value` / `total` only count when qualified: totalValue, varianceValue, lineTotal.
  return tokens.length > 1 && tokens.some((t) => COMPOUND_TOKENS.has(t));
}

function mentionsNumber(node) {
  if (!node) return false;
  switch (node.type) {
    case 'TSNumberKeyword':
      return true;
    case 'TSUnionType':
      return node.types.some(mentionsNumber);
    case 'TSArrayType':
      return mentionsNumber(node.elementType);
    case 'TSParenthesizedType':
      return mentionsNumber(node.typeAnnotation);
    default:
      return false;
  }
}

function memberName(node) {
  const key = node.key ?? node.id;
  if (!key) return null;
  if (key.type === 'Identifier') return key.name;
  if (key.type === 'Literal' && typeof key.value === 'string') return key.value;
  return null;
}

/** @type {import('eslint').Rule.RuleModule} */
const rule = {
  meta: {
    type: 'problem',
    docs: {
      description:
        'Quantity and money fields must not be typed as `number` — use Quantity/Money (decimal.js) or the contract string.',
    },
    schema: [],
    messages: {
      numberDecimal:
        '`{{name}}` carries a quantity or money value; `number` is forbidden by ADR-008. Use `Quantity`, `Money`, or the raw contract `string`.',
    },
  },
  create(context) {
    function check(node) {
      const name = memberName(node);
      if (!name || !isDecimalFieldName(name)) return;
      if (mentionsNumber(node.typeAnnotation?.typeAnnotation)) {
        context.report({ node, messageId: 'numberDecimal', data: { name } });
      }
    }

    return {
      TSPropertySignature: check,
      PropertyDefinition: check,
      TSParameterProperty(node) {
        check(node.parameter);
      },
    };
  },
};

export default rule;
