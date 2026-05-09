# mobiledashboard

A high-performance, mobile-optimized Agent Platform dashboard built with Tailwind CSS and Phosphor Icons.

## Features
- **Mobile-First Design**: Optimized for touch interactions and small screens.
- **Agent Composer**: Quick access to AI agent interactions.
- **Automations**: Manage and deploy workflow automations.
- **History & Diffs**: Review past agent activities with detailed code diffs.
- **CI/CD Ready**: Configured for seamless deployment via Cloudflare Pages.

## Deployment to Cloudflare Pages

This repository is designed to work out-of-the-box with Cloudflare Pages.

1.  Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.  Navigate to **Workers & Pages** > **Create application** > **Pages** > **Connect to Git**.
3.  Select the `mobiledashboard` repository.
4.  **Build Settings**:
    - **Framework preset**: None (Static site)
    - **Build command**: (Leave empty)
    - **Build output directory**: `/` (Root)
5.  Click **Save and Deploy**.

Cloudflare will automatically deploy every push to the `main` branch.

## Tech Stack
- **HTML5**
- **Tailwind CSS** (via CDN for rapid prototyping)
- **Phosphor Icons**
- **Cloudflare Pages** (CI/CD)

<!-- AGENT_MEAUXBILITY_FILETREE_START -->
# Agent Meauxbility App Map

This repo powers `https://agent.meauxbility.workers.dev`.

## Current live worker

```txt
Worker name: agent
Worker entry: worker.js
SPA entry: index.html
Wrangler config: wrangler.json

Runtime bindings:
  env.DB  -> D1 database inneranimalmedia-business
  env.CMS -> R2 bucket cms

Bucket roles:
  env.CMS / cms -> clean CMS editor drafts, test page JSON, section JSON, sandbox artifacts
  CLOUDFLARE_R2_BUCKET / inneranimalmedia -> production themes, public assets, published artifacts

Routes:
  /             Agents
  /automations Automations
  /dashboard   Dashboard
  /cms         CMS editor
```

## Proposed filetree

```txt
mobiledashboard/
  README.md
  wrangler.json
  worker.js
  index.html

  agents/
    agent-meauxbility-cms/
      README.md
      SKILL.md
      agentsam_db_contract.py
      prompts/

  apps/
    agent-meauxbility/
      src/
        routes/
          AgentsPage.jsx
          AutomationsPage.jsx
          DashboardPage.jsx
          CmsPage.jsx
        shell/
        agents/
        automations/
        dashboard/
        cms/

  packages/
    cms-components/
    cms-schemas/
    cms-editor/
    agentsam-runtime/

  scripts/
    cms/
      load-agent-meauxbility-env.sh
      execute_agent_meauxbility_phases.mjs
      run_agent_meauxbility_overnight.sh
      py1_update_readme_filetree.py

  tmp/
    agent-meauxbility/
```

## Next README update chunks

```txt
py2 -> add agentsam_* table inventory
py3 -> add cms_* table inventory
py4 -> add API map and validation commands
```
<!-- AGENT_MEAUXBILITY_FILETREE_END -->

<!-- AGENT_MEAUXBILITY_AGENTSAM_TABLES_START -->

## Required Agent Sam telemetry contract

Any Agent Sam run that calls a model or tool must capture these values. If any required capture is missing, the run should be treated as failed for validation purposes.

| Required capture | Expected storage | Notes |
|---|---|---|
| Input tokens | `input_tokens` or `tokens_in` | Exact provider-reported count when available. |
| Output tokens | `output_tokens` or `tokens_out` | Exact provider-reported count when available. |
| Total tokens | `total_tokens` or computed input + output | Required for cost and routing comparisons. |
| Latency | `latency_ms` or `duration_ms` | Wall-clock elapsed time in milliseconds. |
| Cost | `cost_usd` | Must be calculated from provider/model pricing and token counts. Store full precision; UI can round to cents. |
| Provider/model | `provider`, `model`, `model_key` | Required for model routing and cost attribution. |
| Run linkage | `run_group_id`, `workflow_run_id`, `execution_id`, `execution_step_id` where applicable | Required for E2E traceability. |

### Core telemetry tables checked

