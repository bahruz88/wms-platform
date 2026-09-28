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

A DTO with no same-named contract schema is skipped: not every DTO mirrors a schema one to one.
"""
from __future__ import annotations

import glob
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DTO_ROOT = ROOT / "mobile/packages/wms_api_client/lib/src/dto"

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


def contract_schemas(path: Path) -> dict[str, set[str]]:
    """
    Schema name -> every property name the schema carries, `allOf` bases included.

    The contracts build detail schemas on their summary: `GoodsReceipt` is `allOf: [GoodsReceiptSummary,
    {the extra fields}]`. Reading only the extension block makes `docNo` and `id` look invented by the
    DTO, which is how an earlier version of this script over-reported the damage.
    """
    own: dict[str, set[str]] = {}
    bases: dict[str, list[str]] = {}
    name: str | None = None
    props: set[str] = set()
    parents: list[str] = []
    in_props = False

    def flush() -> None:
        if name:
            own[name] = props
            bases[name] = parents

    for line in path.read_text(encoding="utf-8").split("\n"):
        m = re.match(r"^    (\w+):\s*$", line)
        if m:
            flush()
            name, props, parents, in_props = m.group(1), set(), [], False
            continue
        if name is None:
            continue
        # `- $ref: '#/components/schemas/X'` directly under allOf is a base schema.
        m = re.match(r"^\s+- \$ref: '#/components/schemas/(\w+)'\s*$", line)
        if m:
            parents.append(m.group(1))
            continue
        if re.match(r"^      properties:\s*$", line) or re.match(r"^          properties:\s*$", line):
            in_props = True
            continue
        m = re.match(r"^        (\w+):", line) or re.match(r"^            (\w+):", line)
        if m and in_props:
            props.add(m.group(1))
        if re.match(r"^[a-z]", line) and name:
            flush()
            name = None
    flush()

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

    json_serializable wraps a nullable field in `json['x'] == null ? null : …` and reads a required
    one directly. That distinction is the whole difference between a DTO that cannot parse a real
    response and one that merely carries a field nobody sends: a missing nullable key yields null,
    a missing required key throws.
    """
    text = path.read_text(encoding="utf-8")
    out: dict[str, tuple[set[str], set[str]]] = {}
    for m in re.finditer(r"_\$(\w+)FromJson\(Map<String, dynamic> json\) =>(.*?)\n\n", text, re.S):
        body = m.group(2)
        keys = set(re.findall(r"json\['(\w+)'\]", body))
        guarded = set(re.findall(r"json\['(\w+)'\] == null", body))
        if keys:
            out[m.group(1)] = (keys, keys - guarded)
    return out


def main() -> int:
    summary_only = "--summary" in sys.argv
    checked = broken = incomplete = 0
    findings: list[str] = []

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
            base = cls[:-3] if cls.endswith("Dto") else cls
            if base not in schemas:
                continue
            checked += 1
            ignored = sorted(schemas[base] - keys)
            invented = sorted(keys - schemas[base])
            # Only a *required* invented field breaks parsing; a nullable one just reads as null.
            fatal = sorted(required - schemas[base])
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
    )
    if findings and not summary_only:
        print()
        print("\n".join(findings))
    # Only BROKEN fails the check. A DTO that expects a field the contract never sends cannot parse
    # a real response at all — that is the bug this script was written for. Ignoring a field the
    # contract does send is usually just incomplete, and occasionally deliberate: `BalanceDto` drops
    # `qtyAvailable` because it recomputes it from the two numbers printed beside it.
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main())
