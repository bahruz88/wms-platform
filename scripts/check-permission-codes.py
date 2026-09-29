#!/usr/bin/env python3
"""Checks the client permission constants against the ones the contracts declare.

Why this exists
---------------
Every operation in the OpenAPI specs carries `x-permission`, and the server
enforces exactly that string. The clients keep their own copies — Dart's
`Permissions` class, the web's permission literals — and a copy that drifts does
not fail loudly: a permission nobody holds simply reads as denied. The screen
behind it hides, the menu tile never appears, and everything looks like a
deliberate access decision.

Four of the Dart constants had drifted this way. `proc.requisition.create` is
spelled `proc.pr.create`, `proc.rfq.manage` is `proc.rfq.create`,
`inv.stock_request.create` is `inv.request.create`, and price history is gated on
`master.product.view_cost` rather than a permission of its own. A buyer's menu
was therefore empty, and nothing anywhere said why.

    scripts/check-permission-codes.py            # report, exit 1 on a bad code
    scripts/check-permission-codes.py --summary  # counts only

A constant whose value is not in any contract is an error. A contract permission
no client names is only listed: most are server-side or web-only, and the mobile
app is not meant to cover all 100.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
SPEC_DIR = ROOT / "contracts/openapi"
DART_PERMISSIONS = ROOT / "mobile/packages/wms_core/lib/src/auth/permissions.dart"

# Roles are Keycloak realm roles, not permissions; they live in the same file.
ROLES_MARKER = "abstract final class Roles"


def contract_permissions() -> dict[str, list[str]]:
    """`x-permission` -> the operations that carry it."""
    found: dict[str, list[str]] = {}
    for spec in sorted(SPEC_DIR.glob("*.v1.yaml")):
        doc = yaml.safe_load(spec.read_text(encoding="utf-8")) or {}
        for path, item in (doc.get("paths") or {}).items():
            if not isinstance(item, dict):
                continue
            for method, operation in item.items():
                if not isinstance(operation, dict):
                    continue
                code = operation.get("x-permission")
                if isinstance(code, str) and code:
                    found.setdefault(code, []).append(
                        f"{method.upper()} {spec.stem.split('.')[0]}{path}"
                    )
    return found


def dart_constants() -> dict[str, str]:
    """Constant name -> its permission string, from the `Permissions` class."""
    source = DART_PERMISSIONS.read_text(encoding="utf-8")
    body = source.split(ROLES_MARKER)[0]
    return {
        match.group(1): match.group(2)
        for match in re.finditer(r"static const String (\w+) = '([^']+)';", body)
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()

    declared = contract_permissions()
    constants = dart_constants()

    unknown = {
        name: code for name, code in constants.items() if code not in declared
    }
    named = set(constants.values())
    unused = sorted(code for code in declared if code not in named)

    print(
        f"Dart constants: {len(constants)}"
        f"   matching a contract: {len(constants) - len(unknown)}"
        f"   unknown: {len(unknown)}"
        f"   contract permissions the app does not name: {len(unused)}"
    )
    if unknown and not args.summary:
        print()
        print("  No operation in any contract asks for these — they can only")
        print("  ever read as denied:")
        for name, code in sorted(unknown.items()):
            print(f"      {name:24} {code}")
    if unused and not args.summary:
        print()
        print("  Declared by a contract, not named by the mobile app (most are")
        print("  server-side or web-only; listed so the gap is visible):")
        for code in unused:
            print(f"      {code}")
    return 1 if unknown else 0


if __name__ == "__main__":
    sys.exit(main())
