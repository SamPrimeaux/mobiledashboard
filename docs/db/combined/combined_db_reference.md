# Combined Agent Sam + CMS DB Reference

Captured: `2026-05-09T21:28:55.494566+00:00`
Database: `inneranimalmedia-business`

## Totals

- `agentsam_*`: `84` objects
- `cms_*`: `27` tables from `docs/db/cms/cms_schemas.json`
- Combined: `111` objects/tables

## References

- `docs/db/agentsam/agentsam_schemas.md`
- `docs/db/agentsam/agentsam_schemas.json`
- `docs/db/agentsam/agentsam_schemas.sql`
- `docs/db/cms/cms_schemas.md`
- `docs/db/cms/cms_schemas.json`
- `docs/db/cms/cms_schemas.sql`

## Agent Sam objects

- `agentsam_agent_run` — `table`, `315` rows, `27` columns
- `agentsam_ai` — `table`, `101` rows, `94` columns
- `agentsam_analytics` — `table`, `3` rows, `50` columns
- `agentsam_approval_queue` — `table`, `6` rows, `23` columns
- `agentsam_artifacts` — `table`, `63` rows, `15` columns
- `agentsam_bootstrap` — `table`, `12` rows, `43` columns
- `agentsam_browser_trusted_origin` — `table`, `10` rows, `8` columns
- `agentsam_cad_jobs` — `table`, `2` rows, `13` columns
- `agentsam_code_index_job` — `table`, `8` rows, `25` columns
- `agentsam_command_allowlist` — `table`, `155` rows, `6` columns
- `agentsam_command_pattern` — `table`, `10` rows, `14` columns
- `agentsam_command_run` — `table`, `87` rows, `29` columns
- `agentsam_commands` — `table`, `496` rows, `43` columns
- `agentsam_compaction_events` — `table`, `0` rows, `16` columns
- `agentsam_context_digest` — `table`, `0` rows, `15` columns
- `agentsam_cron_runs` — `table`, `1235` rows, `14` columns
- `agentsam_deployment_health` — `table`, `23` rows, `15` columns
- `agentsam_error_log` — `table`, `12` rows, `13` columns
- `agentsam_escalation` — `table`, `0` rows, `17` columns
- `agentsam_eval_cases` — `table`, `19` rows, `10` columns
- `agentsam_eval_runs` — `table`, `21` rows, `29` columns
- `agentsam_eval_suites` — `table`, `9` rows, `13` columns
- `agentsam_execution_context` — `table`, `68` rows, `13` columns
- `agentsam_execution_dependency_graph` — `table`, `7` rows, `19` columns
- `agentsam_execution_performance_metrics` — `table`, `47` rows, `54` columns
- `agentsam_execution_steps` — `table`, `22` rows, `20` columns
- `agentsam_executions` — `table`, `16` rows, `31` columns
- `agentsam_executions_backup_20260509_014549` — `table`, `16` rows, `31` columns
- `agentsam_feature_flag` — `table`, `19` rows, `15` columns
- `agentsam_fetch_domain_allowlist` — `table`, `18` rows, `6` columns
- `agentsam_guardrail_events` — `table`, `0` rows, `28` columns
- `agentsam_guardrail_rulesets` — `table`, `2` rows, `17` columns
- `agentsam_guardrails` — `table`, `13` rows, `22` columns
- `agentsam_health_daily` — `table`, `3` rows, `18` columns
- `agentsam_hook` — `table`, `14` rows, `17` columns
- `agentsam_hook_execution` — `table`, `78` rows, `25` columns
- `agentsam_ignore_pattern` — `table`, `10` rows, `10` columns
- `agentsam_mcp_allowlist` — `table`, `412` rows, `16` columns
- `agentsam_mcp_servers` — `table`, `3` rows, `17` columns
- `agentsam_mcp_tool_execution` — `table`, `20` rows, `37` columns
- `agentsam_mcp_tools` — `table`, `393` rows, `50` columns
- `agentsam_mcp_workflows` — `table`, `52` rows, `43` columns
- `agentsam_memory` — `table`, `116` rows, `19` columns
- `agentsam_model_catalog` — `table`, `23` rows, `35` columns
- `agentsam_model_drift_signals` — `table`, `3` rows, `20` columns
- `agentsam_model_routing_memory` — `table`, `26` rows, `25` columns
- `agentsam_model_tier` — `table`, `5` rows, `18` columns
- `agentsam_plan_tasks` — `table`, `97` rows, `38` columns
- `agentsam_plans` — `table`, `16` rows, `36` columns
- `agentsam_plans_old` — `table`, `15` rows, `36` columns
- `agentsam_project_context` — `table`, `55` rows, `35` columns
- `agentsam_prompt_cache_keys` — `table`, `6` rows, `24` columns
- `agentsam_prompt_routes` — `table`, `24` rows, `23` columns
- `agentsam_prompt_versions` — `table`, `17` rows, `19` columns
- `agentsam_route_requirements` — `table`, `18` rows, `21` columns
- `agentsam_routing_arms` — `table`, `127` rows, `38` columns
- `agentsam_rules_document` — `table`, `4` rows, `10` columns
- `agentsam_script_runs` — `table`, `5` rows, `18` columns
- `agentsam_scripts` — `table`, `115` rows, `22` columns
- `agentsam_skill` — `table`, `48` rows, `29` columns
- `agentsam_skill_invocation` — `table`, `0` rows, `21` columns
- `agentsam_skill_revision` — `table`, `0` rows, `7` columns
- `agentsam_slash_commands` — `table`, `42` rows, `17` columns
- `agentsam_subagent_profile` — `table`, `41` rows, `37` columns
- `agentsam_subscription_registry` — `table`, `16` rows, `11` columns
- `agentsam_task_slos` — `table`, `3` rows, `10` columns
- `agentsam_todo` — `table`, `95` rows, `40` columns
- `agentsam_tool_cache` — `table`, `0` rows, `23` columns
- `agentsam_tool_call_log` — `table`, `20` rows, `27` columns
- `agentsam_tool_chain` — `table`, `43` rows, `42` columns
- `agentsam_tool_stats_compacted` — `table`, `81` rows, `18` columns
- `agentsam_tools` — `table`, `40` rows, `35` columns
- `agentsam_usage_events` — `table`, `426` rows, `23` columns
- `agentsam_usage_rollups_daily` — `table`, `31` rows, `19` columns
- `agentsam_user_feature_override` — `table`, `0` rows, `5` columns
- `agentsam_user_policy` — `table`, `4` rows, `51` columns
- `agentsam_webhook_events` — `table`, `1393` rows, `28` columns
- `agentsam_webhook_weekly` — `table`, `1` rows, `14` columns
- `agentsam_workflow_edges` — `table`, `35` rows, `10` columns
- `agentsam_workflow_nodes` — `table`, `30` rows, `18` columns
- `agentsam_workflow_runs` — `table`, `21` rows, `49` columns
- `agentsam_workflows` — `table`, `14` rows, `20` columns
- `agentsam_workspace` — `table`, `23` rows, `19` columns
- `agentsam_workspace_state` — `table`, `5` rows, `18` columns

