#!/usr/bin/env python3
"""
py2: Add/update README agentsam_* table inventory and telemetry contract.

Read-only:
- Queries D1 sqlite_master, PRAGMA table_info, and COUNT(*)
- Does not mutate D1
- Does not call model APIs
- Does not spend model tokens

Requires:
- IAM_D1_DB, default inneranimalmedia-business
- CLOUDFLARE_API_TOKEN for wrangler, if your shell needs it

Usage:
  cd /Users/samprimeaux/mobiledashboard
  source scripts/cms/load-agent-meauxbility-env.sh
  export CLOUDFLARE_API_TOKEN="$AGENT_DASHBOARD_API_TOKEN"
  python3 scripts/cms/py2_add_agentsam_table_inventory.py
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"
DB = os.environ.get("IAM_D1_DB", "inneranimalmedia-business")

START = "<!-- AGENT_MEAUXBILITY_AGENTSAM_TABLES_START -->"
END = "<!-- AGENT_MEAUXBILITY_AGENTSAM_TABLES_END -->"

REQUIRED_TELEMETRY_COLUMNS = [
    "input_tokens",
    "output_tokens",
    "total_tokens",
    "tokens_in",
    "tokens_out",
    "latency_ms",
    "duration_ms",
    "cost_usd",
    "model",
    "model_key",
    "provider",
    "created_at",
    "started_at",
    "completed_at",
]

CORE_TELEMETRY_TABLES = [
    "agentsam_usage_events",
    "agentsam_tool_chain",
    "agentsam_execution_steps",
    "agentsam_workflow_runs",
    "agentsam_execution_performance_metrics",
    "agentsam_eval_runs",
    "agentsam_command_run",
]


def run(cmd: list[str]) -> str:
    start = time.time()
    proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True)
    elapsed_ms = round((time.time() - start) * 1000)
    if proc.returncode != 0:
        raise SystemExit(
            "Command failed after " + str(elapsed_ms) + "ms: " + " ".join(cmd) + "\n"
            + "STDOUT:\n" + proc.stdout + "\n"
            + "STDERR:\n" + proc.stderr
        )
    return proc.stdout


def d1(sql: str) -> list[dict]:
    out = run([
        "npx", "wrangler", "d1", "execute", DB,
        "--remote", "--json", "--command", sql,
    ])
    data = json.loads(out)
    if isinstance(data, list) and data:
        return data[0].get("results") or []
    return []


def table_names() -> list[str]:
    rows = d1(
        "SELECT name FROM sqlite_master "
        "WHERE type IN ('table','view') "
        "AND name LIKE 'agentsam\\_%' ESCAPE '\\' "
        "ORDER BY name"
    )
    return [str(row["name"]) for row in rows]


def columns(table: str) -> list[str]:
    safe = table.replace('"', '""')
    rows = d1(f'PRAGMA table_info("{safe}")')
    return [str(row["name"]) for row in rows]


def row_count(table: str) -> str:
    safe = table.replace('"', '""')
    try:
        rows = d1(f'SELECT COUNT(*) AS n FROM "{safe}"')
        return str(rows[0].get("n", 0)) if rows else "0"
    except Exception:
        return "n/a"


def group_name(table: str) -> str:
    t = table.lower()
    rules = [
        ("Execution / Workflow / Telemetry", ["workflow", "execution", "run", "step", "chain", "usage", "performance", "dependency"]),
        ("Models / Prompts / Routing", ["model", "prompt", "route", "routing", "cache"]),
        ("Tools / MCP / Skills / Subagents", ["tool", "mcp", "skill", "subagent", "slash"]),
        ("Plans / Todos / Context / Memory", ["plan", "todo", "task", "context", "workspace", "memory"]),
        ("Evals / Quality / Health", ["eval", "judge", "shadow", "health", "analytics"]),
    ]
    for label, needles in rules:
        if any(needle in t for needle in needles):
            return label
    return "Other Agent Sam"


def key_columns(cols: list[str]) -> list[str]:
    preferred = {
        "id", "tenant_id", "workspace_id", "user_id", "status",
        "workflow_id", "workflow_run_id", "run_group_id",
        "execution_id", "execution_step_id", "command_run_id",
        "plan_id", "todo_id", "project_key", "source", "r2_key",
        "model", "model_key", "provider",
        "input_tokens", "output_tokens", "total_tokens",
        "tokens_in", "tokens_out", "latency_ms", "duration_ms", "cost_usd",
        "created_at", "updated_at", "started_at", "completed_at",
    }
    picked = [col for col in cols if col in preferred]
    return picked or cols[:10]


def telemetry_columns(cols: list[str]) -> list[str]:
    return [col for col in REQUIRED_TELEMETRY_COLUMNS if col in cols]


def telemetry_status(table: str, cols: list[str]) -> str:
    present = set(cols)
    has_tokens = bool({"input_tokens", "output_tokens", "total_tokens", "tokens_in", "tokens_out"} & present)
    has_latency = bool({"latency_ms", "duration_ms"} & present)
    has_cost = "cost_usd" in present
    has_model = bool({"model", "model_key", "provider"} & present)

    if table in CORE_TELEMETRY_TABLES:
        missing = []
        if not has_tokens:
            missing.append("tokens")
        if not has_latency:
            missing.append("latency")
        if not has_cost:
            missing.append("cost_usd")
        if not has_model:
            missing.append("model/provider")
        return "OK" if not missing else "MISSING " + ", ".join(missing)

    if has_tokens or has_latency or has_cost:
        return "PARTIAL"
    return ""


def build_table_inventory(tables: list[str]) -> str:
    grouped: dict[str, list[str]] = {}
    for table in tables:
        grouped.setdefault(group_name(table), []).append(table)

    lines = []
    lines.append("## Live `agentsam_*` DB table inventory")
    lines.append("")
    lines.append(f"Total discovered: **{len(tables)}**")
    lines.append("")

    for group in sorted(grouped):
        lines.append(f"### {group}")
        lines.append("")
        lines.append("| Table | Rows | Key columns | Telemetry status |")
        lines.append("|---|---:|---|---|")
        for table in grouped[group]:
            cols = columns(table)
            lines.append(
                f"| `{table}` | {row_count(table)} | `{', '.join(key_columns(cols)[:14])}` | {telemetry_status(table, cols)} |"
            )
        lines.append("")

    return "\n".join(lines).rstrip()


def build_telemetry_contract(tables: list[str]) -> str:
    lines = []
    lines.append("## Required Agent Sam telemetry contract")
    lines.append("")
    lines.append("Any Agent Sam run that calls a model or tool must capture these values. If any required capture is missing, the run should be treated as failed for validation purposes.")
    lines.append("")
    lines.append("| Required capture | Expected storage | Notes |")
    lines.append("|---|---|---|")
    lines.append("| Input tokens | `input_tokens` or `tokens_in` | Exact provider-reported count when available. |")
    lines.append("| Output tokens | `output_tokens` or `tokens_out` | Exact provider-reported count when available. |")
    lines.append("| Total tokens | `total_tokens` or computed input + output | Required for cost and routing comparisons. |")
    lines.append("| Latency | `latency_ms` or `duration_ms` | Wall-clock elapsed time in milliseconds. |")
    lines.append("| Cost | `cost_usd` | Must be calculated from provider/model pricing and token counts. Store full precision; UI can round to cents. |")
    lines.append("| Provider/model | `provider`, `model`, `model_key` | Required for model routing and cost attribution. |")
    lines.append("| Run linkage | `run_group_id`, `workflow_run_id`, `execution_id`, `execution_step_id` where applicable | Required for E2E traceability. |")
    lines.append("")

    lines.append("### Core telemetry tables checked")
    lines.append("")
    lines.append("| Table | Exists | Rows | Present telemetry columns | Status |")
    lines.append("|---|---:|---:|---|---|")
    table_set = set(tables)
    for table in CORE_TELEMETRY_TABLES:
        exists = table in table_set
        if exists:
            cols = columns(table)
            present = telemetry_columns(cols)
            rows = row_count(table)
            status = telemetry_status(table, cols)
        else:
            present = []
            rows = "0"
            status = "MISSING TABLE"
        lines.append(f"| `{table}` | {'yes' if exists else 'no'} | {rows} | `{', '.join(present)}` | {status} |")

    lines.append("")
    lines.append("### Cost precision rule")
    lines.append("")
    lines.append("Persist cost as `REAL cost_usd` with full calculated precision. Display may round to cents, but raw storage should not pre-round. If provider billing exposes exact charged cost later, reconcile the estimated `cost_usd` with the provider-billed value.")
    return "\n".join(lines).rstrip()


def build_section() -> str:
    tables = table_names()
    return "\n\n".join([
        START,
        build_telemetry_contract(tables),
        build_table_inventory(tables),
        END,
    ]) + "\n"


def update_readme(section: str) -> None:
    old = README.read_text() if README.exists() else "# Agent Meauxbility Dashboard\n"
    pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)
    if pattern.search(old):
        new = pattern.sub(section.strip(), old)
    else:
        new = old.rstrip() + "\n\n" + section.strip() + "\n"
    README.write_text(new)


def main() -> None:
    section = build_section()
    update_readme(section)
    print(f"updated {README}")
    print(f"database: {DB}")
    print(f"agentsam_tables: {len(table_names())}")


if __name__ == "__main__":
    main()
