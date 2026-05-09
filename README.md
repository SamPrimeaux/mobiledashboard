Here’s the cleaner Agent Meauxbility CMS DB lineup, limited to relevant agentsam_* and cms_* tables.

Core E2E required tables

These are the non-negotiable tables for a real Agent Meauxbility CMS generation/validation run:

agentsam_plans
agentsam_plan_tasks
agentsam_project_context
agentsam_todo
agentsam_artifacts

agentsam_workflows
agentsam_workflow_runs
agentsam_workflow_nodes
agentsam_workflow_edges

agentsam_executions
agentsam_execution_context
agentsam_execution_steps
agentsam_execution_dependency_graph
agentsam_execution_performance_metrics

agentsam_tools
agentsam_tool_chain
agentsam_tool_call_log
agentsam_tool_cache
agentsam_approval_queue

agentsam_prompt_routes
agentsam_prompt_versions
agentsam_prompt_cache_keys

agentsam_usage_events
agentsam_model_catalog
agentsam_routing_arms
agentsam_route_requirements
agentsam_model_routing_memory

agentsam_scripts
agentsam_script_runs

agentsam_subagent_profile
agentsam_skill
agentsam_skill_revision
agentsam_skill_invocation

cms_pages
cms_site_pages
cms_page_sections
cms_section_components
cms_assets
cms_themes
cms_theme_preferences
cms_navigation_menus
Full relevant grouping for the agent pack

Use this as the rewritten DB contract grouping.

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
Tables to exclude from the agent contract

These can exist in D1, but the agent pack should not depend on them for active runtime validation:

agentsam_executions_backup_20260509_014549
agentsam_plans_old

agentsam_plans_old may remain for legacy compatibility, but new runtime should target agentsam_plans. We already migrated agentsam_project_context.linked_plan_id and agentsam_executions.plan_id toward agentsam_plans.

Rewrite your local contract file with this

Run this as a safer single-file update:
