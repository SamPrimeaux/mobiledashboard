#!/usr/bin/env python3
"""
capture_agentsam_schemas_existing_env.py

Captures full schema details for all live agentsam_* tables/views from the D1
database configured by the existing Agent Meauxbility local environment.

Uses existing env:
  IAM_D1_DB                       defaults to inneranimalmedia-business
  AGENT_DASHBOARD_API_TOKEN       preferred token source
  CLOUDFLARE_API_TOKEN            fallback / Wrangler token source

No direct Cloudflare account/database IDs are hardcoded.
No model calls.
No D1 mutations.
No R2 writes.

Outputs by default:
  tmp/agent-meauxbility/agentsam-schema-capture/agentsam_schemas.json
  tmp/agent-meauxbility/agentsam-schema-capture/agentsam_schemas.md
  tmp/agent-meauxbility/agentsam-schema-capture/agentsam_schemas.sql
  tmp/agent-meauxbility/agentsam-schema-capture/combined_db_reference.md

Usage:
  cd /Users/samprimeaux/mobiledashboard
  source scripts/cms/load-agent-meauxbility-env.sh
  python3 scripts/cms/capture_agentsam_schemas_existing_env.py
"""

from __future__ import annotations

import json
import os
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
DB_NAME = os.environ.get("IAM_D1_DB", "inneranimalmedia-business").strip()
OUT_DIR = Path(os.environ.get("AGENTSAM_SCHEMA_OUT_DIR", "tmp/agent-meauxbility/agentsam-schema-capture"))

OUTPUT_JSON = OUT_DIR / "agentsam_schemas.json"
OUTPUT_MD = OUT_DIR / "agentsam_schemas.md"
OUTPUT_SQL = OUT_DIR / "agentsam_schemas.sql"
OUTPUT_COMBINED = OUT_DIR / "combined_db_reference.md"


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


def discover_tables(env: dict[str, str], prefix: str) -> list[dict[str, str]]:
    rows = run_json(
        f"""
SELECT name, type
FROM sqlite_master
WHERE type IN ('table','view')
  AND name LIKE '{prefix}\\_%' ESCAPE '\\'
ORDER BY name;
""".strip(),
        env,
    )
    return [{"name": str(row["name"]), "type": str(row.get("type") or "table")} for row in rows if row.get("name")]


def fetch_columns(name: str, env: dict[str, str]) -> list[dict[str, Any]]:
    return run_json(f"PRAGMA table_info({quote_ident(name)});", env)


def fetch_ddl(name: str, env: dict[str, str]) -> str:
    safe_name = name.replace("'", "''")
    rows = run_json(
        f"SELECT sql FROM sqlite_master WHERE type IN ('table','view') AND name = '{safe_name}';",
        env,
    )
    if rows:
        return rows[0].get("sql") or "-- DDL not found"
    return "-- DDL not found"


def fetch_row_count(name: str, object_type: str, env: dict[str, str]) -> int | None:
    # Views may be expensive or not countable depending on definition; still try.
    try:
        rows = run_json(f"SELECT COUNT(*) AS count FROM {quote_ident(name)};", env)
        if rows:
            return int(rows[0].get("count", 0))
    except Exception:
        return None
    return None


def capture_prefix(prefix: str, env: dict[str, str]) -> dict[str, Any]:
    objects = discover_tables(env, prefix)
    schema_map: dict[str, Any] = {}

    print("=" * 78)
    print(f"{prefix}_* Schema Capture")
    print(f"Database: {DB_NAME}")
    print(f"Objects discovered: {len(objects)}")
    print(f"Output directory: {OUT_DIR}")
    print("=" * 78)

    for idx, item in enumerate(objects, start=1):
        name = item["name"]
        object_type = item["type"]
        print(f"[{idx:02d}/{len(objects):02d}] {name} ({object_type}) ... ", end="", flush=True)
        started = time.time()
        try:
            columns = fetch_columns(name, env)
            ddl = fetch_ddl(name, env)
            row_count = fetch_row_count(name, object_type, env)
            elapsed_ms = round((time.time() - started) * 1000)

            schema_map[name] = {
                "type": object_type,
                "columns": columns,
                "ddl": ddl,
                "row_count": row_count,
                "elapsed_ms": elapsed_ms,
            }
            print(f"OK ({len(columns)} cols, {row_count if row_count is not None else 'n/a'} rows, {elapsed_ms}ms)")
        except Exception as exc:
            elapsed_ms = round((time.time() - started) * 1000)
            schema_map[name] = {
                "type": object_type,
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
        "prefix": prefix,
        "object_count": len(objects),
        "objects": schema_map,
    }


def markdown_anchor(name: str) -> str:
    return name.lower().replace("_", "-")


def write_json(payload: dict[str, Any], path: Path) -> None:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
    print(f"JSON -> {path}")


