#!/usr/bin/env python3
"""
capture_cms_schemas_existing_env.py

Captures schema details for all live cms_* tables from the D1 database configured
by the existing Agent Meauxbility local environment.

Uses existing env:
  IAM_D1_DB                       defaults to inneranimalmedia-business
  AGENT_DASHBOARD_API_TOKEN       preferred token source
  CLOUDFLARE_API_TOKEN            fallback / Wrangler token source

No direct Cloudflare account/database IDs are hardcoded.
No model calls.
No D1 mutations.
No R2 writes.

Outputs by default:
  tmp/agent-meauxbility/cms-schema-capture/cms_schemas.json
  tmp/agent-meauxbility/cms-schema-capture/cms_schemas.md
  tmp/agent-meauxbility/cms-schema-capture/cms_schemas.sql

Usage:
  cd /Users/samprimeaux/mobiledashboard
  source scripts/cms/load-agent-meauxbility-env.sh
  python3 scripts/cms/capture_cms_schemas_existing_env.py

Optional:
  CMS_SCHEMA_OUT_DIR=tmp/custom-cms-schema-capture python3 scripts/cms/capture_cms_schemas_existing_env.py
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DB_NAME = os.environ.get("IAM_D1_DB", "inneranimalmedia-business").strip()
OUT_DIR = Path(os.environ.get("CMS_SCHEMA_OUT_DIR", "tmp/agent-meauxbility/cms-schema-capture"))

OUTPUT_JSON = OUT_DIR / "cms_schemas.json"
OUTPUT_MD = OUT_DIR / "cms_schemas.md"
OUTPUT_SQL = OUT_DIR / "cms_schemas.sql"


def ensure_env() -> dict[str, str]:
    env = os.environ.copy()

    token = env.get("CLOUDFLARE_API_TOKEN") or env.get("AGENT_DASHBOARD_API_TOKEN")
    if token:
        env["CLOUDFLARE_API_TOKEN"] = token

    if not DB_NAME:
        raise SystemExit("Missing IAM_D1_DB. Expected IAM_D1_DB=inneranimalmedia-business or equivalent.")

    if not env.get("CLOUDFLARE_API_TOKEN"):
        raise SystemExit(
            "Missing Cloudflare token. Source the loader first or export one of:\n"
            "  AGENT_DASHBOARD_API_TOKEN\n"
            "  CLOUDFLARE_API_TOKEN"
        )

    return env


def run_json(sql: str, env: dict[str, str]) -> list[dict[str, Any]]:
    cmd = [
        "npx",
        "wrangler",
        "d1",
        "execute",
        DB_NAME,
        "--remote",
        "--json",
        "--command",
        sql,
    ]

    proc = subprocess.run(
        cmd,
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )

    if proc.returncode != 0:
        raise RuntimeError(
            "Wrangler D1 query failed\n"
            f"SQL:\n{sql}\n\n"
            f"STDOUT:\n{proc.stdout}\n\n"
            f"STDERR:\n{proc.stderr}"
        )

    try:
        payload = json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Wrangler returned non-JSON output for SQL:\n{sql}\n\n{proc.stdout}") from exc

    if isinstance(payload, list) and payload:
        return payload[0].get("results") or []

    return []


def quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def discover_cms_tables(env: dict[str, str]) -> list[str]:
    rows = run_json(
        """
SELECT name
FROM sqlite_master
WHERE type IN ('table','view')
  AND name LIKE 'cms\\_%' ESCAPE '\\'