| Table | Exists | Rows | Present telemetry columns | Status |
|---|---:|---:|---|---|
| `agentsam_usage_events` | yes | 426 | `total_tokens, tokens_in, tokens_out, duration_ms, cost_usd, model, model_key, provider, created_at` | OK |
| `agentsam_tool_chain` | yes | 43 | `input_tokens, output_tokens, duration_ms, cost_usd, started_at, completed_at` | MISSING model/provider |
| `agentsam_execution_steps` | yes | 22 | `tokens_in, tokens_out, latency_ms, cost_usd, created_at, started_at, completed_at` | MISSING model/provider |
| `agentsam_workflow_runs` | yes | 21 | `input_tokens, output_tokens, duration_ms, cost_usd, created_at, started_at, completed_at` | MISSING model/provider |
| `agentsam_execution_performance_metrics` | yes | 47 | `input_tokens, output_tokens, model_key, provider` | MISSING latency, cost_usd |
| `agentsam_eval_runs` | yes | 21 | `input_tokens, output_tokens, latency_ms, cost_usd, model_key, provider` | OK |
| `agentsam_command_run` | yes | 87 | `input_tokens, output_tokens, duration_ms, cost_usd, created_at` | MISSING model/provider |

### Cost precision rule

Persist cost as `REAL cost_usd` with full calculated precision. Display may round to cents, but raw storage should not pre-round. If provider billing exposes exact charged cost later, reconcile the estimated `cost_usd` with the provider-billed value.

## Live `agentsam_*` DB table inventory

Total discovered: **84**

### Evals / Quality / Health

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_analytics` | 3 | `id, tenant_id, workspace_id, latency_ms, input_tokens, output_tokens, total_tokens` | PARTIAL |
| `agentsam_deployment_health` | 23 | `id, tenant_id, status, workspace_id` |  |
| `agentsam_eval_cases` | 19 | `id, tenant_id, created_at` |  |
| `agentsam_eval_suites` | 9 | `id, tenant_id, provider, created_at, updated_at` |  |
| `agentsam_health_daily` | 3 | `id, tenant_id, workspace_id` |  |

### Execution / Workflow / Telemetry

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_agent_run` | 315 | `id, user_id, workspace_id, status, input_tokens, output_tokens, cost_usd, started_at, completed_at, created_at, tenant_id` | PARTIAL |
| `agentsam_command_run` | 87 | `id, workspace_id, duration_ms, input_tokens, output_tokens, cost_usd, created_at, tenant_id, user_id` | MISSING model/provider |
| `agentsam_cron_runs` | 1235 | `id, status, tenant_id, workspace_id, started_at, completed_at, duration_ms, created_at` | PARTIAL |
| `agentsam_eval_runs` | 21 | `id, tenant_id, model_key, provider, input_tokens, output_tokens, latency_ms, cost_usd, run_group_id` | OK |
| `agentsam_execution_context` | 68 | `id, tenant_id, workspace_id, command_run_id, todo_id, created_at, execution_step_id` |  |
| `agentsam_execution_dependency_graph` | 7 | `id, tenant_id, workspace_id, user_id, run_group_id, workflow_run_id, plan_id, status, created_at, updated_at` |  |
| `agentsam_execution_performance_metrics` | 47 | `id, tenant_id, workspace_id, user_id, workflow_id, workflow_run_id, model_key, provider, input_tokens, output_tokens` | MISSING latency, cost_usd |
| `agentsam_execution_steps` | 22 | `id, execution_id, status, started_at, completed_at, latency_ms, tokens_in, tokens_out, cost_usd, created_at` | MISSING model/provider |
| `agentsam_executions` | 16 | `id, tenant_id, workspace_id, user_id, plan_id, todo_id, command_run_id, workflow_run_id, execution_step_id, model_key, provider, duration_ms, input_tokens, output_tokens` | PARTIAL |
| `agentsam_executions_backup_20260509_014549` | 16 | `id, tenant_id, workspace_id, user_id, plan_id, todo_id, command_run_id, workflow_run_id, execution_step_id, model_key, provider, duration_ms, input_tokens, output_tokens` | PARTIAL |
| `agentsam_hook_execution` | 78 | `id, tenant_id, workspace_id, user_id, plan_id, todo_id, command_run_id, source, status, duration_ms, created_at` | PARTIAL |
| `agentsam_mcp_tool_execution` | 20 | `id, input_tokens, output_tokens, duration_ms, cost_usd, created_at, tenant_id, user_id, workflow_id, workspace_id` | PARTIAL |
| `agentsam_mcp_workflows` | 52 | `id, status, created_at, updated_at, tenant_id, workspace_id` |  |
| `agentsam_script_runs` | 5 | `id, workspace_id, status, duration_ms, cost_usd, started_at, completed_at, created_at` | PARTIAL |
| `agentsam_tool_chain` | 43 | `id, tenant_id, workspace_id, user_id, plan_id, todo_id, command_run_id, duration_ms, input_tokens, output_tokens, cost_usd, started_at, completed_at, execution_step_id` | MISSING model/provider |
| `agentsam_usage_events` | 426 | `id, tenant_id, workspace_id, user_id, provider, model, tokens_in, tokens_out, cost_usd, status, created_at, model_key, duration_ms, total_tokens` | OK |
| `agentsam_usage_rollups_daily` | 31 | `tenant_id, workspace_id, tokens_in, tokens_out, cost_usd` | PARTIAL |
| `agentsam_workflow_edges` | 35 | `id, workflow_id, created_at` |  |
| `agentsam_workflow_nodes` | 30 | `id, workflow_id, created_at, updated_at` |  |
| `agentsam_workflow_runs` | 21 | `id, workflow_id, tenant_id, workspace_id, user_id, run_group_id, status, input_tokens, output_tokens, cost_usd, duration_ms, started_at, completed_at, created_at` | MISSING model/provider |
| `agentsam_workflows` | 14 | `id, tenant_id, workspace_id, created_at, updated_at` |  |

