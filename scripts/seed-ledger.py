#!/usr/bin/env python3
"""Grows `inv_movement` to the size SPEC §17.3 asks the load test to run against.

    scripts/seed-ledger.py --check                 # report only, write nothing
    scripts/seed-ledger.py --target 1000000        # add what is missing
    scripts/seed-ledger.py --target 1000000 --batch 20000

Why a tool rather than the API
------------------------------
The criterion needs 1 000 000 existing ledger rows, and the write rate it also specifies is
2 000 movements/hour — reaching a million that way would take five hundred hours. So the rows are
written directly, and the two invariants the ledger lives by are preserved deliberately:

  · every `movement_group` sums to exactly zero (ADR-003, spec §12.3). Rows are written in balanced
    pairs: a physical location gains what a virtual counter-account loses.
  · `inv_balance` is a projection of the ledger, never an independent number (ADR-004). After
    seeding, every balance row this tool touched is recomputed from the movements, so §12.2 — each
    balance row equals the sum of its ledger lines — still holds.

TEST ENVIRONMENTS ONLY. It writes to a live schema and the ledger is append-only: there is no undo.
The tool refuses to run unless `--i-know-this-is-a-test-database` is passed, or `WMS_ENV=test`.
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys

CONTAINER = os.environ.get("WMS_MYSQL_CONTAINER", "wms-mysql-1")
DATABASE = os.environ.get("WMS_DB_NAME", "wms")
TENANT = int(os.environ.get("WMS_TENANT_ID", "1"))

# The virtual counter-account every seeded pair balances against. `V_ADJUSTMENT` is the one that
# exists for exactly this purpose — a correction with no external counterparty (spec §12.3).
COUNTER_LOCATION_CODE = "V_ADJUSTMENT"


def sql(statement: str, *, read: bool = True) -> str:
    """Runs one statement through the MySQL container. Credentials stay in its environment."""
    flags = "-N -B" if read else "-B"
    result = subprocess.run(
        ["docker", "exec", "-e", "P=" + os.environ.get("WMS_DB_PASSWORD", "wms_root"), CONTAINER,
         "sh", "-c", f'mysql -uroot -p"$P" {DATABASE} {flags} -e {shell_quote(statement)}'],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        stderr = "\n".join(l for l in result.stderr.split("\n") if "Using a password" not in l)
        raise SystemExit(f"mysql failed:\n{stderr.strip()}")
    return result.stdout.strip()


def shell_quote(value: str) -> str:
    return "'" + value.replace("'", "'\\''") + "'"


def count(table: str) -> int:
    return int(sql(f"SELECT COUNT(*) FROM {table}") or 0)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--target", type=int, default=1_000_000, help="rows inv_movement should end up with")
    parser.add_argument("--batch", type=int, default=20_000, help="rows per INSERT … SELECT pass")
    parser.add_argument("--check", action="store_true", help="report only")
    parser.add_argument("--i-know-this-is-a-test-database", action="store_true", dest="confirmed")
    args = parser.parse_args()

    have = count("inv_movement")
    groups = count("inv_movement_group")
    print(f"inv_movement: {have:,}   inv_movement_group: {groups:,}   target: {args.target:,}")

    if have >= args.target:
        print("already at or above the target — nothing to do")
        return 0

    missing = args.target - have
    print(f"missing: {missing:,} rows ({missing // 2:,} balanced pairs)")

    if args.check:
        return 0

    if not (args.confirmed or os.environ.get("WMS_ENV") == "test"):
        print(
            "\nrefusing to write: pass --i-know-this-is-a-test-database or set WMS_ENV=test.\n"
            "The ledger is append-only (ADR-003); seeded rows cannot be deleted afterwards.",
            file=sys.stderr,
        )
        return 2

    product = sql(f"SELECT id FROM master_product WHERE tenant_id={TENANT} AND is_active=1 ORDER BY id LIMIT 1")
    base_uom = sql(f"SELECT base_uom_id FROM master_product WHERE id={product}")
    real_loc = sql(
        f"SELECT id FROM master_location WHERE tenant_id={TENANT} AND location_type='CENTRAL_WAREHOUSE' ORDER BY id LIMIT 1"
    )
    counter_loc = sql(
        f"SELECT id FROM master_location WHERE tenant_id={TENANT} AND code='{COUNTER_LOCATION_CODE}' LIMIT 1"
    )
    if not (product and real_loc and counter_loc):
        raise SystemExit(
            f"reference data missing: product={product!r} warehouse={real_loc!r} {COUNTER_LOCATION_CODE}={counter_loc!r}"
        )
    print(f"seeding product {product} between location {real_loc} and {COUNTER_LOCATION_CODE} ({counter_loc})")

    written = 0
    while written < missing:
        pairs = min(args.batch, missing - written) // 2
        if pairs <= 0:
            break
        group_id = seed_batch(int(product), int(base_uom), int(real_loc), int(counter_loc), pairs)
        written += pairs * 2
        print(f"  +{pairs * 2:,} rows (group {group_id})   total {have + written:,}")

    print("recomputing inv_balance from the ledger so §12.2 still holds…")
    recompute_balance(int(product), [int(real_loc), int(counter_loc)], int(base_uom))

    print(f"done: inv_movement {count('inv_movement'):,}")
    verify(int(product), [int(real_loc), int(counter_loc)])
    return 0


def seed_batch(product: int, base_uom: int, real_loc: int, counter_loc: int, pairs: int) -> int:
    """One group holding `pairs` balanced pairs. The group sums to zero by construction."""
    sql(
        f"""INSERT INTO inv_movement_group
              (tenant_id, doc_type, doc_no, doc_date, source_doc_type, source_doc_id,
               note, posted_at, posted_by, idempotency_key)
            VALUES ({TENANT}, 'OPENING', CONCAT('LOAD-', UUID_SHORT()), CURDATE(), 'LOAD_SEED', 0,
                    'scripts/seed-ledger.py — SPEC §17.3 load fixture', NOW(3), 1, UUID())""",
        read=False,
    )
    group_id = int(sql("SELECT LAST_INSERT_ID()"))

    # `seq` gives each pair its own line numbers without a temp table: two rows per pair, the
    # physical location gaining 1 and the counter-account losing 1, so the group nets to zero.
    sql(
        f"""INSERT INTO inv_movement
              (tenant_id, group_id, line_no, product_id, batch_id, location_id, qty_base,
               base_uom_id, entered_qty, entered_uom_id, conversion_rate, posted_at, posted_by)
            WITH RECURSIVE seq(n) AS (
              SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < {pairs}
            )
            SELECT {TENANT}, {group_id}, n * 2 - 1, {product}, NULL, {real_loc}, 1.0000,
                   {base_uom}, 1.0000, {base_uom}, 1.00000000, NOW(3), 1 FROM seq
            UNION ALL
            SELECT {TENANT}, {group_id}, n * 2, {product}, NULL, {counter_loc}, -1.0000,
                   {base_uom}, -1.0000, {base_uom}, 1.00000000, NOW(3), 1 FROM seq""",
        read=False,
    )
    return group_id


def recompute_balance(product: int, locations: list[int], base_uom: int) -> None:
    """Rewrites the touched balance rows as the sum of their ledger lines (ADR-004)."""
    for location in locations:
        sql(
            f"""INSERT INTO inv_balance
                  (tenant_id, product_id, location_id, batch_id, qty_on_hand, qty_reserved,
                   base_uom_id, avg_unit_cost, updated_at)
                SELECT {TENANT}, {product}, {location}, 0,
                       COALESCE(SUM(qty_base), 0), 0, {base_uom}, 0, NOW(3)
                  FROM inv_movement
                 WHERE tenant_id={TENANT} AND product_id={product}
                   AND location_id={location} AND batch_id IS NULL
                ON DUPLICATE KEY UPDATE
                   qty_on_hand = VALUES(qty_on_hand), updated_at = VALUES(updated_at)""",
            read=False,
        )


def verify(product: int, locations: list[int]) -> None:
    """The two invariants the load test must not have broken."""
    unbalanced = sql(
        f"""SELECT COUNT(*) FROM (
              SELECT group_id FROM inv_movement WHERE tenant_id={TENANT}
               GROUP BY group_id HAVING SUM(qty_base) <> 0) x"""
    )
    drift = sql(
        f"""SELECT COUNT(*) FROM inv_balance b
             WHERE b.tenant_id={TENANT} AND b.product_id={product}
               AND b.location_id IN ({','.join(str(l) for l in locations)}) AND b.batch_id = 0
               AND b.qty_on_hand <> (
                 SELECT COALESCE(SUM(m.qty_base), 0) FROM inv_movement m
                  WHERE m.tenant_id=b.tenant_id AND m.product_id=b.product_id
                    AND m.location_id=b.location_id AND m.batch_id IS NULL)"""
    )
    print(f"  §12.3 groups not summing to zero: {unbalanced}")
    print(f"  §12.2 balance rows disagreeing with the ledger: {drift}")
    if unbalanced != "0" or drift != "0":
        raise SystemExit("invariant broken — do not run the load test against this data")


if __name__ == "__main__":
    sys.exit(main())
