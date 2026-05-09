#!/usr/bin/env python3
# Agent Meauxbility CMS — Agent Sam + CMS DB Contract
#
# Repo: SamPrimeaux/mobiledashboard
# Purpose:
# Defines the relevant agentsam_* and cms_* tables for full-stack CMS editor,
# component-library generation, workflow execution, artifacts, telemetry,
# prompt routing, and end-to-end validation.
#
# This is not a migration. It is a runtime/generation contract.

AGENTSAM_CMS_RELEVANT_TABLES = {
    "workspace_and_identity": [
        "agentsam_workspace",
        "agentsam_workspace_state",
        "agentsam_user_policy",
        "agentsam_user_feature_override",
        "agentsam_subscription_registry",
    ],

    "planning_project_and_todos": [
        "agentsam_plans",
        "agentsam_plan_tasks",
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
        "agentsam_execution_context",
        "agentsam_execution_steps",
        "agentsam_execution_dependency_graph",
        "agentsam_execution_performance_metrics",
    ],

    "tool_runtime": [
        "agentsam_tools",
        "agentsam_tool_chain",
        "agentsam_tool_call_log",
        "agentsam_tool_cache",
        "agentsam_tool_stats_compacted",
        "agentsam_approval_queue",
    ],

    "commands_scripts_and_allowlists": [
        "agentsam_commands",
        "agentsam_command_run",
        "agentsam_command_allowlist",
        "agentsam_command_pattern",
        "agentsam_scripts",
        "agentsam_script_runs",
        "agentsam_slash_commands",
        "agentsam_ignore_pattern",
        "agentsam_fetch_domain_allowlist",
    ],

    "prompt_routing_and_cache": [
        "agentsam_prompt_routes",
        "agentsam_prompt_versions",
        "agentsam_prompt_cache_keys",
        "agentsam_context_digest",
        "agentsam_compaction_events",
    ],

    "model_catalog_routing_and_usage": [
        "agentsam_ai",
        "agentsam_model_catalog",
        "agentsam_model_tier",
        "agentsam_routing_arms",
        "agentsam_route_requirements",
        "agentsam_model_routing_memory",
        "agentsam_model_drift_signals",
        "agentsam_usage_events",
        "agentsam_usage_rollups_daily",
        "agentsam_analytics",
        "agentsam_agent_run",
    ],

    "subagents_skills_and_memory": [
        "agentsam_subagent_profile",
        "agentsam_skill",
        "agentsam_skill_revision",
        "agentsam_skill_invocation",
        "agentsam_memory",
        "agentsam_rules_document",
        "agentsam_bootstrap",
    ],

    "mcp_runtime": [
        "agentsam_mcp_servers",
        "agentsam_mcp_allowlist",
        "agentsam_mcp_tools",
        "agentsam_mcp_tool_execution",
        "agentsam_mcp_workflows",
    ],

    "quality_eval_guardrails": [
        "agentsam_eval_suites",
        "agentsam_eval_cases",
        "agentsam_eval_runs",
        "agentsam_guardrails",
        "agentsam_guardrail_rulesets",
        "agentsam_guardrail_events",
        "agentsam_task_slos",
        "agentsam_escalation",
    ],

    "hooks_webhooks_health_and_ops": [
        "agentsam_hook",
        "agentsam_hook_execution",
        "agentsam_webhook_events",
        "agentsam_webhook_weekly",
        "agentsam_health_daily",
        "agentsam_deployment_health",
        "agentsam_error_log",
        "agentsam_cron_runs",
        "agentsam_feature_flag",
    ],

    "browser_code_and_specialized_jobs": [
        "agentsam_browser_trusted_origin",
        "agentsam_code_index_job",
        "agentsam_cad_jobs",
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

EXCLUDED_LEGACY_OR_BACKUP_TABLES = [
    "agentsam_executions_backup_20260509_014549",
    "agentsam_plans_old",
]

E2E_REQUIRED_NONZERO_TABLES = [
    "agentsam_plans",
    "agentsam_project_context",
    "agentsam_todo",
    "agentsam_workflows",
    "agentsam_workflow_runs",
    "agentsam_workflow_nodes",
    "agentsam_workflow_edges",
    "agentsam_prompt_routes",
    "agentsam_prompt_versions",
    "agentsam_prompt_cache_keys",
    "agentsam_tool_chain",
    "agentsam_execution_steps",
    "agentsam_execution_dependency_graph",
    "agentsam_execution_performance_metrics",
    "agentsam_artifacts",
    "cms_pages",
    "cms_page_sections",
    "cms_section_components",
    "cms_assets",
    "cms_themes",
]

AGENT_MEAUXBILITY_TOUCHPOINTS = [
    {
        "phase": "plan_and_context",
        "tables": [
            "agentsam_plans",
            "agentsam_plan_tasks",
            "agentsam_project_context",
            "agentsam_todo",
        ],
    },
    {
        "phase": "workflow_graph",
        "tables": [
            "agentsam_workflows",
            "agentsam_workflow_runs",
            "agentsam_workflow_nodes",
            "agentsam_workflow_edges",
        ],
    },
    {
        "phase": "prompt_routing",
        "tables": [
            "agentsam_prompt_routes",
            "agentsam_prompt_versions",
            "agentsam_prompt_cache_keys",
        ],
    },
    {
        "phase": "execution",
        "tables": [
            "agentsam_executions",
            "agentsam_execution_context",
            "agentsam_execution_steps",
            "agentsam_execution_dependency_graph",
            "agentsam_execution_performance_metrics",
        ],
    },
    {
        "phase": "tools",
        "tables": [
            "agentsam_tools",
            "agentsam_tool_chain",
            "agentsam_tool_call_log",
            "agentsam_tool_cache",
            "agentsam_approval_queue",
        ],
    },
    {
        "phase": "models_and_usage",
        "tables": [
            "agentsam_model_catalog",
            "agentsam_routing_arms",
            "agentsam_route_requirements",
            "agentsam_model_routing_memory",
            "agentsam_usage_events",
        ],
    },
    {
        "phase": "artifacts",
        "tables": [
            "agentsam_artifacts",
        ],
    },
    {
        "phase": "cms_library",
        "tables": [
            "cms_pages",
            "cms_site_pages",
            "cms_page_sections",
            "cms_section_components",
            "cms_assets",
            "cms_themes",
            "cms_theme_preferences",
            "cms_navigation_menus",
        ],
    },
]

SAFE_R2_PREFIXES = [
    "cms/test-runs/agent-meauxbility/",
    "dev/agent-meauxbility/",
    "analytics/agentsam/cms-live-editor/",
    "captures/inneranimalmedia/results/",
]

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

MODEL_POLICY = {
    "default": "gpt-5.4-nano",
    "escalation": "gpt-5.4-mini",
    "max_cost_usd_default": 0.25,
}

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
}

def flatten_relevant_tables():
    tables = []
    for group in AGENTSAM_CMS_RELEVANT_TABLES.values():
        tables.extend(group)
    return sorted(set(tables))

def active_contract_tables():
    excluded = set(EXCLUDED_LEGACY_OR_BACKUP_TABLES)
    return [t for t in flatten_relevant_tables() if t not in excluded]

def contract_summary():
    return {
        "relevant_table_count": len(flatten_relevant_tables()),
        "active_contract_table_count": len(active_contract_tables()),
        "groups": AGENTSAM_CMS_RELEVANT_TABLES,
        "excluded": EXCLUDED_LEGACY_OR_BACKUP_TABLES,
        "e2e_required_nonzero_tables": E2E_REQUIRED_NONZERO_TABLES,
        "touchpoints": AGENT_MEAUXBILITY_TOUCHPOINTS,
        "safe_r2_prefixes": SAFE_R2_PREFIXES,
        "blocked_live_prefixes": LIVE_PROMOTION_BLOCKED_PREFIXES,
        "model_policy": MODEL_POLICY,
        "multitenant_policy": MULTITENANT_POLICY,
    }

if __name__ == "__main__":
    import json
    print(json.dumps(contract_summary(), indent=2))
