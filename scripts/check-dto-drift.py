#!/usr/bin/env python3
"""Compares the mobile DTOs' JSON field names against the OpenAPI contracts.

Why this exists
---------------
The Dart DTOs under `mobile/packages/wms_api_client/lib/src/dto/` are hand-written, and their unit
tests validate them against hand-written fixtures. When a DTO and the contract disagree, both agree
with each other and the suite stays green while the client cannot parse a single real response —
which is exactly what happened: `BalanceDto` expected a flat `productId` where the server sends a
nested `product` object, and 266 passing tests said nothing.

This check reads the field names the contract declares and the field names the generated
`*.g.dart` serializers actually read, and reports the difference. It is the guard the fixtures
cannot be.

    scripts/check-dto-drift.py            # report, exit 1 on a BROKEN dto
    scripts/check-dto-drift.py --summary  # counts only

Two kinds of difference, and only one of them fails the check:

  BROKEN      the DTO expects a field the contract never sends. `fromJson` throws on a real
              response, so the screen behind it cannot work at all.
  incomplete  the contract sends a field the DTO ignores. Usually just unfinished; sometimes
              deliberate, as when a DTO recomputes a derived value instead of trusting it.

A DTO with no same-named contract schema is skipped, but it is now *counted and listed* — that
silence is how `CurrentUserDto` shipped unable to parse `/identity/me` at all: the schema behind it
is called `Me`, so the name never matched and the DTO was never checked. `ALIASES` maps the ones
that legitimately differ; anything left in the unmatched list is unverified, not verified.

Some fields are sent by the server but absent from the contract. Those are contract defects, not DTO
defects, and `DIVERGENCES` marks them so they read as known rather than as a DTO inventing a field.
"""
from __future__ import annotations

import glob
import re
import sys

import yaml
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DTO_ROOT = ROOT / "mobile/packages/wms_api_client/lib/src/dto"

# Dart class -> contract schema, where the two legitimately carry different names. Without a mapping
# the DTO is silently unchecked, which is how `CurrentUserDto` shipped unable to parse `/identity/me`.
ALIASES = {
    "CurrentUserDto": "Me",
    "UpdateRecipeRequest": "RecipeUpdate",
    "ConfirmIssueLine": "IssueConfirmLine",
    "ConfirmIssueRequest": "IssueConfirmReceipt",
    "CreateCountRequest": "CountCreate",
    "CreateIssueLine": "IssueLineCreate",
    "CreateIssueRequest": "IssueCreate",
    "CreateWasteLine": "WasteLineCreate",
    "CreateWasteRequest": "WasteCreate",
    "CreateSampleRequest": "SampleCreate",
    "EnterCountLine": "CountLineInput",
    "EnterCountRequest": "CountLinesSubmit",
    "ProductCategoryDto": "Category",
    "PriceHistoryDto": "PriceHistoryEntry",
    "SeriesPointDto": "DashboardSeriesPoint",
    "QuantityInput": "Quantity",
    # A sample is a waste document with an authority attached, so it reuses the waste line schemas
    # rather than declaring its own.
    "SampleLineDto": "WasteLine",
    "CreateSampleLine": "WasteLineCreate",
}

# DTOs that mirror an inline schema with no name of its own, so there is nothing to compare against.
# Listing them here keeps them out of the unchecked report without pretending they were verified.
INLINE = {
    # `SalesImportParseResult.parseErrors[]` is declared inline.
    "SalesParseErrorDto",
    # `Batch.byLocation[]` is declared inline.
    "BatchLocationQtyDto",
}

# Where the running server and the contract disagree. These are contract defects, not DTO defects,
# so they are excluded from both directions: a field only the server sends would read as the DTO
# inventing one, and a field only the contract declares as the DTO ignoring one. Keyed by
# `module/DartClass`.
DIVERGENCES: dict[str, set[str]] = {
    # Empty on purpose. The one entry that lived here — `inv_batch` answering with `totalQtyOnHand`
    # and `byLocation` where the contract said `qtyOnHand` and `balances` — was a contract defect,
    # and the contract was corrected rather than kept as a permanent exception.
}