## CMS tables

- `cms_3d_assets` — `14` rows, `17` columns
- `cms_activity_log` — `1` rows, `10` columns
- `cms_assets` — `100` rows, `23` columns
- `cms_collection_assets` — `0` rows, `4` columns
- `cms_collections` — `5` rows, `9` columns
- `cms_component_templates` — `24` rows, `16` columns
- `cms_content` — `4` rows, `3` columns
- `cms_conversion_jobs` — `0` rows, `12` columns
- `cms_conversions` — `0` rows, `13` columns
- `cms_folders` — `6` rows, `7` columns
- `cms_global_settings` — `5` rows, `17` columns
- `cms_liquid_imports` — `0` rows, `17` columns
- `cms_liquid_sections` — `0` rows, `15` columns
- `cms_live_edit_sessions` — `0` rows, `7` columns
- `cms_live_rollbacks` — `0` rows, `8` columns
- `cms_navigation_menus` — `3` rows, `14` columns
- `cms_override_versions` — `0` rows, `11` columns
- `cms_page_drafts` — `0` rows, `6` columns
- `cms_page_overrides` — `0` rows, `13` columns
- `cms_page_sections` — `46` rows, `13` columns
- `cms_pages` — `17` rows, `40` columns
- `cms_section_components` — `93` rows, `10` columns
- `cms_site_pages` — `49` rows, `25` columns
- `cms_tenants` — `12` rows, `13` columns
- `cms_theme_preferences` — `4` rows, `12` columns
- `cms_themes` — `108` rows, `31` columns
- `cms_video_projects` — `3` rows, `10` columns