### Models / Prompts / Routing

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_model_catalog` | 23 | `id, model_key, provider, created_at, updated_at` |  |
| `agentsam_model_drift_signals` | 3 | `id, model_key, provider` |  |
| `agentsam_model_routing_memory` | 26 | `id, workspace_id, tenant_id, provider, model_key, created_at, updated_at` |  |
| `agentsam_model_tier` | 5 | `id, workspace_id, created_at, updated_at` |  |
| `agentsam_prompt_cache_keys` | 6 | `id, tenant_id, provider, model_key, workspace_id, user_id` |  |
| `agentsam_prompt_routes` | 24 | `id, tenant_id, created_at, updated_at` |  |
| `agentsam_prompt_versions` | 17 | `id, created_at, tenant_id, workspace_id, status, user_id` |  |
| `agentsam_route_requirements` | 18 | `id` |  |
| `agentsam_routing_arms` | 127 | `id, model_key, provider, updated_at, workspace_id` |  |
| `agentsam_tool_cache` | 0 | `id, workspace_id, tenant_id, provider, created_at, updated_at` |  |

### Other Agent Sam

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_ai` | 101 | `id, tenant_id, status, created_at, updated_at, provider, model_key` |  |
| `agentsam_approval_queue` | 6 | `id, tenant_id, workspace_id, user_id, plan_id, todo_id, workflow_run_id, command_run_id, status, created_at, execution_step_id` |  |
| `agentsam_artifacts` | 63 | `id, user_id, tenant_id, workspace_id, r2_key, source, created_at, updated_at` |  |
| `agentsam_bootstrap` | 12 | `id, workspace_id, tenant_id, user_id, created_at, updated_at` |  |
| `agentsam_browser_trusted_origin` | 10 | `workspace_id, user_id, created_at, updated_at` |  |
| `agentsam_cad_jobs` | 2 | `id, user_id, status, r2_key, created_at, updated_at` |  |
| `agentsam_code_index_job` | 8 | `id, user_id, workspace_id, status, started_at, completed_at, updated_at` |  |
| `agentsam_command_allowlist` | 155 | `id, user_id, workspace_id, created_at` |  |
| `agentsam_command_pattern` | 10 | `id, workspace_id, created_at, updated_at` |  |
| `agentsam_commands` | 496 | `id, workspace_id, created_at, updated_at, tenant_id` |  |
| `agentsam_compaction_events` | 0 | `id, tenant_id, provider, model_key, workspace_id, user_id` |  |
| `agentsam_error_log` | 12 | `id, workspace_id, tenant_id, source, created_at` |  |
| `agentsam_escalation` | 0 | `id, tenant_id, workspace_id, plan_id, todo_id, command_run_id, created_at, workflow_run_id, execution_step_id` |  |
| `agentsam_feature_flag` | 19 | `updated_at, created_at` |  |
| `agentsam_fetch_domain_allowlist` | 18 | `id, user_id, workspace_id, created_at` |  |
| `agentsam_guardrail_events` | 0 | `id, tenant_id, workspace_id, user_id, run_group_id, model_key, created_at` |  |
| `agentsam_guardrail_rulesets` | 2 | `id, tenant_id, workspace_id, user_id, status, created_at, updated_at` |  |
| `agentsam_guardrails` | 13 | `id, tenant_id, workspace_id, user_id, created_at, updated_at` |  |
| `agentsam_hook` | 14 | `id, tenant_id, workspace_id, user_id, provider, workflow_id, created_at` |  |
| `agentsam_ignore_pattern` | 10 | `id, user_id, workspace_id, source, created_at, updated_at` |  |
| `agentsam_rules_document` | 4 | `id, user_id, workspace_id, created_at, updated_at` |  |
| `agentsam_scripts` | 115 | `id, workspace_id, created_at, updated_at, tenant_id` |  |
| `agentsam_subscription_registry` | 16 | `id, tenant_id, provider, status, created_at, updated_at` |  |
| `agentsam_user_feature_override` | 0 | `user_id, updated_at` |  |
| `agentsam_user_policy` | 4 | `user_id, workspace_id, updated_at, tenant_id` |  |
| `agentsam_webhook_events` | 1393 | `id, tenant_id, provider, status, model_key, input_tokens, output_tokens, cost_usd, source` | PARTIAL |
| `agentsam_webhook_weekly` | 1 | `id, tenant_id, workspace_id, provider` |  |