# Fields a DTO drops on purpose, with the reason. Anything not listed here is an oversight.
DELIBERATE = {
    # Recomputed from the two numbers printed beside it, so the screen cannot show a total and an
    # available figure that disagree.
    "inventory/BalanceDto": {"qtyAvailable"},
}

# contract module -> DTO folder
MODULES = {
    "inventory": "inventory",
    "masterdata": "master_data",
    "procurement": "procurement",
    "identity": "identity",
    "consumption": "consumption",
    "documents": "documents",
    "notifications": "notifications",
    "reporting": "reporting",
}


def _ref_name(ref: object) -> str | None:
    """`'common.v1.yaml#/components/schemas/PageMeta'` -> `'PageMeta'`."""
    if not isinstance(ref, str):
        return None
    marker = "#/components/schemas/"
    return ref.rsplit(marker, 1)[1] if marker in ref else None


def _parse(path: Path, own: dict[str, set[str]], bases: dict[str, list[str]]) -> None:
    """Reads one contract file's `components.schemas` into the shared `own`/`bases` pools.

    Parsed as YAML rather than scanned line by line. An earlier version matched `$ref` and property
    names by indentation, which cannot tell a base schema from an array's item type or an inline
    object's keys — so `UnreadCount.bySeverity`'s three severity names were reported as top-level
    fields the DTO ignored, and a document was reported as ignoring the fields only its lines carry.
    """
    doc = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    schemas = (doc.get("components") or {}).get("schemas") or {}

    for name, schema in schemas.items():
        if not isinstance(schema, dict):
            continue
        props: set[str] = set()
        parents: list[str] = []

        # A schema is either built from `allOf`, or an alias for another schema, or plain.
        blocks = schema.get("allOf") if isinstance(schema.get("allOf"), list) else [schema]
        for block in blocks:
            if not isinstance(block, dict):
                continue
            base = _ref_name(block.get("$ref"))
            # An alias whose target is its own name is a module re-exporting a shared schema.
            if base and base != name:
                parents.append(base)
            if isinstance(block.get("properties"), dict):
                props |= set(block["properties"])

        # A bare alias adds nothing of its own, so it must not overwrite the real definition already
        # read from `common.v1.yaml`.
        if not props and not parents and name in own:
            continue
        own[name] = props
        bases[name] = parents


def contract_schemas(path: Path) -> dict[str, set[str]]:
    """
    Schema name -> every property name the schema carries, `allOf` bases included.

    The contracts build detail schemas on their summary: `GoodsReceipt` is `allOf: [GoodsReceiptSummary,
    {the extra fields}]`. Reading only the extension block makes `docNo` and `id` look invented by the
    DTO, which is how an earlier version of this script over-reported the damage.

    `common.v1.yaml` is parsed alongside the module, because a base a module only `$ref`s is
    otherwise an empty schema — which made `PageMeta`'s paging fields look invented.
    """
    own: dict[str, set[str]] = {}
    bases: dict[str, list[str]] = {}
    _parse(ROOT / "contracts/openapi/common.v1.yaml", own, bases)
    _parse(path, own, bases)

    def resolve(schema: str, seen: frozenset[str] = frozenset()) -> set[str]:
        if schema in seen or schema not in own:
            return set()
        out = set(own[schema])
        for base in bases.get(schema, []):
            out |= resolve(base, seen | {schema})
        return out

    resolved = {k: resolve(k) for k in own}
    return {k: v for k, v in resolved.items() if v}


