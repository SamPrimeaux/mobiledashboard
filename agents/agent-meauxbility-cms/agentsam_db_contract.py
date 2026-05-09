#!/usr/bin/env python3
# Agent Meauxbility CMS — Agent Sam DB Contract
#
# Purpose:
# This file tells Nano/Mini/Agent Sam which agentsam_* tables matter for
# end-to-end generation, validation, telemetry, artifact registration,
# routing, workflow execution, and CMS editor runtime proof.
#
# This is not a migration file.
# This is a repo-local contract/reference used by generation and validation scripts.

AGENTSAM_REQUIRED_TABLES = {
    "identity_scope": [
        "agentsam_workspace",
        "auth_users",
        "auth_sessions",
        "user_oauth_tokens",
    ],

    "planning_and_project_context": [
        "agentsam_plans",
        "agentsam_project_context",
        "agentsam_todo",
        "agentsam_artifacts",
    ],

    "workflow_graph": [
        "agentsam_workflows",
        "agentsam_workflow_runs",
        "agentsam_workflow_nodes",
        "agentsam_workflow_edges",
    ],

    "execution_runtime": [
        "agentsam_executions",
        "agentsam_execution_steps",
        "agentsam_execution_context",
        "agentsam_execution_dependency_graph",
        "agentsam_execution_performance_metrics",
    ],

    "tool_runtime": [
        "agentsam_tools",
        "agentsam_tool_chain",
        "agentsam_tool_call_log",
        "agentsam_tool_cache",
        "agentsam_approval_queue",
    ],

    "commands_and_scripts": [
        "agentsam_commands",
        "agentsam_command_run",
        "agentsam_scripts",
        "agentsam_script_runs",
    ],

    "prompt_system": [
        "agentsam_prompt_routes",
        "agentsam_prompt_versions",
        "agentsam_prompt_cache_keys",
    ],

    "model_routing_and_memory": [
        "agentsam_ai",
        "agentsam_model_catalog",
        "agentsam_routing_arms",
        "agentsam_model_routing_memory",
        "agentsam_usage_events",
    ],

    "mcp_runtime": [
        "agentsam_mcp_tools",
        "agentsam_mcp_tool_execution",
        "agentsam_mcp_workflows",
        "mcp_workflows",
        "mcp_workflow_runs",
        "mcp_tool_calls",
        "mcp_usage_log",
        "mcp_audit_log",
    ],

    "evaluation_and_quality": [
        "agentsam_eval_suites",
        "agentsam_eval_cases",
        "agentsam_eval_runs",
        "agentsam_skill_invocation",
        "agentsam_skill_revision",
    ],

    "hooks_and_events": [
        "agentsam_hook",
        "agentsam_hook_execution",
        "agentsam_webhook_events",
        "agentsam_compaction_events",
        "agentsam_health_daily",
        "agentsam_deployment_health",
    ],

    "cms_runtime": [
        "cms_pages",
        "cms_site_pages",
        "cms_page_sections",
        "cms_section_components",
        "cms_assets",
        "cms_themes",
        "cms_theme_preferences",
        "cms_navigation_menus",
    ],
}

# Minimum proof required for a real generation run.
# If these are missing or zero, the run is not considered end-to-end valid.
AGENTSAM_E2E_REQUIRED_COUNTS = {
    "agentsam_plans": 1,
    "agentsam_project_context": 1,
    "agentsam_todo": 1,
    "agentsam_workflows": 1,
    "agentsam_workflow_runs": 1,
    "agentsam_workflow_nodes": 1,
    "agentsam_workflow_edges": 1,
    "agentsam_prompt_routes": 1,
    "agentsam_prompt_versions": 1,
    "agentsam_prompt_cache_keys": 1,
    "agentsam_tool_chain": 1,
    "agentsam_execution_steps": 1,
    "agentsam_execution_dependency_graph": 1,
    "agentsam_execution_performance_metrics": 1,
    "agentsam_artifacts": 1,
}