ORDER BY name;
""".strip(),
        env,
    )
    return [str(row["name"]) for row in rows if row.get("name")]


def fetch_columns(table: str, env: dict[str, str]) -> list[dict[str, Any]]:
    return run_json(f"PRAGMA table_info({quote_ident(table)});", env)


def fetch_ddl(table: str, env: dict[str, str]) -> str:
    safe_name = table.replace("'", "''")
    rows = run_json(
        f"SELECT sql FROM sqlite_master WHERE type IN ('table','view') AND name = '{safe_name}';",
        env,
    )
    if rows:
        return rows[0].get("sql") or "-- DDL not found"
    return "-- DDL not found"


def fetch_row_count(table: str, env: dict[str, str]) -> int | None:
    try:
        rows = run_json(f"SELECT COUNT(*) AS count FROM {quote_ident(table)};", env)
        if rows:
            return int(rows[0].get("count", 0))
    except Exception:
        return None
    return None


def capture_all(env: dict[str, str]) -> dict[str, Any]:
    tables = discover_cms_tables(env)
    schema_map: dict[str, Any] = {}

    print("=" * 72)
    print("CMS Schema Capture")
    print(f"Database: {DB_NAME}")
    print(f"Tables discovered: {len(tables)}")
    print(f"Output directory: {OUT_DIR}")
    print("=" * 72)

    for idx, table in enumerate(tables, start=1):
        print(f"[{idx:02d}/{len(tables):02d}] {table} ... ", end="", flush=True)
        started = time.time()
        try:
            columns = fetch_columns(table, env)
            ddl = fetch_ddl(table, env)
            row_count = fetch_row_count(table, env)
            elapsed_ms = round((time.time() - started) * 1000)

            schema_map[table] = {
                "columns": columns,
                "ddl": ddl,
                "row_count": row_count,
                "elapsed_ms": elapsed_ms,
            }
            print(f"OK ({len(columns)} cols, {row_count if row_count is not None else 'n/a'} rows, {elapsed_ms}ms)")
        except Exception as exc:
            elapsed_ms = round((time.time() - started) * 1000)
            schema_map[table] = {
                "columns": [],
                "ddl": "-- ERROR",
                "row_count": None,
                "elapsed_ms": elapsed_ms,
                "error": str(exc),
            }
            print(f"FAIL ({elapsed_ms}ms) {exc}")

    return {
        "captured_at": datetime.now(timezone.utc).isoformat(),
        "database_name": DB_NAME,
        "table_count": len(tables),
        "tables": schema_map,
    }


def write_json(payload: dict[str, Any]) -> None:
    OUTPUT_JSON.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
    print(f"JSON -> {OUTPUT_JSON}")


def markdown_anchor(table: str) -> str:
    return table.lower().replace("_", "-")


def write_md(payload: dict[str, Any]) -> None:
    tables: dict[str, Any] = payload["tables"]

    lines: list[str] = [
        "# CMS Table Schemas",
        "",
        f"Captured: `{payload['captured_at']}`",
        f"Database: `{payload['database_name']}`",
        f"Tables: `{payload['table_count']}`",
        "",
        "## Notes",
        "",
        "- This capture is read-only.",
        "- It uses the existing Agent Meauxbility environment and Wrangler D1.",
        "- `env.CMS / cms` is the clean CMS editor/dev bucket.",
        "- `CLOUDFLARE_R2_BUCKET / inneranimalmedia` remains the production brand/theme/assets bucket.",
        "",
        "## Table of contents",
        "",
    ]

    for table, info in tables.items():
        count = info.get("row_count")
        count_label = "n/a" if count is None else str(count)
        lines.append(f"- [{table}](#{markdown_anchor(table)}) — {count_label} rows")

    lines += ["", "---", ""]

    for table, info in tables.items():
        columns = info.get("columns") or []
        count = info.get("row_count")
        ddl = info.get("ddl") or "-- DDL not found"

        lines += [
            f"## {table}",
            "",
            f"Rows: `{count if count is not None else 'n/a'}`",
            f"Columns: `{len(columns)}`",
            f"Capture latency: `{info.get('elapsed_ms', 'n/a')}ms`",
            "",
        ]

        if info.get("error"):
            lines += ["Error:", "", "```txt", str(info["error"]), "```", ""]

        if columns:
            lines += [
                "| cid | name | type | notnull | default | pk |",
                "|---:|---|---|---:|---|---:|",
            ]
            for col in columns:
                default = col.get("dflt_value")
                default_text = "" if default is None else str(default).replace("\n", " ")
                lines.append(
                    f"| {col.get('cid', '')} "
                    f"| `{col.get('name', '')}` "
                    f"| `{col.get('type', '')}` "
                    f"| {col.get('notnull', '')} "
                    f"| `{default_text}` "
                    f"| {col.get('pk', '')} |"
                )
            lines.append("")
        else:
            lines += ["_No column data returned._", ""]

        lines += ["```sql", ddl.rstrip(";") + ";", "```", "", "---", ""]

    OUTPUT_MD.write_text("\n".join(lines).rstrip() + "\n")
    print(f"MD   -> {OUTPUT_MD}")


def write_sql(payload: dict[str, Any]) -> None:
    tables: dict[str, Any] = payload["tables"]

    lines: list[str] = [
        "-- CMS Table DDL Dump",
        f"-- Captured: {payload['captured_at']}",
        f"-- Database: {payload['database_name']}",
        "",
    ]

    for table, info in tables.items():
        ddl = info.get("ddl") or "-- DDL not found"
        lines += [
            "-- " + "-" * 72,
            f"-- {table}",
            "-- " + "-" * 72,
            ddl.rstrip(";") + ";",
            "",
        ]

    OUTPUT_SQL.write_text("\n".join(lines).rstrip() + "\n")
    print(f"SQL  -> {OUTPUT_SQL}")


def main() -> int:
    env = ensure_env()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    payload = capture_all(env)

    print()
    print("Writing outputs...")
    write_json(payload)
    write_md(payload)
    write_sql(payload)

    ok = sum(1 for info in payload["tables"].values() if not info.get("error"))
    total = len(payload["tables"])
    failed = total - ok

    print()
    print(f"Done. {ok}/{total} tables captured.")
    if failed:
        print(f"{failed} failed. Check {OUTPUT_JSON} for error details.")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
