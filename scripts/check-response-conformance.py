#!/usr/bin/env python3
"""Validates what the running gateway actually answers against the OpenAPI contracts.

Why this exists
---------------
CI lints the contracts and validates that they are well-formed OpenAPI. Nothing checked that the
server obeys them, and it did not: `GET /inventory/batches` answers with `totalQtyOnHand` and
`byLocation` where the contract said `qtyOnHand` and `balances`. Every layer downstream agreed with
the contract and so rendered an empty column — the web batch list showed no quantity at all, for
months, with a passing type check and a passing test suite, because a wrong field name reads as
`undefined` rather than as an error.

`check-dto-drift.py` compares the mobile DTOs against the contract. This compares the *server*
against the contract, which is the other half of the same question.

    scripts/check-response-conformance.py                 # every GET the script can reach
    scripts/check-response-conformance.py --module inventory
    scripts/check-response-conformance.py --summary

Exit code 1 when a response violates the contract. What counts as a violation:

  missing      a property the schema marks `required` is absent from the response
  undeclared   a property the response carries that the schema does not declare — the batch case
  type         a value whose JSON type the schema does not allow
  decimal      a decimal sent as a JSON number instead of a string (ADR-008): `double` rounding is
               exactly what the string form exists to prevent, so this is a real defect and not a
               formatting preference
  enum         a value outside the schema's enum

Only GETs are exercised, and only those whose path parameters can be filled from a list endpoint —
a POST would write to the database. The report says how many operations were reached and why each
skipped one was skipped, so the coverage is never overstated.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parent.parent
SPEC_DIR = ROOT / "contracts/openapi"
MODULES = [
    "identity",
    "masterdata",
    "inventory",
    "procurement",
    "documents",
    "notifications",
    "reporting",
]

DEFAULT_GATEWAY = "http://localhost:5001"
DEFAULT_KEYCLOAK = "http://localhost:8180"


# --------------------------------------------------------------------------- spec loading


class Specs:
    """Every module spec plus `common.v1.yaml`, with `$ref` resolution across files."""

    def __init__(self) -> None:
        self._files: dict[str, dict[str, Any]] = {}
        for path in SPEC_DIR.glob("*.v1.yaml"):
            self._files[path.name] = yaml.safe_load(path.read_text(encoding="utf-8")) or {}

    def doc(self, module: str) -> dict[str, Any]:
        return self._files[f"{module}.v1.yaml"]

    def resolve(self, schema: Any, current: str) -> Any:
        """Follows `$ref` until a concrete schema is reached.

        A ref is either local (`#/components/schemas/X`) or points at another file
        (`common.v1.yaml#/...`, `./common.v1.yaml#/...`), which is how every module reuses `Decimal`,
        `PageMeta` and `AuditFields`.
        """
        seen = 0
        while isinstance(schema, dict) and "$ref" in schema:
            seen += 1
            if seen > 50:
                raise RecursionError("$ref cycle")
            ref = schema["$ref"]
            file_part, _, pointer = ref.partition("#")
            doc_name = current
            if file_part:
                doc_name = file_part.lstrip("./")
            doc = self._files.get(doc_name)
            if doc is None:
                return {}
            node: Any = doc
            for part in pointer.strip("/").split("/"):
                if not isinstance(node, dict) or part not in node:
                    return {}
                node = node[part]
            schema, current = node, doc_name
        return schema


# --------------------------------------------------------------------------- validation

# `Decimal`, `Money`, `Quantity`, `Percent` and the rest are all strings carrying a number.
DECIMAL_PATTERN = re.compile(r"^-?\d+(\.\d{1,8})?$")

JSON_TYPES = {
    "object": dict,
    "array": list,
    "string": str,
    "boolean": bool,
    # `bool` is a subclass of `int`, so an integer check must exclude it explicitly.
    "integer": int,
    "number": (int, float),
    "null": type(None),
}


def _types_of(schema: dict[str, Any]) -> list[str]:
    declared = schema.get("type")
    if declared is None:
        return []
    return [declared] if isinstance(declared, str) else list(declared)


def _matches_type(value: Any, name: str) -> bool:
    expected = JSON_TYPES.get(name)
    if expected is None:
        return True
    if name in ("integer", "number") and isinstance(value, bool):
        return False
    return isinstance(value, expected)


class Validator:
    """Walks a response against a schema and collects violations as `(kind, path, detail)`."""

    def __init__(self, specs: Specs, module: str) -> None:
        self.specs = specs
        self.doc_name = f"{module}.v1.yaml"
        self.problems: list[tuple[str, str, str]] = []

    def check(
        self,
        value: Any,
        schema: Any,
        path: str = "",
        doc: str | None = None,
        *,
        undeclared: bool = True,
    ) -> None:
        """`undeclared=False` while walking an `allOf` member, because each member declares only its
        own slice of the properties and would otherwise report its siblings' as undeclared."""
        doc = doc or self.doc_name
        schema = self.specs.resolve(schema, doc)
        if not isinstance(schema, dict) or not schema:
            return

        # A `oneOf`/`anyOf` passes when any branch does, which is how the contracts spell "nullable":
        # `oneOf: [Decimal, null]`. Reporting every branch's complaint would be noise.
        for combinator in ("oneOf", "anyOf"):
            branches = schema.get(combinator)
            if isinstance(branches, list):
                for branch in branches:
                    probe = Validator(self.specs, self.doc_name.removesuffix(".v1.yaml"))
                    probe.check(value, branch, path, doc, undeclared=undeclared)
                    if not probe.problems:
                        return
                self.problems.append(
                    (
                        "type",
                        path,
                        f"no {combinator} branch accepts {type(value).__name__}",
                    )
                )
                return

        if isinstance(schema.get("allOf"), list):
            for part in schema["allOf"]:
                self.check(value, part, path, doc, undeclared=False)
            # The undeclared-key check needs the union of every member's properties, so it runs once
            # here rather than inside each member.
            if undeclared:
                self._undeclared(value, self._union_properties(schema, doc), path)
            return

        types = _types_of(schema)
        if types and not any(_matches_type(value, t) for t in types):
            self.problems.append(
                ("type", path, f"expected {'|'.join(types)}, got {type(value).__name__}")
            )
            return

        enum = schema.get("enum")
        if enum is not None and value not in enum:
            self.problems.append(("enum", path, f"{value!r} not in {enum}"))
            return

        if isinstance(value, str) and schema.get("pattern") == DECIMAL_PATTERN.pattern:
            if not DECIMAL_PATTERN.match(value):
                self.problems.append(("type", path, f"{value!r} is not a decimal string"))
        elif isinstance(value, (int, float)) and not isinstance(value, bool):
            if schema.get("pattern") == DECIMAL_PATTERN.pattern:
                self.problems.append(
                    ("decimal", path, f"{value!r} sent as a JSON number; ADR-008 requires a string")
                )

        if isinstance(value, dict):
            self._object(value, schema, path, doc, undeclared=undeclared)
        elif isinstance(value, list):
            items = schema.get("items")
            if items is not None:
                for i, entry in enumerate(value):
                    self.check(entry, items, f"{path}[{i}]", doc)

    def _union_properties(self, schema: dict[str, Any], doc: str) -> set[str]:
        """Property names an `allOf` schema carries, its bases included."""
        out: set[str] = set()
        for part in schema.get("allOf", []):
            resolved = self.specs.resolve(part, doc)
            if not isinstance(resolved, dict):
                continue
            if isinstance(resolved.get("properties"), dict):
                out |= set(resolved["properties"])
            if isinstance(resolved.get("allOf"), list):
                out |= self._union_properties(resolved, doc)
        return out

    def _object(
        self,
        value: dict[str, Any],
        schema: dict[str, Any],
        path: str,
        doc: str,
        *,
        undeclared: bool = True,
    ) -> None:
        properties = schema.get("properties")
        if isinstance(properties, dict):
            for name in schema.get("required", []):
                if name not in value:
                    self.problems.append(("missing", f"{path}.{name}", "required but absent"))
            for name, entry in value.items():
                if name in properties:
                    self.check(entry, properties[name], f"{path}.{name}", doc)
            if undeclared:
                self._undeclared(value, set(properties), path, schema)

    def _undeclared(
        self,
        value: Any,
        declared: set[str],
        path: str,
        schema: dict[str, Any] | None = None,
    ) -> None:
        if not isinstance(value, dict) or not declared:
            return
        # A schema that opts into free-form keys cannot have undeclared ones.
        if schema is not None and schema.get("additionalProperties") not in (None, False):
            return
        for name in sorted(set(value) - declared):
            self.problems.append(("undeclared", f"{path}.{name}", "the contract does not declare it"))