def write_md(payload: dict[str, Any], path: Path, title: str) -> None:
    objects: dict[str, Any] = payload["objects"]

    lines: list[str] = [
        f"# {title}",
        "",
        f"Captured: `{payload['captured_at']}`",
        f"Database: `{payload['database_name']}`",
        f"Objects: `{payload['object_count']}`",
        "",
        "## Notes",
        "",
        "- This capture is read-only.",
        "- It uses the existing Agent Meauxbility environment and Wrangler D1.",
        "- No model APIs are called.",
        "- Row counts are included to help agents understand which tables are active vs. placeholders.",
        "",
        "## Table of contents",
        "",
    ]

    for name, info in objects.items():
        count = info.get("row_count")
        count_label = "n/a" if count is None else str(count)
        object_type = info.get("type", "table")
        lines.append(f"- [{name}](#{markdown_anchor(name)}) — {object_type}, {count_label} rows")

    lines += ["", "---", ""]

    for name, info in objects.items():
        columns = info.get("columns") or []
        count = info.get("row_count")
        ddl = info.get("ddl") or "-- DDL not found"

        lines += [
            f"## {name}",
            "",
            f"Type: `{info.get('type', 'table')}`",
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

    path.write_text("\n".join(lines).rstrip() + "\n")
    print(f"MD   -> {path}")


def write_sql(payload: dict[str, Any], path: Path, title: str) -> None:
    objects: dict[str, Any] = payload["objects"]

    lines: list[str] = [
        f"-- {title}",
        f"-- Captured: {payload['captured_at']}",
        f"-- Database: {payload['database_name']}",
        "",
    ]

    for name, info in objects.items():
        ddl = info.get("ddl") or "-- DDL not found"
        lines += [
            "-- " + "-" * 72,
            f"-- {name}",
            "-- " + "-" * 72,
            ddl.rstrip(";") + ";",
            "",
        ]

    path.write_text("\n".join(lines).rstrip() + "\n")
    print(f"SQL  -> {path}")


def load_existing_cms_summary() -> dict[str, Any] | None:
    cms_json = ROOT / "docs/db/cms/cms_schemas.json"
    if not cms_json.exists():
        return None
    try:
        return json.loads(cms_json.read_text())
    except Exception:
        return None


def write_combined_reference(agentsam_payload: dict[str, Any]) -> None:
    cms_payload = load_existing_cms_summary()
    agentsam_objects = agentsam_payload["objects"]
    cms_tables = (cms_payload or {}).get("tables") or {}

    total_agentsam = len(agentsam_objects)
    total_cms = len(cms_tables)
    total = total_agentsam + total_cms

    lines = [
        "# Combined Agent Sam + CMS DB Reference",
        "",
        f"Captured: `{agentsam_payload['captured_at']}`",
        f"Database: `{agentsam_payload['database_name']}`",
        "",
        "## Totals",
        "",
        f"- `agentsam_*`: `{total_agentsam}` objects",
        f"- `cms_*`: `{total_cms}` tables from `docs/db/cms/cms_schemas.json`" if cms_payload else "- `cms_*`: `0` loaded; run/copy the CMS schema capture first",
        f"- Combined: `{total}` objects/tables",
        "",
        "## References",
        "",
        "- `docs/db/agentsam/agentsam_schemas.md`",
        "- `docs/db/agentsam/agentsam_schemas.json`",
        "- `docs/db/agentsam/agentsam_schemas.sql`",
        "- `docs/db/cms/cms_schemas.md`",
        "- `docs/db/cms/cms_schemas.json`",
        "- `docs/db/cms/cms_schemas.sql`",
        "",
        "## Agent Sam objects",
        "",
    ]

    for name, info in agentsam_objects.items():
        count = info.get("row_count")
        lines.append(f"- `{name}` — `{info.get('type', 'table')}`, `{count if count is not None else 'n/a'}` rows, `{len(info.get('columns') or [])}` columns")

    lines += ["", "## CMS tables", ""]

    for name, info in cms_tables.items():
        count = info.get("row_count")
        lines.append(f"- `{name}` — `{count if count is not None else 'n/a'}` rows, `{len(info.get('columns') or [])}` columns")

    OUTPUT_COMBINED.write_text("\n".join(lines).rstrip() + "\n")
    print(f"COMBINED -> {OUTPUT_COMBINED}")


def main() -> int:
    env = ensure_env()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    payload = capture_prefix("agentsam", env)

    print()
    print("Writing outputs...")
    write_json(payload, OUTPUT_JSON)
    write_md(payload, OUTPUT_MD, "Agent Sam Table Schemas")
    write_sql(payload, OUTPUT_SQL, "Agent Sam Table DDL Dump")
    write_combined_reference(payload)

    ok = sum(1 for info in payload["objects"].values() if not info.get("error"))
    total = len(payload["objects"])
    failed = total - ok

    print()
    print(f"Done. {ok}/{total} Agent Sam objects captured.")
    if failed:
        print(f"{failed} failed. Check {OUTPUT_JSON} for error details.")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