def dart_dtos(path: Path) -> dict[str, tuple[set[str], set[str]]]:
    """
    Class name -> (every JSON key its `fromJson` reads, the subset it reads *unguarded*).

    The cast tells us whether a field is required. json_serializable emits `json['x'] as int` for a
    field that must be there and `json['x'] as int?` — often followed by `?? default` — for one that
    may be absent. A nested object reads as `Foo.fromJson(json['x'] as Map<String, dynamic>)` when
    required and `json['x'] == null ? null : …` when not.

    That distinction is the whole difference between a DTO that cannot parse a real response and one
    that merely carries a field nobody sends: a missing nullable key yields null, a missing required
    key throws.
    """
    text = path.read_text(encoding="utf-8")
    out: dict[str, tuple[set[str], set[str]]] = {}
    for m in re.finditer(r"_\$(\w+)FromJson\(Map<String, dynamic> json\) =>(.*?)\n\n", text, re.S):
        body = m.group(2)
        keys = set(re.findall(r"json\['(\w+)'\]", body))
        nullable: set[str] = set(re.findall(r"json\['(\w+)'\] == null", body))
        # `as <Type>?` — the trailing `?` is what makes the read safe.
        nullable |= set(re.findall(r"json\['(\w+)'\]\s*\)?\s*as [\w<>, ]*\?", body))
        if keys:
            out[m.group(1)] = (keys, keys - nullable)
    return out


def main() -> int:
    summary_only = "--summary" in sys.argv
    checked = broken = incomplete = 0
    findings: list[str] = []
    unmatched: list[str] = []

    for module, folder in MODULES.items():
        spec = ROOT / f"contracts/openapi/{module}.v1.yaml"
        if not spec.exists():
            print(f"error: contract not found: {spec}", file=sys.stderr)
            return 2
        schemas = contract_schemas(spec)
        generated = glob.glob(str(DTO_ROOT / folder / "*.g.dart"))
        if not generated:
            findings.append(f"  {module}: no DTO serializers under {folder}/ — run build_runner")
            continue

        for cls, (keys, required) in sorted(dart_dtos(Path(generated[0])).items()):
            base = ALIASES.get(cls) or (cls[:-3] if cls.endswith("Dto") else cls)
            if base not in schemas:
                if cls not in INLINE:
                    unmatched.append(f"{module}/{cls}")
                continue
            checked += 1
            diverged = DIVERGENCES.get(f"{module}/{cls}", set())
            ignored = sorted(schemas[base] - keys - diverged - DELIBERATE.get(f"{module}/{cls}", set()))
            invented = sorted(keys - schemas[base] - diverged)
            # Only a *required* invented field breaks parsing; a nullable one just reads as null.
            # A known server-vs-contract divergence is not the DTO's fault either way.
            fatal = sorted(required - schemas[base] - diverged)
            if not ignored and not invented:
                continue
            if fatal:
                broken += 1
            else:
                incomplete += 1
            findings.append(f"  {module}/{cls}")
            if fatal:
                findings.append(
                    f"      BROKEN — required fields the contract never sends: {', '.join(fatal)}"
                )
            for spare in (f for f in invented if f not in fatal):
                findings.append(f"      dead field — nullable, never sent: {spare}")
            if ignored:
                findings.append(f"      incomplete — the contract sends, the DTO ignores: {', '.join(ignored)}")

    print(
        f"DTOs mirroring a contract schema: {checked}"
        f"   in step: {checked - broken - incomplete}"
        f"   broken: {broken}   incomplete: {incomplete}"
        f"   unchecked: {len(unmatched)}"
    )
    if findings and not summary_only:
        print()
        print("\n".join(findings))
    if unmatched and not summary_only:
        print()
        print("  No contract schema of the same name — these are NOT checked by anything:")
        for name in sorted(unmatched):
            print(f"      {name}")
        print("  Add a mapping to ALIASES if the schema is simply named differently.")
    # Only BROKEN fails the check. A DTO that expects a field the contract never sends cannot parse
    # a real response at all — that is the bug this script was written for. Ignoring a field the
    # contract does send is usually just incomplete, and occasionally deliberate: `BalanceDto` drops
    # `qtyAvailable` because it recomputes it from the two numbers printed beside it.
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main())