# --------------------------------------------------------------------------- the gateway


def sign_in(keycloak: str, username: str, password: str) -> str:
    body = urllib.parse.urlencode(
        {
            "grant_type": "password",
            "client_id": "wms-web",
            "scope": "openid",
            "username": username,
            "password": password,
        }
    ).encode()
    url = f"{keycloak}/realms/wms/protocol/openid-connect/token"
    with urllib.request.urlopen(urllib.request.Request(url, data=body), timeout=30) as response:
        return json.load(response)["access_token"]


def get(gateway: str, path: str, token: str) -> tuple[int, Any]:
    request = urllib.request.Request(
        f"{gateway}{path}", headers={"Authorization": f"Bearer {token}"}
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            raw = response.read()
            return response.status, (json.loads(raw) if raw else None)
    except urllib.error.HTTPError as error:
        raw = error.read()
        try:
            return error.code, json.loads(raw) if raw else None
        except json.JSONDecodeError:
            return error.code, None
    except urllib.error.URLError as error:
        return 0, str(error.reason)


# --------------------------------------------------------------------------- driving the specs


def response_schema(operation: dict[str, Any]) -> Any:
    responses = operation.get("responses") or {}
    for code in ("200", 200):
        ok = responses.get(code)
        if isinstance(ok, dict):
            content = ok.get("content") or {}
            payload = content.get("application/json")
            if isinstance(payload, dict):
                return payload.get("schema")
    return None


def path_params(specs: Specs, module: str, item: dict[str, Any], operation: dict[str, Any]) -> list[str]:
    names: list[str] = []
    for parameter in [*(item.get("parameters") or []), *(operation.get("parameters") or [])]:
        resolved = specs.resolve(parameter, f"{module}.v1.yaml")
        if isinstance(resolved, dict) and resolved.get("in") == "path":
            names.append(str(resolved.get("name")))
    return names


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gateway", default=DEFAULT_GATEWAY)
    parser.add_argument("--keycloak", default=DEFAULT_KEYCLOAK)
    parser.add_argument("--username", default="admin")
    parser.add_argument("--password", default="admin")
    parser.add_argument("--module", action="append", choices=MODULES)
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()

    specs = Specs()
    try:
        token = sign_in(args.keycloak, args.username, args.password)
    except Exception as error:  # noqa: BLE001 - the reason is what the operator needs
        print(f"error: sign-in against {args.keycloak} failed: {error}", file=sys.stderr)
        return 2

    checked = violating = 0
    skipped: list[str] = []
    findings: list[str] = []
    # Ids discovered from list responses, so `/{id}` operations can be reached too.
    known_ids: dict[str, int] = {}

    for module in args.module or MODULES:
        doc = specs.doc(module)
        base = (doc.get("servers") or [{}])[0].get("url", f"/api/v1/{module}")

        # Collection endpoints first: they are what supplies the ids for the detail endpoints.
        entries = sorted(
            (doc.get("paths") or {}).items(), key=lambda kv: ("{" in kv[0], kv[0])
        )
        for spec_path, item in entries:
            if not isinstance(item, dict):
                continue
            operation = item.get("get")
            if not isinstance(operation, dict):
                continue
            operation_id = operation.get("operationId", spec_path)
            schema = response_schema(operation)
            if schema is None:
                skipped.append(f"{module}/{operation_id}: no 200 application/json schema")
                continue

            url_path = spec_path
            unresolved = []
            for name in path_params(specs, module, item, operation):
                token_name = f"{{{name}}}"
                candidate = known_ids.get(f"{module}:{name}") or known_ids.get(name)
                if candidate is None:
                    unresolved.append(name)
                else:
                    url_path = url_path.replace(token_name, str(candidate))
            if unresolved:
                skipped.append(
                    f"{module}/{operation_id}: no id to fill {', '.join(unresolved)}"
                )
                continue

            status, body = get(args.gateway, f"{base}{url_path}", token)
            if status != 200:
                skipped.append(f"{module}/{operation_id}: answered {status}")
                continue

            checked += 1
            validator = Validator(specs, module)
            validator.check(body, schema, operation_id)
            if validator.problems:
                violating += 1
                findings.append(f"  {module}/{operation_id}  {base}{url_path}")
                # One complaint per shape, not per row: a list of 50 rows all missing the same field
                # is one defect, and printing it 50 times buries the next one.
                seen: dict[tuple[str, str, str], int] = {}
                for kind, where, detail in validator.problems:
                    key = (kind, re.sub(r"\[\d+\]", "[*]", where), detail)
                    seen[key] = seen.get(key, 0) + 1
                for (kind, where, detail), count in seen.items():
                    times = f"  (×{count})" if count > 1 else ""
                    findings.append(f"      {kind:10} {where}: {detail}{times}")

            # Remember ids so the detail endpoints below become reachable.
            items = body.get("items") if isinstance(body, dict) else body
            if isinstance(items, list) and items and isinstance(items[0], dict):
                first = items[0]
                if isinstance(first.get("id"), int):
                    known_ids.setdefault(f"{module}:id", first["id"])
                    known_ids.setdefault("id", first["id"])
                for key, value in first.items():
                    if key.endswith("Id") and isinstance(value, int):
                        known_ids.setdefault(f"{module}:{key}", value)

    print(
        f"GET operations reached: {checked}"
        f"   obeying the contract: {checked - violating}"
        f"   violating: {violating}"
        f"   unreachable: {len(skipped)}"
    )
    if findings and not args.summary:
        print()
        print("\n".join(findings))
    if skipped and not args.summary:
        print()
        print("  Not reached (a POST would write, or no id was available):")
        for line in sorted(skipped):
            print(f"      {line}")
    return 1 if violating else 0


if __name__ == "__main__":
    sys.exit(main())