# Rows that must be written/updated by Agent Meauxbility CMS generation.
AGENT_MEAUXBILITY_REQUIRED_TOUCHPOINTS = [
    {
        "phase": "plan",
        "tables": ["agentsam_plans", "agentsam_project_context", "agentsam_todo"],
        "requirement": "A run must link a plan, project context, and todo before generation.",
    },
    {
        "phase": "workflow_graph",
        "tables": ["agentsam_workflows", "agentsam_workflow_runs", "agentsam_workflow_nodes", "agentsam_workflow_edges"],
        "requirement": "A run must have graph identity and node/edge structure.",
    },
    {
        "phase": "prompt_routing",
        "tables": ["agentsam_prompt_routes", "agentsam_prompt_versions", "agentsam_prompt_cache_keys"],
        "requirement": "A run must use routeable prompts and compiled prompt cache keys.",
    },
    {
        "phase": "tool_execution",
        "tables": ["agentsam_tool_chain", "agentsam_execution_steps", "agentsam_execution_dependency_graph"],
        "requirement": "Every phase must create a chain row, execution step, and dependency edge where applicable.",
    },
    {
        "phase": "artifact_output",
        "tables": ["agentsam_artifacts"],
        "requirement": "Every R2 object produced by generation must be registered as an artifact.",
    },
    {
        "phase": "usage_and_cost",
        "tables": ["agentsam_usage_events", "agentsam_execution_performance_metrics"],
        "requirement": "Every model-backed generation must write usage/cost/performance telemetry.",
    },
]

# Canonical safe R2 prefixes for this project.
SAFE_R2_PREFIXES = [
    "cms/test-runs/agent-meauxbility/",
    "dev/agent-meauxbility/",
    "analytics/agentsam/cms-live-editor/",
    "captures/inneranimalmedia/results/",
]

# Paths that require explicit approval before any generated script may write.
LIVE_PROMOTION_BLOCKED_PREFIXES = [
    "pages/",
    "components/",
    "src/",
    "static/",
    "assets/",
    "dashboard/",
    "cms/themes/",
    "cms/pages/",
]

# Model routing policy.
MODEL_POLICY = {
    "default": "gpt-5.4-nano",
    "escalation": "gpt-5.4-mini",
    "max_cost_usd_default": 0.25,
    "escalate_when": [
        "schema inference fails",
        "build fails twice",
        "generated code is incomplete",
        "validation required rows are missing",
        "Nano output is too shallow for architectural reconciliation",
    ],
}

# Multi-tenant safety policy.
MULTITENANT_POLICY = {
    "required_env": [
        "IAM_D1_DB",
        "IAM_TENANT_ID",
        "IAM_WORKSPACE_ID",
        "IAM_USER_ID",
        "CLOUDFLARE_R2_BUCKET",
    ],
    "forbidden_fallbacks": [
        "tenant_sam_primeaux",
        "ws_inneranimalmedia",
        "au_871d920d1233cbd1",
    ],
    "rule": "Reusable scripts must fail if tenant/workspace/user scope is missing. Sam-specific IDs may exist only in local env files or explicit test fixtures.",
}


def flatten_required_tables():
    tables = []
    for group in AGENTSAM_REQUIRED_TABLES.values():
        tables.extend(group)
    return sorted(set(tables))


def contract_summary():
    return {
        "required_table_count": len(flatten_required_tables()),
        "required_groups": sorted(AGENTSAM_REQUIRED_TABLES.keys()),
        "e2e_required_counts": AGENTSAM_E2E_REQUIRED_COUNTS,
        "touchpoints": AGENT_MEAUXBILITY_REQUIRED_TOUCHPOINTS,
        "safe_r2_prefixes": SAFE_R2_PREFIXES,
        "blocked_live_prefixes": LIVE_PROMOTION_BLOCKED_PREFIXES,
        "model_policy": MODEL_POLICY,
        "multitenant_policy": MULTITENANT_POLICY,
    }


if __name__ == "__main__":
    import json
    print(json.dumps(contract_summary(), indent=2))