### Plans / Todos / Context / Memory

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_context_digest` | 0 | `id, workspace_id, created_at, updated_at` |  |
| `agentsam_memory` | 116 | `id, tenant_id, user_id, workspace_id, source, created_at, updated_at` |  |
| `agentsam_plan_tasks` | 97 | `id, tenant_id, workspace_id, plan_id, todo_id, command_run_id, status, cost_usd, started_at, completed_at, created_at, execution_step_id, workflow_run_id` | PARTIAL |
| `agentsam_plans` | 16 | `id, tenant_id, workspace_id, status, cost_usd, created_at, updated_at, workflow_id, workflow_run_id` | PARTIAL |
| `agentsam_plans_old` | 15 | `id, tenant_id, workspace_id, status, cost_usd, created_at, updated_at, workflow_id, workflow_run_id` | PARTIAL |
| `agentsam_project_context` | 55 | `id, tenant_id, workspace_id, project_key, status, cost_usd, started_at, completed_at, created_at, updated_at` | PARTIAL |
| `agentsam_task_slos` | 3 | `updated_at` |  |
| `agentsam_todo` | 95 | `id, tenant_id, workspace_id, status, completed_at, created_at, updated_at, plan_id, project_key, cost_usd, started_at` | PARTIAL |
| `agentsam_workspace` | 23 | `id, tenant_id, status, created_at, updated_at` |  |
| `agentsam_workspace_state` | 5 | `id, workspace_id, created_at, updated_at` |  |

### Tools / MCP / Skills / Subagents

| Table | Rows | Key columns | Telemetry status |
|---|---:|---|---|
| `agentsam_mcp_allowlist` | 412 | `id, user_id, workspace_id, created_at, tenant_id` |  |
| `agentsam_mcp_servers` | 3 | `id, workspace_id, tenant_id, created_at, updated_at` |  |
| `agentsam_mcp_tools` | 393 | `id, user_id, created_at, input_tokens, output_tokens, duration_ms, updated_at, tenant_id, workspace_id` | PARTIAL |
| `agentsam_skill` | 48 | `id, tenant_id, user_id, workspace_id, created_at, updated_at` |  |
| `agentsam_skill_invocation` | 0 | `id, tenant_id, user_id, workspace_id, duration_ms, tokens_in, tokens_out, cost_usd` | PARTIAL |
| `agentsam_skill_revision` | 0 | `id, created_at` |  |
| `agentsam_slash_commands` | 42 | `id, created_at` |  |
| `agentsam_subagent_profile` | 41 | `id, user_id, workspace_id, created_at, updated_at, tenant_id` |  |
| `agentsam_tool_call_log` | 20 | `id, tenant_id, status, duration_ms, cost_usd, input_tokens, output_tokens, created_at, user_id, workflow_id, workspace_id` | PARTIAL |
| `agentsam_tool_stats_compacted` | 81 | `id, tenant_id, workspace_id, total_tokens` | PARTIAL |
| `agentsam_tools` | 40 | `id, created_at, updated_at` |  |

<!-- AGENT_MEAUXBILITY_AGENTSAM_TABLES_END -->
