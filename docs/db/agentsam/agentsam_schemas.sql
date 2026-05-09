-- Agent Sam Table DDL Dump
-- Captured: 2026-05-09T21:28:55.494566+00:00
-- Database: inneranimalmedia-business

-- ------------------------------------------------------------------------
-- agentsam_agent_run
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_agent_run (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT,
  conversation_id TEXT,
  status TEXT NOT NULL DEFAULT 'queued',
  trigger TEXT,
  model_id TEXT,
  idempotency_key TEXT,
  error_message TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  cost_usd REAL,
  started_at TEXT,
  completed_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
, agent_ai_id TEXT DEFAULT NULL, person_uuid TEXT, agent_id TEXT, ai_model_ref     TEXT, routing_arm_id   TEXT, chain_root_id    TEXT, tenant_id TEXT, work_session_id TEXT, timed_out INTEGER DEFAULT 0, sla_breach INTEGER DEFAULT 0, timeout_ms INTEGER DEFAULT 30000, command_id TEXT REFERENCES agentsam_commands(id));

-- ------------------------------------------------------------------------
-- agentsam_ai
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_ai (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  is_global INTEGER NOT NULL DEFAULT 1,
  name TEXT NOT NULL,
  role_name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  mode TEXT NOT NULL DEFAULT 'orchestrator',
  safety_level TEXT NOT NULL DEFAULT 'strict',
  tenant_scope TEXT NOT NULL DEFAULT 'multi_tenant',
  allowed_tenants_json TEXT DEFAULT '[]',
  blocked_tenants_json TEXT DEFAULT '[]',
  auth_strategy TEXT DEFAULT 'zero_trust_plus_oauth',
  required_roles_json TEXT DEFAULT '["super_admin"]',
  requires_human_approval INTEGER NOT NULL DEFAULT 1,
  approvals_policy_json TEXT DEFAULT '{}',
  integrations_json TEXT DEFAULT '{}',
  mcp_services_json TEXT DEFAULT '[]',
  tool_permissions_json TEXT DEFAULT '{}',
  rate_limits_json TEXT DEFAULT '{}',
  budgets_json TEXT DEFAULT '{}',
  model_policy_json TEXT DEFAULT '{}',
  cost_policy_json TEXT DEFAULT '{}',
  pii_policy_json TEXT DEFAULT '{}',
  security_policy_json TEXT DEFAULT '{}',
  findings_policy_json TEXT DEFAULT '{}',
  notification_policy_json TEXT DEFAULT '{}',
  telemetry_enabled INTEGER NOT NULL DEFAULT 1,
  telemetry_policy_json TEXT DEFAULT '{}',
  last_health_check INTEGER,
  last_run_at INTEGER,
  last_error TEXT,
  config_version INTEGER NOT NULL DEFAULT 1,
  config_hash TEXT,
  notes TEXT,
  user_email TEXT,
  additional_alert_emails_json TEXT DEFAULT '[]',
  owner_user_id TEXT,
  backup_user_email TEXT,
  alert_escalation_email TEXT,
  memory_policy_json TEXT DEFAULT '{}',
  total_runs INTEGER DEFAULT 0,
  total_cost_usd REAL DEFAULT 0.0,
  avg_response_ms INTEGER DEFAULT 0,
  success_rate REAL DEFAULT 0.0,
  created_by TEXT NOT NULL DEFAULT 'sam_primeaux',
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
, system_prompt TEXT, tool_invocation_style TEXT
  DEFAULT 'balanced'
  CHECK(tool_invocation_style IN ('aggressive', 'balanced', 'conservative')), icon TEXT NOT NULL DEFAULT '', access_mode TEXT NOT NULL DEFAULT 'read_write' CHECK(access_mode IN ('read_only','read_write')), sort_order INTEGER NOT NULL DEFAULT 0, context_max_tokens INTEGER DEFAULT 1000000, output_max_tokens INTEGER DEFAULT 64000, thinking_mode TEXT DEFAULT 'adaptive', effort TEXT DEFAULT 'medium', person_uuid TEXT, provider       TEXT, model_key      TEXT, api_platform   TEXT DEFAULT 'unknown', secret_key_name TEXT, size_class     TEXT DEFAULT 'medium', billing_unit   TEXT DEFAULT 'tokens', supports_cache      INTEGER DEFAULT 0, supports_tools      INTEGER DEFAULT 1, supports_vision     INTEGER DEFAULT 0, supports_web_search INTEGER DEFAULT 0, supports_fast_mode  INTEGER DEFAULT 0, context_default_tokens INTEGER DEFAULT 0, pricing_unit            TEXT DEFAULT 'usd_per_mtok', pricing_source          TEXT DEFAULT 'manual', input_rate_per_mtok     REAL, output_rate_per_mtok    REAL, cache_write_rate_per_mtok REAL, cache_read_rate_per_mtok  REAL, web_search_per_1k_usd   REAL DEFAULT 0, neurons_usd_per_1k      REAL DEFAULT 0, cost_per_unit           REAL, rpm_limit  INTEGER DEFAULT 0, itpm_limit INTEGER DEFAULT 0, otpm_limit INTEGER DEFAULT 0, show_in_picker  INTEGER DEFAULT 0, picker_eligible INTEGER DEFAULT 1, picker_group    TEXT, features_json    TEXT DEFAULT '{}', input_schema_json TEXT, supports_responses_api INTEGER DEFAULT 0, supports_parallel_tools INTEGER DEFAULT 1, supports_structured_output INTEGER DEFAULT 0, supports_prompt_cache INTEGER DEFAULT 0, supports_thinking INTEGER DEFAULT 0, requires_phase_param INTEGER DEFAULT 0, max_tool_calls_per_turn INTEGER DEFAULT 10);

-- ------------------------------------------------------------------------
-- agentsam_analytics
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_analytics" (
  id                            TEXT    PRIMARY KEY DEFAULT ('aan_' || lower(hex(randomblob(8)))),
  tenant_id                     TEXT    NOT NULL,
  period                        TEXT    NOT NULL CHECK(period IN ('session','daily','weekly','monthly','alltime')),
  period_date                   TEXT,
  top_tool                      TEXT,
  top_tool_calls                INTEGER DEFAULT 0,
  most_failed_tool              TEXT,
  most_failed_tool_failure_rate REAL    DEFAULT 0,
  total_tool_calls              INTEGER DEFAULT 0,
  total_tool_successes          INTEGER DEFAULT 0,
  total_tool_failures           INTEGER DEFAULT 0,
  overall_tool_success_rate     REAL    DEFAULT 0,
  top_model                     TEXT,
  top_model_sessions            INTEGER DEFAULT 0,
  top_provider                  TEXT,
  total_sessions                INTEGER DEFAULT 0,
  total_input_tokens            INTEGER DEFAULT 0,
  total_output_tokens           INTEGER DEFAULT 0,
  total_cache_tokens            INTEGER DEFAULT 0,
  total_cost_usd                REAL    DEFAULT 0,
  avg_cost_per_session          REAL    DEFAULT 0,
  avg_tokens_per_session        REAL    DEFAULT 0,
  cache_hit_rate                REAL    DEFAULT 0,
  cache_savings_usd             REAL    DEFAULT 0,
  tool_reliability_json         TEXT    DEFAULT '{}',
  model_breakdown_json          TEXT    DEFAULT '{}',
  broken_tools_json             TEXT    DEFAULT '[]',
  healthy_tools_json            TEXT    DEFAULT '[]',
  most_common_intent            TEXT,
  avg_session_length_turns      REAL    DEFAULT 0,
  computed_at                   INTEGER NOT NULL DEFAULT (unixepoch()),
  data_from                     INTEGER,
  data_to                       INTEGER,
  row_count_source              INTEGER DEFAULT 0,
  notes                         TEXT,
  workspace_id                  TEXT,
  sla_breaches                  INTEGER DEFAULT 0,
  timed_out_calls               INTEGER DEFAULT 0,
  time_tracked_seconds          INTEGER DEFAULT 0, latency_ms INTEGER, input_tokens INTEGER DEFAULT 0, output_tokens INTEGER DEFAULT 0, total_tokens INTEGER DEFAULT 0, cached_input_tokens INTEGER DEFAULT 0, cache_hit INTEGER DEFAULT 0, cache_key TEXT, cost_usd_estimate REAL DEFAULT 0, route_reason TEXT, task_type TEXT, retry_count INTEGER DEFAULT 0,
  UNIQUE(tenant_id, workspace_id, period, period_date)
);

-- ------------------------------------------------------------------------
-- agentsam_approval_queue
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_approval_queue" (
  id              TEXT    PRIMARY KEY DEFAULT ('appr_' || lower(hex(randomblob(8)))),
  tenant_id       TEXT    NOT NULL,
  workspace_id    TEXT,
  user_id         TEXT    NOT NULL,
  session_id      TEXT,

  -- Chain linkage — all three locked with FKs
  plan_id         TEXT    REFERENCES "agentsam_plans_old"(id)          ON DELETE SET NULL,
  todo_id         TEXT    REFERENCES agentsam_todo(id)            ON DELETE CASCADE,
  workflow_run_id TEXT    REFERENCES agentsam_workflow_runs(id)   ON DELETE SET NULL,
  command_run_id  TEXT    REFERENCES agentsam_command_run(id)     ON DELETE SET NULL,

  -- What needs approval
  tool_name       TEXT    NOT NULL,
  tool_id         TEXT,
  tool_key        TEXT,
  action_summary  TEXT    NOT NULL,
  input_json      TEXT    DEFAULT '{}',
  risk_level      TEXT    DEFAULT 'medium',
  approval_type   TEXT    DEFAULT 'tool',

  -- Resolution
  status          TEXT    DEFAULT 'pending'
                          CHECK (status IN ('pending','approved','denied','expired')),
  approved_by     TEXT,
  decided_at      INTEGER,
  expires_at      INTEGER DEFAULT (unixepoch() + 300),

  -- Meta
  person_uuid     TEXT,
  created_at      INTEGER DEFAULT (unixepoch())
, execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL);

-- ------------------------------------------------------------------------
-- agentsam_artifacts
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_artifacts" (
  id TEXT PRIMARY KEY DEFAULT ('art_' || lower(hex(randomblob(8)))),
  user_id TEXT NOT NULL,
  tenant_id TEXT NOT NULL,       -- required, no default
  workspace_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  artifact_type TEXT NOT NULL DEFAULT 'html',
  r2_key TEXT NOT NULL,
  public_url TEXT,
  source TEXT NOT NULL,          -- required, no default
  tags TEXT DEFAULT '[]',
  is_public INTEGER DEFAULT 0,
  file_size_bytes INTEGER,
  created_at INTEGER DEFAULT (unixepoch()),
  updated_at INTEGER DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_bootstrap
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_bootstrap (
  id                           TEXT NOT NULL PRIMARY KEY,
  workspace_id                 TEXT NOT NULL,
  tenant_id                    TEXT NOT NULL,
  brand_id                     TEXT,
  user_id                      TEXT,
  session_id                   TEXT,
  email                        TEXT,
  role_slug                    TEXT,
  display_name                 TEXT,
  workspace_slug               TEXT,
  workspace_name               TEXT,
  environment                  TEXT NOT NULL DEFAULT 'production'
                                 CHECK (environment IN ('production','sandbox','staging','development')),
  deploy_env                   TEXT,
  bootstrap_version            TEXT DEFAULT '1.0.0',
  is_active                    INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0,1)),
  capabilities_json            TEXT NOT NULL DEFAULT '{}',
  governance_roles_json        TEXT NOT NULL DEFAULT '[]',
  approval_required_json       TEXT NOT NULL DEFAULT '[]',
  allowed_execution_modes_json TEXT NOT NULL DEFAULT '["pty"]',
  default_execution_mode       TEXT NOT NULL DEFAULT 'pty',
  runtime_status_json          TEXT NOT NULL DEFAULT '{}',
  backend_health_json          TEXT NOT NULL DEFAULT '{}',
  feature_flags_json           TEXT NOT NULL DEFAULT '{}',
  ui_preferences_json          TEXT NOT NULL DEFAULT '{}',
  theme_slug                   TEXT,
  agent_session_id             TEXT,
  terminal_session_id          TEXT,
  resume_token                 TEXT,
  resume_expires_at            TEXT,
  api_base_url                 TEXT DEFAULT '/api',
  terminal_ws_path             TEXT,
  agent_api_path               TEXT,
  mcp_api_path                 TEXT,
  cloud_api_path               TEXT,
  source_of_truth              TEXT DEFAULT 'worker',
  last_bootstrapped_at         TEXT,
  last_validated_at            TEXT,
  expires_at                   TEXT,
  created_at                   TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at                   TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
, person_uuid TEXT, repo_json TEXT NOT NULL DEFAULT '{}', scripts_json TEXT NOT NULL DEFAULT '[]');

-- ------------------------------------------------------------------------
-- agentsam_browser_trusted_origin
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_browser_trusted_origin" (
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  origin TEXT NOT NULL,
  cert_fingerprint_sha256 TEXT,
  trust_scope TEXT NOT NULL DEFAULT 'persistent',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  person_uuid TEXT,
  PRIMARY KEY (workspace_id, user_id, origin)
);

-- ------------------------------------------------------------------------
-- agentsam_cad_jobs
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_cad_jobs (id TEXT PRIMARY KEY, session_id TEXT, user_id TEXT NOT NULL, engine TEXT NOT NULL, prompt TEXT, mode TEXT DEFAULT 'text', status TEXT DEFAULT 'pending', external_task_id TEXT, result_url TEXT, r2_key TEXT, error TEXT, created_at INTEGER DEFAULT (unixepoch()), updated_at INTEGER DEFAULT (unixepoch()));

-- ------------------------------------------------------------------------
-- agentsam_code_index_job
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_code_index_job (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL,

  -- Lifecycle
  status TEXT NOT NULL DEFAULT 'idle',
  -- idle | queued | indexing | completed | failed | stale
  progress_percent INTEGER DEFAULT 0,

  -- Source config
  source_type TEXT DEFAULT 'r2',
  -- r2 | github | local
  source_path TEXT,
  -- R2 prefix or GitHub repo path
  vector_backend TEXT DEFAULT 'supabase_pgvector',
  -- supabase_pgvector | vectorize | d1_cosine

  -- File manifest — JSON array of objects:
  -- [{path, language, size_bytes, hash, status, chunk_count, symbol_count, last_indexed_at}]
  file_manifest TEXT DEFAULT '[]',

  -- Symbol summary — JSON:
  -- {total, by_type: {function: N, class: N, component: N, hook: N}, top_exports: [...]}
  symbol_summary TEXT DEFAULT '{}',

  -- Dependency graph — JSON:
  -- {edges: [{from, to, type}], orphans: [...], entry_points: [...]}
  dependency_summary TEXT DEFAULT '{}',

  -- Language breakdown — JSON: {js: N, jsx: N, ts: N, tsx: N, css: N}
  languages TEXT DEFAULT '{}',

  -- Counters
  file_count INTEGER DEFAULT 0,
  indexed_file_count INTEGER DEFAULT 0,
  failed_file_count INTEGER DEFAULT 0,
  total_size_bytes INTEGER DEFAULT 0,
  chunk_count INTEGER DEFAULT 0,
  symbol_count INTEGER DEFAULT 0,

  -- Trigger + timing
  triggered_by TEXT DEFAULT 'manual',
  -- manual | cron | git_push | webhook
  started_at TEXT,
  completed_at TEXT,
  last_sync_at TEXT,
  last_error TEXT,

  updated_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT,

  UNIQUE (user_id, workspace_id)
);

-- ------------------------------------------------------------------------
-- agentsam_command_allowlist
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_command_allowlist (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '',
  command TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT,
  UNIQUE (user_id, workspace_id, command)
);

-- ------------------------------------------------------------------------
-- agentsam_command_pattern
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_command_pattern (
  id               TEXT PRIMARY KEY DEFAULT ('pat_' || lower(hex(randomblob(8)))),
  workspace_id     TEXT NOT NULL REFERENCES agentsam_workspace(id) ON DELETE CASCADE,
  pattern          TEXT NOT NULL,
  pattern_type     TEXT NOT NULL DEFAULT 'exact'
    CHECK(pattern_type IN ('exact','prefix','regex','glob')),
  mapped_command   TEXT NOT NULL,
  description      TEXT,
  category         TEXT DEFAULT 'misc'
    CHECK(category IN ('deploy','debug','db','r2','git','worker','misc')),
  risk_level       TEXT NOT NULL DEFAULT 'low'
    CHECK(risk_level IN ('none','low','medium','high','critical')),
  requires_confirmation INTEGER NOT NULL DEFAULT 0,
  is_active        INTEGER NOT NULL DEFAULT 1,
  use_count        INTEGER NOT NULL DEFAULT 0,
  last_used_at     INTEGER,
  created_at       TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(workspace_id, pattern)
);

-- ------------------------------------------------------------------------
-- agentsam_command_run
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_command_run (
  id TEXT PRIMARY KEY DEFAULT ('run_' || lower(hex(randomblob(8)))),
  workspace_id TEXT NOT NULL,
  session_id TEXT,
  conversation_id TEXT,
  user_input TEXT NOT NULL,
  normalized_intent TEXT,
  intent_category TEXT
    CHECK(intent_category IN ('deploy','debug','db','r2','git','worker','search','file','misc') OR intent_category IS NULL),
  tier_used INTEGER NOT NULL DEFAULT 0,
  model_id TEXT,
  commands_json TEXT NOT NULL DEFAULT '[]',
  result_json TEXT NOT NULL DEFAULT '{}',
  output_text TEXT,
  confidence_score REAL,
  success INTEGER NOT NULL DEFAULT 0,
  exit_code INTEGER,
  duration_ms INTEGER,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  cost_usd REAL DEFAULT 0,
  error_message TEXT,
  escalated_from_run_id TEXT REFERENCES agentsam_command_run(id) ON DELETE SET NULL,
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
, selected_command_id TEXT, selected_command_slug TEXT, risk_level TEXT, requires_confirmation INTEGER DEFAULT 0, approval_status TEXT DEFAULT 'not_required', tenant_id TEXT, user_id TEXT);

-- ------------------------------------------------------------------------
-- agentsam_commands
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_commands" (
  id                  TEXT PRIMARY KEY,
  workspace_id        TEXT NOT NULL,
  slug                TEXT,
  display_name        TEXT NOT NULL,
  description         TEXT,
  pattern             TEXT,
  pattern_type        TEXT DEFAULT 'exact',
  mapped_command      TEXT NOT NULL,
  command_args        TEXT,
  category            TEXT DEFAULT 'misc',
  subcategory         TEXT,
  risk_level          TEXT DEFAULT 'low',
  requires_confirmation INTEGER DEFAULT 0,
  show_in_slash       INTEGER DEFAULT 1,
  show_in_allowlist   INTEGER DEFAULT 1,
  show_in_palette     INTEGER DEFAULT 1,
  modes_json          TEXT DEFAULT '["agent","auto","debug"]',
  sort_order          INTEGER DEFAULT 50,
  use_count           INTEGER DEFAULT 0,
  last_used_at        TEXT,
  is_active           INTEGER DEFAULT 1,
  created_at          TEXT DEFAULT (datetime('now')),
  updated_at          TEXT DEFAULT (datetime('now')),
  internal_seo        TEXT DEFAULT '',
  task_type           TEXT DEFAULT 'tool_use',
  timeout_seconds     INTEGER DEFAULT 120,
  estimated_cost_usd  REAL DEFAULT 0.0,
  allowed_models_json TEXT DEFAULT '[]',
  output_schema       TEXT DEFAULT '{}',
  retry_policy        TEXT DEFAULT 'once',
  requires_approval   INTEGER DEFAULT 0,
  tenant_id           TEXT,
  success_count       INTEGER DEFAULT 0,
  failure_count       INTEGER DEFAULT 0,
  avg_duration_ms     REAL DEFAULT 0,
  router_type         TEXT DEFAULT 'tool',
  tool_key            TEXT,
  workflow_key        TEXT,
  subagent_slug       TEXT,
  server_key          TEXT,
  execution_mode      TEXT DEFAULT 'agent',
  is_global           INTEGER DEFAULT 1,
  route_key           TEXT DEFAULT NULL
                    REFERENCES agentsam_prompt_routes(route_key) ON UPDATE CASCADE,
  UNIQUE(workspace_id, slug)
);

-- ------------------------------------------------------------------------
-- agentsam_compaction_events
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_compaction_events (
  id TEXT PRIMARY KEY DEFAULT ('cmp_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL DEFAULT 'tenant_sam_primeaux',
  session_id TEXT,
  provider TEXT NOT NULL,
  model_key TEXT NOT NULL,
  tokens_before INTEGER NOT NULL,
  tokens_after INTEGER NOT NULL,
  tokens_saved INTEGER GENERATED ALWAYS AS (tokens_before - tokens_after) STORED,
  cost_saved_usd REAL DEFAULT 0,
  compaction_strategy TEXT CHECK(compaction_strategy IN ('summarize','truncate','selective','full')) DEFAULT 'summarize',
  summary_text TEXT,
  compacted_at TEXT NOT NULL DEFAULT (datetime('now'))
, agent_id TEXT, workspace_id TEXT, user_id TEXT, person_uuid TEXT, metadata_json TEXT DEFAULT '{}');

-- ------------------------------------------------------------------------
-- agentsam_context_digest
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_context_digest (
  id TEXT PRIMARY KEY DEFAULT ('cd_' || lower(hex(randomblob(8)))),
  workspace_id TEXT NOT NULL,
  digest_type TEXT NOT NULL CHECK(digest_type IN ('schema','repo','docs','memory','tool_registry','route_map','session','deployment','rag')),
  source_hash TEXT NOT NULL,
  digest_hash TEXT NOT NULL UNIQUE,
  raw_size_bytes INTEGER,
  reduced_size_bytes INTEGER,
  token_count INTEGER,
  digest_text TEXT NOT NULL,
  source_updated_at TEXT,
  generation_model TEXT,
  namespace TEXT,
  hit_count INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ------------------------------------------------------------------------
-- agentsam_cron_runs
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_cron_runs (
  id TEXT PRIMARY KEY DEFAULT ('acr_' || lower(hex(randomblob(8)))),
  job_name TEXT NOT NULL,
  cron_expression TEXT,
  status TEXT NOT NULL DEFAULT 'running'
    CHECK(status IN ('running','completed','failed','skipped')),
  tenant_id TEXT,
  workspace_id TEXT,
  started_at INTEGER NOT NULL DEFAULT (unixepoch()),
  completed_at INTEGER,
  duration_ms INTEGER,
  rows_read INTEGER DEFAULT 0,
  rows_written INTEGER DEFAULT 0,
  error_message TEXT,
  metadata_json TEXT DEFAULT '{}',
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_deployment_health
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_deployment_health (
  id TEXT PRIMARY KEY DEFAULT ('dhc_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL DEFAULT 'tenant_sam_primeaux',
  deployment_id TEXT NOT NULL,
  worker_name TEXT NOT NULL,
  environment TEXT NOT NULL DEFAULT 'production',
  check_type TEXT NOT NULL
    CHECK(check_type IN ('http_ping','api_response','d1_query','r2_read','benchmark','smoke_test','manual')),
  check_url TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK(status IN ('pending','healthy','degraded','failed','timeout','skipped')),
  http_status_code INTEGER,
  response_time_ms INTEGER,
  error_message TEXT,
  metadata_json TEXT DEFAULT '{}',
  checked_by TEXT DEFAULT 'cron',
  checked_at TEXT NOT NULL DEFAULT (datetime('now')), workspace_id TEXT,
  FOREIGN KEY (deployment_id) REFERENCES deployments(id)
);

-- ------------------------------------------------------------------------
-- agentsam_error_log
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_error_log (
  id TEXT PRIMARY KEY DEFAULT ('err_' || lower(hex(randomblob(8)))),
  workspace_id TEXT NOT NULL,
  tenant_id TEXT NOT NULL,
  session_id TEXT,
  error_code TEXT,
  error_type TEXT NOT NULL,
  error_message TEXT NOT NULL,
  source TEXT NOT NULL,
  source_id TEXT,
  context_json TEXT DEFAULT '{}',
  stack_trace TEXT,
  resolved INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_escalation
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_escalation" (
  id             TEXT    PRIMARY KEY DEFAULT ('esc_' || lower(hex(randomblob(8)))),
  tenant_id      TEXT    NOT NULL,
  workspace_id   TEXT    NOT NULL,
  plan_id        TEXT    REFERENCES "agentsam_plans_old"(id)        ON DELETE SET NULL,
  todo_id        TEXT    REFERENCES agentsam_todo(id)          ON DELETE SET NULL,
  command_run_id TEXT    NOT NULL REFERENCES agentsam_command_run(id) ON DELETE CASCADE,
  from_tier      INTEGER NOT NULL,
  from_model     TEXT,
  to_tier        INTEGER NOT NULL,
  to_model       TEXT    NOT NULL,
  reason         TEXT    NOT NULL CHECK(reason IN ('low_confidence','execution_failure','timeout','complexity','user_requested','recovery')),
  context_tokens INTEGER DEFAULT 0,
  success        INTEGER,
  agent_id       TEXT,
  created_at     INTEGER NOT NULL DEFAULT (unixepoch())
, workflow_run_id TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL, execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL);

-- ------------------------------------------------------------------------
-- agentsam_eval_cases
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_eval_cases" (
  id               TEXT PRIMARY KEY DEFAULT ('evc_' || lower(hex(randomblob(8)))),
  suite_id         TEXT NOT NULL REFERENCES agentsam_eval_suites(id),
  tenant_id        TEXT NOT NULL,
  input_prompt     TEXT NOT NULL,
  expected_output  TEXT,
  grading_criteria TEXT,
  tags             TEXT DEFAULT '[]',
  is_edge_case     INTEGER DEFAULT 0,
  sort_order       INTEGER DEFAULT 50,
  created_at       TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_eval_runs
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_eval_runs" (
  id                   TEXT PRIMARY KEY DEFAULT ('evr_' || lower(hex(randomblob(8)))),
  suite_id             TEXT NOT NULL REFERENCES agentsam_eval_suites(id),
  case_id              TEXT REFERENCES agentsam_eval_cases(id),
  tenant_id            TEXT NOT NULL,
  model_key            TEXT NOT NULL,
  provider             TEXT NOT NULL,
  input_tokens         INTEGER DEFAULT 0,
  output_tokens        INTEGER DEFAULT 0,
  latency_ms           INTEGER DEFAULT 0,
  cost_usd             REAL DEFAULT 0,
  score_quality        REAL,
  score_latency        REAL,
  score_cost           REAL,
  score_tool_use       REAL,
  score_safety         REAL,
  score_overall        REAL,
  passed               INTEGER DEFAULT 0,
  output_text          TEXT,
  grader_notes         TEXT,
  grader_model         TEXT,
  run_at               TEXT NOT NULL DEFAULT (datetime('now')),
  cached_input_tokens  INTEGER DEFAULT 0,
  schema_valid         INTEGER DEFAULT NULL,
  retry_count          INTEGER DEFAULT 0,
  prompt_version_id    TEXT REFERENCES agentsam_prompt_versions(id),
  run_group_id         TEXT,
  tool_calls_attempted INTEGER DEFAULT 0,
  tool_calls_succeeded INTEGER DEFAULT 0,
  failure_taxonomy     TEXT
);

-- ------------------------------------------------------------------------
-- agentsam_eval_suites
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_eval_suites" (
  id          TEXT PRIMARY KEY DEFAULT ('evs_' || lower(hex(randomblob(8)))),
  tenant_id   TEXT NOT NULL,
  name        TEXT NOT NULL,
  description TEXT,
  provider    TEXT,
  mode        TEXT CHECK(mode IN (
                'ask','plan','agent','debug','auto',
                'ui_review','mcp','terminal','deploy','cost','context'
              )) DEFAULT 'auto',
  task_type   TEXT,
  is_active   INTEGER DEFAULT 1,
  run_count   INTEGER DEFAULT 0,
  last_run_at TEXT,
  created_by  TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_execution_context
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_execution_context" (
  id             TEXT    PRIMARY KEY DEFAULT ('ctx_' || lower(hex(randomblob(8)))),
  tenant_id      TEXT,
  workspace_id   TEXT,
  command_run_id TEXT    NOT NULL REFERENCES agentsam_command_run(id) ON DELETE CASCADE,
  todo_id        TEXT    REFERENCES agentsam_todo(id) ON DELETE SET NULL,
  cwd            TEXT,
  files_json     TEXT    DEFAULT '[]',
  recent_error   TEXT,
  goal           TEXT,
  extra_json     TEXT    DEFAULT '{}',
  context_tokens INTEGER DEFAULT 0,
  created_at     INTEGER NOT NULL DEFAULT (unixepoch())
, execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL);

-- ------------------------------------------------------------------------
-- agentsam_execution_dependency_graph
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_execution_dependency_graph (
  id TEXT PRIMARY KEY DEFAULT ('edg_' || lower(hex(randomblob(8)))),

  tenant_id TEXT NOT NULL,
  workspace_id TEXT,
  user_id TEXT,

  run_group_id TEXT,
  workflow_run_id TEXT,
  plan_id TEXT,
  plan_task_id TEXT,

  chain_id TEXT NOT NULL,
  depends_on_chain_id TEXT NOT NULL,

  dependency_type TEXT NOT NULL CHECK (
    dependency_type IN (
      'sequential',
      'conditional',
      'parallel_allowed',
      'compensation',
      'approval_gate',
      'guardrail_gate'
    )
  ),

  condition_expression TEXT,
  condition_json TEXT DEFAULT '{}',

  compensation_chain_id TEXT,

  status TEXT NOT NULL DEFAULT 'active' CHECK (
    status IN (
      'active',
      'waiting',
      'satisfied',
      'blocked',
      'skipped',
      'failed',
      'archived'
    )
  ),

  last_evaluated_at INTEGER,
  metadata_json TEXT NOT NULL DEFAULT '{}',

  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch()),

  FOREIGN KEY (chain_id) REFERENCES agentsam_tool_chain(id) ON DELETE CASCADE,
  FOREIGN KEY (depends_on_chain_id) REFERENCES agentsam_tool_chain(id) ON DELETE CASCADE,
  FOREIGN KEY (compensation_chain_id) REFERENCES agentsam_tool_chain(id) ON DELETE SET NULL,

  UNIQUE(chain_id, depends_on_chain_id)
);

-- ------------------------------------------------------------------------
-- agentsam_execution_performance_metrics
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_execution_performance_metrics (
  id TEXT PRIMARY KEY DEFAULT ('epm_' || lower(hex(randomblob(8)))),

  tenant_id TEXT NOT NULL,
  workspace_id TEXT,
  user_id TEXT,

  metric_date TEXT NOT NULL,
  metric_grain TEXT NOT NULL DEFAULT 'daily' CHECK (
    metric_grain IN ('hourly', 'daily', 'weekly', 'monthly')
  ),

  source_table TEXT NOT NULL DEFAULT 'mixed' CHECK (
    source_table IN (
      'agentsam_command_run',
      'agentsam_tool_call_log',
      'agentsam_tool_chain',
      'agentsam_workflow_runs',
      'mixed'
    )
  ),

  command_id TEXT,
  command_slug TEXT,
  tool_name TEXT,
  tool_category TEXT,
  workflow_id TEXT,
  workflow_run_id TEXT,
  chain_id TEXT,

  task_type TEXT,
  intent_category TEXT,
  trigger_key TEXT,

  model_key TEXT,
  provider TEXT,
  routing_arm_id TEXT,

  execution_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  failure_count INTEGER DEFAULT 0,
  timeout_count INTEGER DEFAULT 0,
  blocked_count INTEGER DEFAULT 0,
  skipped_count INTEGER DEFAULT 0,
  cancelled_count INTEGER DEFAULT 0,
  approval_required_count INTEGER DEFAULT 0,
  sla_breach_count INTEGER DEFAULT 0,

  avg_duration_ms REAL DEFAULT 0,
  min_duration_ms INTEGER DEFAULT 0,
  max_duration_ms INTEGER DEFAULT 0,
  median_duration_ms INTEGER DEFAULT 0,
  p95_duration_ms INTEGER DEFAULT 0,
  p99_duration_ms INTEGER DEFAULT 0,

  success_rate_percent REAL DEFAULT 0,
  failure_rate_percent REAL DEFAULT 0,
  timeout_rate_percent REAL DEFAULT 0,
  sla_breach_rate_percent REAL DEFAULT 0,

  total_tokens_consumed INTEGER DEFAULT 0,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,

  total_cost_usd REAL DEFAULT 0,
  total_cost_cents REAL DEFAULT 0,
  avg_cost_usd REAL DEFAULT 0,

  avg_confidence_score REAL DEFAULT 0,
  avg_quality_score REAL DEFAULT 0,

  error_types_json TEXT DEFAULT '{}',
  status_counts_json TEXT DEFAULT '{}',
  metadata_json TEXT DEFAULT '{}',

  first_seen_at INTEGER,
  last_seen_at INTEGER,
  last_computed_at INTEGER DEFAULT (unixepoch()), node_key TEXT DEFAULT NULL,

  FOREIGN KEY (command_id) REFERENCES agentsam_commands(id) ON DELETE SET NULL,

  UNIQUE (
    tenant_id,
    workspace_id,
    metric_date,
    metric_grain,
    source_table,
    command_id,
    command_slug,
    tool_name,
    tool_category,
    workflow_id,
    task_type,
    intent_category,
    model_key,
    provider,
    trigger_key
  )
);

-- ------------------------------------------------------------------------
-- agentsam_execution_steps
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_execution_steps (
  id              TEXT    PRIMARY KEY DEFAULT ('estep_' || lower(hex(randomblob(8)))),
  execution_id    TEXT    NOT NULL REFERENCES agentsam_workflow_runs(id) ON DELETE CASCADE,
  node_key        TEXT    NOT NULL,
  node_type       TEXT,
  status          TEXT    NOT NULL DEFAULT 'pending'
                          CHECK(status IN (
                            'pending','running','success','failed',
                            'skipped','approval_pending','timed_out','retrying'
                          )),
  input_json      TEXT    DEFAULT '{}',
  output_json     TEXT    DEFAULT '{}',
  error_json      TEXT    DEFAULT '{}',
  started_at      INTEGER,
  completed_at    INTEGER,
  latency_ms      INTEGER,
  tokens_in       INTEGER DEFAULT 0,
  tokens_out      INTEGER DEFAULT 0,
  cost_usd        REAL    DEFAULT 0,
  quality_score   REAL,
  gate_results_json TEXT  DEFAULT '{}',
  approval_id     TEXT    REFERENCES agentsam_approval_queue(id) ON DELETE SET NULL,
  attempt         INTEGER DEFAULT 1,
  edge_taken      TEXT,
  created_at      TEXT    DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_executions
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_executions" (
  id TEXT PRIMARY KEY,
  tenant_id TEXT,
  workspace_id TEXT REFERENCES agentsam_workspace(id) ON DELETE SET NULL,
  user_id TEXT,

  plan_id TEXT REFERENCES agentsam_plans(id) ON DELETE SET NULL,
  todo_id TEXT REFERENCES agentsam_todo(id) ON DELETE SET NULL,
  command_run_id TEXT REFERENCES agentsam_command_run(id) ON DELETE SET NULL,

  workflow_run_id TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL,
  execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL,

  task_id TEXT NOT NULL,
  subagent_id TEXT,
  agent_id TEXT,
  work_session_id TEXT,

  execution_type TEXT NOT NULL,
  command TEXT,
  file_path TEXT,

  node_key TEXT,
  model_key TEXT,
  provider TEXT,

  output TEXT,
  error TEXT,

  duration_ms INTEGER,
  timed_out INTEGER DEFAULT 0,
  sla_breach INTEGER DEFAULT 0,
  timeout_ms INTEGER DEFAULT 120000,

  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  cost_usd REAL DEFAULT 0,
  quality_score REAL,

  status TEXT DEFAULT 'completed',

  created_at INTEGER NOT NULL DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_executions_backup_20260509_014549
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_executions_backup_20260509_014549(
  id TEXT,
  tenant_id TEXT,
  workspace_id TEXT,
  user_id TEXT,
  plan_id TEXT,
  todo_id TEXT,
  command_run_id TEXT,
  workflow_run_id TEXT,
  execution_step_id TEXT,
  task_id TEXT,
  subagent_id TEXT,
  agent_id TEXT,
  work_session_id TEXT,
  execution_type TEXT,
  command TEXT,
  file_path TEXT,
  node_key TEXT,
  model_key TEXT,
  provider TEXT,
  output TEXT,
  error TEXT,
  duration_ms INT,
  timed_out INT,
  sla_breach INT,
  timeout_ms INT,
  input_tokens INT,
  output_tokens INT,
  cost_usd REAL,
  quality_score REAL,
  status TEXT,
  created_at INT
);

-- ------------------------------------------------------------------------
-- agentsam_feature_flag
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_feature_flag (
  flag_key TEXT PRIMARY KEY,
  description TEXT,
  enabled_globally INTEGER NOT NULL DEFAULT 0,
  config_json TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
, enabled_for_tenants TEXT DEFAULT '[]', enabled_for_users TEXT DEFAULT '[]', rollout_pct INTEGER DEFAULT 0, environment TEXT DEFAULT 'all', flag_type TEXT DEFAULT 'boolean', expires_at INTEGER, created_at TEXT, created_by TEXT DEFAULT 'sam_primeaux', is_archived INTEGER DEFAULT 0, tags TEXT DEFAULT '[]');

-- ------------------------------------------------------------------------
-- agentsam_fetch_domain_allowlist
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_fetch_domain_allowlist (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '',
  host TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT,
  UNIQUE (user_id, workspace_id, host)
);

-- ------------------------------------------------------------------------
-- agentsam_guardrail_events
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_guardrail_events (
  id TEXT PRIMARY KEY,

  event_scope TEXT NOT NULL CHECK (
    event_scope IN ('global', 'tenant', 'workspace', 'user', 'session')
  ),

  tenant_id TEXT,
  workspace_id TEXT,
  user_id TEXT,
  identity_profile_id TEXT,

  session_id TEXT,
  conversation_id TEXT,
  request_id TEXT,
  run_group_id TEXT,

  guardrail_id TEXT,
  guardrail_key TEXT NOT NULL,
  ruleset_id TEXT,
  ruleset_key TEXT,

  category TEXT NOT NULL,
  severity TEXT NOT NULL,
  action TEXT NOT NULL,

  target_type TEXT NOT NULL,
  target_name TEXT,
  route_path TEXT,
  tool_name TEXT,
  model_key TEXT,

  decision TEXT NOT NULL CHECK (
    decision IN ('allowed', 'warned', 'approval_required', 'blocked', 'logged')
  ),

  reason TEXT,
  input_preview TEXT,
  output_preview TEXT,
  metadata_json TEXT NOT NULL DEFAULT '{}',

  created_at TEXT NOT NULL DEFAULT (datetime('now')),

  FOREIGN KEY (guardrail_id) REFERENCES agentsam_guardrails(id),
  FOREIGN KEY (ruleset_id) REFERENCES agentsam_guardrail_rulesets(id),

  CHECK (
    (event_scope = 'global')
    OR
    (event_scope = 'tenant' AND tenant_id IS NOT NULL)
    OR
    (event_scope = 'workspace' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
    OR
    (event_scope = 'user' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL AND user_id IS NOT NULL)
    OR
    (event_scope = 'session' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
  )
);

-- ------------------------------------------------------------------------
-- agentsam_guardrail_rulesets
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_guardrail_rulesets (
  id TEXT PRIMARY KEY,
  ruleset_key TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,

  scope TEXT NOT NULL CHECK (
    scope IN ('global', 'tenant', 'workspace', 'user', 'session')
  ),

  tenant_id TEXT,
  workspace_id TEXT,
  user_id TEXT,

  version INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'active' CHECK (
    status IN ('draft', 'active', 'archived')
  ),

  guardrail_keys_json TEXT NOT NULL DEFAULT '[]',
  metadata_json TEXT NOT NULL DEFAULT '{}',

  is_enabled INTEGER NOT NULL DEFAULT 1,
  priority INTEGER NOT NULL DEFAULT 100,

  created_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),

  CHECK (
    (scope = 'global' AND tenant_id IS NULL AND workspace_id IS NULL)
    OR
    (scope = 'tenant' AND tenant_id IS NOT NULL)
    OR
    (scope = 'workspace' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
    OR
    (scope = 'user' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL AND user_id IS NOT NULL)
    OR
    (scope = 'session' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
  ),

  UNIQUE(scope, tenant_id, workspace_id, user_id, ruleset_key, version)
);

-- ------------------------------------------------------------------------
-- agentsam_guardrails
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_guardrails (
  id TEXT PRIMARY KEY,

  scope TEXT NOT NULL CHECK (
    scope IN ('global', 'tenant', 'workspace', 'user', 'session')
  ),

  tenant_id TEXT,
  workspace_id TEXT,
  user_id TEXT,

  guardrail_key TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,

  category TEXT NOT NULL CHECK (
    category IN (
      'tenant_isolation',
      'tool_permission',
      'secret_protection',
      'deploy_safety',
      'data_access',
      'model_routing',
      'rag_retrieval',
      'browser_terminal',
      'code_modification',
      'email_external_action',
      'cost_budget',
      'compliance',
      'general'
    )
  ),

  severity TEXT NOT NULL DEFAULT 'medium' CHECK (
    severity IN ('info', 'low', 'medium', 'high', 'critical')
  ),

  action TEXT NOT NULL DEFAULT 'warn' CHECK (
    action IN ('allow', 'warn', 'require_approval', 'block', 'log_only')
  ),

  applies_to TEXT NOT NULL DEFAULT 'agent' CHECK (
    applies_to IN (
      'agent',
      'mcp_tool',
      'model',
      'route',
      'integration',
      'rag',
      'browser',
      'terminal',
      'deploy',
      'email',
      'storage',
      'all'
    )
  ),

  matcher_json TEXT NOT NULL DEFAULT '{}',
  policy_json TEXT NOT NULL DEFAULT '{}',
  metadata_json TEXT NOT NULL DEFAULT '{}',

  is_enabled INTEGER NOT NULL DEFAULT 1,
  priority INTEGER NOT NULL DEFAULT 100,

  created_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), tags_json TEXT DEFAULT '[]', version INTEGER DEFAULT 1,

  CHECK (
    (scope = 'global' AND tenant_id IS NULL AND workspace_id IS NULL)
    OR
    (scope = 'tenant' AND tenant_id IS NOT NULL)
    OR
    (scope = 'workspace' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
    OR
    (scope = 'user' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL AND user_id IS NOT NULL)
    OR
    (scope = 'session' AND tenant_id IS NOT NULL AND workspace_id IS NOT NULL)
  )
);

-- ------------------------------------------------------------------------
-- agentsam_health_daily
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_health_daily (
  id TEXT PRIMARY KEY DEFAULT ('ahd_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL DEFAULT 'tenant_sam_primeaux',
  day TEXT NOT NULL,
  health_status TEXT NOT NULL DEFAULT 'unknown',
  snapshot_count INTEGER NOT NULL DEFAULT 0,
  green_count INTEGER NOT NULL DEFAULT 0,
  yellow_count INTEGER NOT NULL DEFAULT 0,
  red_count INTEGER NOT NULL DEFAULT 0,
  avg_tools_degraded REAL DEFAULT 0,
  avg_rd_total REAL DEFAULT 0,
  avg_tel_cost_24h REAL DEFAULT 0,
  worst_status TEXT,
  health_notes TEXT,
  rolled_up_at TEXT NOT NULL DEFAULT (datetime('now')), workspace_id TEXT, sla_breach_count INTEGER DEFAULT 0, timed_out_count INTEGER DEFAULT 0, snapshot_json TEXT DEFAULT '{}',
  UNIQUE(tenant_id, day)
);

-- ------------------------------------------------------------------------
-- agentsam_hook
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_hook" (
  id            TEXT    PRIMARY KEY,
  tenant_id     TEXT,
  workspace_id  TEXT,
  user_id       TEXT    NOT NULL,
  provider      TEXT    NOT NULL DEFAULT 'system',
  external_id   TEXT,
  trigger       TEXT    NOT NULL
                        CHECK(trigger IN ('start','stop','pre_deploy','post_deploy',
                                          'pre_commit','error','imessage_reply','email_reply')),
  command       TEXT    NOT NULL DEFAULT '',
  target_id     TEXT    NOT NULL DEFAULT '',
  metadata      TEXT    DEFAULT '{}',
  is_active     INTEGER NOT NULL DEFAULT 1,
  run_count     INTEGER DEFAULT 0,
  last_run_at   TEXT,
  workflow_id   TEXT    REFERENCES agentsam_mcp_workflows(id) ON DELETE SET NULL,
  subagent_slug TEXT,
  person_uuid   TEXT,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_hook_execution
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_hook_execution" (
  id             TEXT    PRIMARY KEY DEFAULT ('hexec_' || lower(hex(randomblob(6)))),
  tenant_id      TEXT,
  workspace_id   TEXT,
  hook_id        TEXT    NOT NULL REFERENCES agentsam_hook(id) ON DELETE CASCADE,
  user_id        TEXT    NOT NULL,
  agent_id       TEXT,
  session_id     TEXT,
  plan_id        TEXT    REFERENCES "agentsam_plans_old"(id)       ON DELETE SET NULL,
  todo_id        TEXT    REFERENCES agentsam_todo(id)         ON DELETE SET NULL,
  command_run_id TEXT    REFERENCES agentsam_command_run(id) ON DELETE SET NULL,
  source         TEXT,
  event_type     TEXT,
  action         TEXT,
  actor          TEXT,
  target_type    TEXT,
  target_id      TEXT,
  payload_json   TEXT    DEFAULT '{}',
  metadata_json  TEXT    DEFAULT '{}',
  status         TEXT    NOT NULL CHECK(status IN ('success','fail','timeout')),
  duration_ms    INTEGER,
  output         TEXT,
  error          TEXT,
  person_uuid    TEXT,
  ran_at         TEXT    NOT NULL DEFAULT (datetime('now')),
  created_at     INTEGER DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_ignore_pattern
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_ignore_pattern (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  workspace_id TEXT,
  pattern TEXT NOT NULL,
  is_negation INTEGER NOT NULL DEFAULT 0,
  order_index INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'db',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
, person_uuid TEXT);

-- ------------------------------------------------------------------------
-- agentsam_mcp_allowlist
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_mcp_allowlist (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '',
  tool_key TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  notes TEXT
, person_uuid TEXT, agentsam_tools_id TEXT, risk_level_override TEXT, max_calls_per_day INTEGER, agent_id TEXT, tenant_id TEXT, is_allowed INTEGER DEFAULT 1, timeout_override_ms INTEGER, requires_approval INTEGER DEFAULT 0, granted_by TEXT);

-- ------------------------------------------------------------------------
-- agentsam_mcp_servers
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_mcp_servers (
  id               TEXT PRIMARY KEY DEFAULT ('mcps_' || lower(hex(randomblob(8)))),
  server_key       TEXT NOT NULL UNIQUE,
  display_name     TEXT NOT NULL,
  url              TEXT NOT NULL,
  auth_type        TEXT NOT NULL DEFAULT 'bearer',
  token_id         TEXT,
  workspace_id     TEXT,
  tenant_id        TEXT,
  is_active        INTEGER NOT NULL DEFAULT 1,
  timeout_ms       INTEGER NOT NULL DEFAULT 30000,
  health_check_url TEXT,
  last_health_at   INTEGER,
  health_status    TEXT DEFAULT 'unknown',
  avg_latency_ms   REAL,
  error_rate       REAL DEFAULT 0,
  created_at       INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at       INTEGER NOT NULL DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_mcp_tool_execution
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_mcp_tool_execution (
  id TEXT PRIMARY KEY,
  tool_id TEXT,
  tool_name TEXT,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  duration_ms INTEGER,
  cost_usd REAL DEFAULT 0,
  success INTEGER DEFAULT 1,
  error_message TEXT,
  created_at TEXT DEFAULT (datetime('now'))
, tenant_id TEXT DEFAULT 'tenant_sam_primeaux', session_id TEXT, user_id TEXT, workflow_id TEXT, input_json TEXT DEFAULT '{}', requires_approval INTEGER DEFAULT 0, retry_count INTEGER DEFAULT 0, output_json TEXT DEFAULT '{}', tool_chain_id TEXT, agentsam_tools_id TEXT, workspace_id TEXT, agent_id TEXT, timed_out INTEGER DEFAULT 0, sla_breach INTEGER DEFAULT 0, timeout_ms INTEGER DEFAULT 30000, tool_key TEXT, action_type TEXT, resource_type TEXT, resource_id TEXT, actor_type TEXT DEFAULT 'user', actor_source TEXT, policy_decision_json TEXT DEFAULT '{}', denial_code TEXT, error_code TEXT, error_family TEXT, error_detail_json TEXT DEFAULT '{}', error_log_id TEXT);

-- ------------------------------------------------------------------------
-- agentsam_mcp_tools
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_mcp_tools (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  tool_key TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT, tool_name TEXT DEFAULT '', display_name TEXT DEFAULT '', tool_category TEXT DEFAULT 'mcp', mcp_service_url TEXT DEFAULT '', description TEXT DEFAULT '', input_schema TEXT DEFAULT '{}', output_schema TEXT DEFAULT '{}', intent_tags TEXT DEFAULT '[]', intent_category_tags TEXT DEFAULT '', modes_json TEXT DEFAULT '["auto","agent","debug"]', handler_config TEXT DEFAULT '{}', categories_json TEXT DEFAULT '[]', schema_hint TEXT DEFAULT '', risk_level TEXT DEFAULT 'low', input_tokens INTEGER DEFAULT 0, output_tokens INTEGER DEFAULT 0, duration_ms INTEGER DEFAULT 0, trigger_config_json TEXT DEFAULT '{}', trigger_type TEXT DEFAULT 'manual', steps_json TEXT DEFAULT '[]', timeout_seconds INTEGER DEFAULT 120, requires_approval INTEGER DEFAULT 0, estimated_cost_usd REAL DEFAULT 0.0, last_used_at TEXT, updated_at TEXT, handler_type TEXT DEFAULT 'builtin', is_active INTEGER DEFAULT 1, workspace_scope TEXT DEFAULT '["ws_inneranimalmedia"]', is_degraded      INTEGER NOT NULL DEFAULT 0, failure_rate      REAL DEFAULT 0.0, avg_latency_ms    REAL DEFAULT NULL, last_health_check INTEGER DEFAULT NULL, sort_priority     INTEGER DEFAULT 50, cost_per_call_usd REAL DEFAULT 0.0, agentsam_tools_id TEXT, enabled INTEGER DEFAULT 1, tenant_id TEXT, workspace_id TEXT, agent_id TEXT, server_key TEXT, server_id TEXT, routing_scope TEXT DEFAULT 'workspace', last_error TEXT, health_status TEXT DEFAULT 'unknown', health_checked_at TEXT,
  UNIQUE(user_id, tool_key)
);

-- ------------------------------------------------------------------------
-- agentsam_mcp_workflows
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_mcp_workflows" (
  id                       TEXT PRIMARY KEY,
  workflow_key             TEXT NOT NULL,
  display_name             TEXT NOT NULL,
  description              TEXT,
  status                   TEXT NOT NULL DEFAULT 'ready',
  priority                 TEXT NOT NULL DEFAULT 'medium',
  steps_json               TEXT NOT NULL DEFAULT '[]',
  tools_json               TEXT NOT NULL DEFAULT '[]',
  acceptance_criteria_json TEXT NOT NULL DEFAULT '[]',
  notes                    TEXT,
  created_at               TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at               TEXT NOT NULL DEFAULT (datetime('now')),
  tenant_id                TEXT,
  workspace_id             TEXT,
  trigger_type             TEXT DEFAULT 'manual',
  trigger_config_json      TEXT DEFAULT '{}',
  input_schema_json        TEXT DEFAULT '{}',
  output_schema_json       TEXT DEFAULT '{}',
  requires_approval        INTEGER DEFAULT 0,
  risk_level               TEXT DEFAULT 'low',
  run_count                INTEGER DEFAULT 0,
  success_count            INTEGER DEFAULT 0,
  last_run_at              TEXT,
  last_run_status          TEXT,
  avg_duration_ms          REAL DEFAULT 0,
  total_cost_usd           REAL DEFAULT 0,
  version                  INTEGER DEFAULT 1,
  is_active                INTEGER DEFAULT 1,
  subagent_slug            TEXT,
  model_id                 TEXT,
  timeout_seconds          INTEGER DEFAULT 300,
  category                 TEXT DEFAULT 'general',
  parent_workflow_id       TEXT DEFAULT NULL,
  tags_json                TEXT DEFAULT '[]',
  retry_policy_json        TEXT DEFAULT '{"max_retries":2,"backoff":"exponential","delay_ms":2000,"retry_on":["timeout","network_error"]}',
  on_failure_json          TEXT DEFAULT '{"action":"notify","notify_channel":"resend"}',
  max_concurrent_runs      INTEGER DEFAULT 1,
  environment              TEXT DEFAULT 'production',
  visibility               TEXT DEFAULT 'workspace',
  input_defaults_json      TEXT DEFAULT '{}',
  last_error               TEXT DEFAULT NULL,
  task_type                TEXT DEFAULT 'agent_workflow',
  graph_mode               INTEGER DEFAULT 0,
  UNIQUE(workspace_id, workflow_key)
);

-- ------------------------------------------------------------------------
-- agentsam_memory
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_memory" (
  id               TEXT    PRIMARY KEY DEFAULT ('mem_' || lower(hex(randomblob(8)))),
  tenant_id        TEXT    NOT NULL,
  user_id          TEXT    NOT NULL,
  workspace_id     TEXT,
  memory_type      TEXT    DEFAULT 'fact'
                           CHECK (memory_type IN ('fact','preference','project','skill','error','decision')),
  key              TEXT    NOT NULL,
  value            TEXT    NOT NULL,
  source           TEXT,
  confidence       REAL    DEFAULT 1.0,
  decay_score      REAL    DEFAULT 1.0,
  recall_count     INTEGER DEFAULT 0,
  last_recalled_at INTEGER,
  expires_at       INTEGER,
  created_at       INTEGER DEFAULT (unixepoch()),
  updated_at       INTEGER DEFAULT (unixepoch()),
  agent_id         TEXT,
  session_id       TEXT,
  tags             TEXT    DEFAULT '[]',
  embedding_id     TEXT,
  UNIQUE(tenant_id, user_id, key)
);

-- ------------------------------------------------------------------------
-- agentsam_model_catalog
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_model_catalog (
  id                    TEXT PRIMARY KEY DEFAULT ('mdl_' || lower(hex(randomblob(6)))),
  model_key             TEXT UNIQUE NOT NULL,   

  
  display_name          TEXT NOT NULL,
  provider              TEXT NOT NULL CHECK(provider IN ('anthropic','openai','google','workers_ai','ollama')),
  tier                  TEXT NOT NULL CHECK(tier IN ('micro','flash','standard','power','reasoning')),

  
  anthropic_model_id    TEXT DEFAULT NULL,      
  openai_model_id       TEXT DEFAULT NULL,      
  google_model_id       TEXT DEFAULT NULL,      
  workers_ai_model_id   TEXT DEFAULT NULL,      
  ollama_model_id       TEXT DEFAULT NULL,      

  
  context_window        INTEGER NOT NULL,       
  max_output_tokens     INTEGER NOT NULL,

  
  cost_per_1k_in        REAL NOT NULL DEFAULT 0,
  cost_per_1k_out       REAL NOT NULL DEFAULT 0,
  cost_per_tool_call    REAL NOT NULL DEFAULT 0,
  cost_notes            TEXT DEFAULT NULL,      

  
  supports_tools        INTEGER NOT NULL DEFAULT 0,
  supports_vision       INTEGER NOT NULL DEFAULT 0,
  supports_streaming    INTEGER NOT NULL DEFAULT 1,
  supports_json_mode    INTEGER NOT NULL DEFAULT 0,
  supports_reasoning    INTEGER NOT NULL DEFAULT 0,   
  reasoning_effort      TEXT DEFAULT NULL CHECK(reasoning_effort IN ('low','medium','high',NULL)),

  
  avg_latency_p50_ms    INTEGER DEFAULT NULL,
  avg_latency_p95_ms    INTEGER DEFAULT NULL,
  quality_score         REAL DEFAULT NULL,      
  total_calls           INTEGER DEFAULT 0,
  total_failures        INTEGER DEFAULT 0,

  
  rate_limit_rpm        INTEGER DEFAULT NULL,
  rate_limit_tpd        INTEGER DEFAULT NULL,   

  
  is_active             INTEGER NOT NULL DEFAULT 1,
  is_degraded           INTEGER NOT NULL DEFAULT 0,
  budget_exhausted      INTEGER NOT NULL DEFAULT 0,
  degraded_reason       TEXT DEFAULT NULL,

  created_at            INTEGER DEFAULT (unixepoch()),
  updated_at            INTEGER DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_model_drift_signals
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_model_drift_signals (
  id TEXT PRIMARY KEY DEFAULT ('mds_' || lower(hex(randomblob(8)))),
  model_key TEXT NOT NULL,
  provider TEXT NOT NULL,
  task_type TEXT NOT NULL,
  case_id TEXT NOT NULL REFERENCES agentsam_eval_cases(id),
  baseline_score REAL NOT NULL,
  baseline_run_id TEXT REFERENCES agentsam_eval_runs(id),
  current_score REAL NOT NULL,
  current_run_id TEXT REFERENCES agentsam_eval_runs(id),
  delta REAL NOT NULL,
  delta_pct REAL NOT NULL,
  detected_at INTEGER NOT NULL DEFAULT (unixepoch()),
  severity TEXT NOT NULL CHECK(severity IN ('info','warn','regression','breaking')),
  acknowledged INTEGER NOT NULL DEFAULT 0,
  acknowledged_by TEXT,
  acknowledged_at INTEGER,
  notes TEXT
, ai_model_id TEXT, routing_arm_paused INTEGER DEFAULT 0, routing_arm_id     TEXT);

-- ------------------------------------------------------------------------
-- agentsam_model_routing_memory
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_model_routing_memory (
  id TEXT PRIMARY KEY DEFAULT ('mrm_' || lower(hex(randomblob(8)))),
  workspace_id TEXT,
  tenant_id TEXT,
  task_type TEXT NOT NULL,
  subtask_type TEXT,
  provider TEXT NOT NULL,
  model_key TEXT NOT NULL,
  avg_latency_ms REAL,
  avg_input_tokens REAL,
  avg_output_tokens REAL,
  avg_cost_usd REAL,
  success_rate REAL DEFAULT 0,
  retry_rate REAL DEFAULT 0,
  hallucination_rate REAL DEFAULT 0,
  tool_success_rate REAL DEFAULT 0,
  code_pass_rate REAL DEFAULT 0,
  browser_success_rate REAL DEFAULT 0,
  image_generation_score REAL DEFAULT 0,
  writing_quality_score REAL DEFAULT 0,
  reasoning_quality_score REAL DEFAULT 0,
  sample_count INTEGER DEFAULT 0,
  last_evaluated_at TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')), sample_n INTEGER DEFAULT 0,
  UNIQUE(task_type, model_key, workspace_id)
);

-- ------------------------------------------------------------------------
-- agentsam_model_tier
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_model_tier" (
      id TEXT PRIMARY KEY DEFAULT ('tier_' || lower(hex(randomblob(6)))),
      workspace_id TEXT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
      tier_level INTEGER NOT NULL CHECK(tier_level BETWEEN 0 AND 4),
      tier_name TEXT NOT NULL,
      model_id TEXT,
      api_platform TEXT,
      role_description TEXT NOT NULL,
      escalate_if_confidence_below REAL DEFAULT 0.75,
      escalate_after_failures INTEGER DEFAULT 1,
      max_context_tokens INTEGER DEFAULT 4096,
      max_output_tokens INTEGER DEFAULT 1024,
      cost_tier TEXT DEFAULT 'free' CHECK(cost_tier IN ('free','low','standard','high')),
      is_active INTEGER NOT NULL DEFAULT 1,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')), fallback_model_id TEXT, routing_arm_id    TEXT,
      UNIQUE(workspace_id, tier_level)
    );

-- ------------------------------------------------------------------------
-- agentsam_plan_tasks
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_plan_tasks" (
  id                TEXT    PRIMARY KEY DEFAULT ('task_' || lower(hex(randomblob(8)))),
  tenant_id         TEXT,
  workspace_id      TEXT,
  plan_id           TEXT    NOT NULL REFERENCES "agentsam_plans_old"(id)       ON DELETE CASCADE,
  todo_id           TEXT    REFERENCES agentsam_todo(id)                  ON DELETE SET NULL,
  command_run_id    TEXT    REFERENCES agentsam_command_run(id)           ON DELETE SET NULL,
  agent_id          TEXT,
  assigned_model    TEXT,
  order_index       INTEGER NOT NULL,
  title             TEXT    NOT NULL,
  description       TEXT,
  priority          TEXT    NOT NULL DEFAULT 'P1'
                            CHECK(priority IN ('P0','P1','P2','P3')),
  category          TEXT    DEFAULT 'backend'
                            CHECK(category IN ('frontend','backend','db','infra','ux','research','other')),
  status            TEXT    NOT NULL DEFAULT 'todo'
                            CHECK(status IN ('todo','in_progress','done','blocked','skipped','carried')),
  files_involved    TEXT    DEFAULT '[]',
  tables_involved   TEXT    DEFAULT '[]',
  routes_involved   TEXT    DEFAULT '[]',
  depends_on        TEXT    DEFAULT '[]',
  estimated_minutes INTEGER,
  actual_minutes    INTEGER,
  blocked_reason    TEXT,
  notes             TEXT,
  output_summary    TEXT,
  error_trace       TEXT,
  tokens_used       INTEGER DEFAULT 0,
  cost_usd          REAL    DEFAULT 0,
  started_at        INTEGER,
  completed_at      INTEGER,
  created_at        INTEGER DEFAULT (unixepoch())
, node_key TEXT DEFAULT NULL, execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL, workflow_run_id TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL, handler_key TEXT DEFAULT NULL, handler_type TEXT DEFAULT NULL CHECK(handler_type IN ('agent','db_query','terminal','mcp_tool','script','eval','branch','webhook',NULL)), risk_level TEXT DEFAULT 'low' CHECK(risk_level IN ('low','medium','high','critical')), requires_approval INTEGER DEFAULT 0, quality_gate_json TEXT DEFAULT '{}', edge_taken TEXT DEFAULT NULL);

-- ------------------------------------------------------------------------
-- agentsam_plans
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_plans (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  workspace_id TEXT,
  session_id TEXT,
  agent_id TEXT,
  client_id TEXT,
  client_name TEXT,
  plan_date TEXT NOT NULL,
  plan_type TEXT DEFAULT 'daily'
    CHECK(plan_type IN ('daily','sprint','incident','feature','refactor')),
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK(status IN ('draft','active','complete','abandoned')),
  morning_brief TEXT,
  session_notes TEXT,
  eod_summary TEXT,
  available_providers TEXT DEFAULT '["anthropic","openai","google","workers_ai"]',
  blocked_providers TEXT DEFAULT '[]',
  budget_snapshot TEXT DEFAULT '{}',
  default_model TEXT,
  token_budget INTEGER DEFAULT NULL,
  tokens_used INTEGER NOT NULL DEFAULT 0,
  cost_usd REAL NOT NULL DEFAULT 0,
  carry_over_from TEXT,
  carry_over_count INTEGER DEFAULT 0,
  tasks_total INTEGER DEFAULT 0,
  tasks_done INTEGER DEFAULT 0,
  tasks_blocked INTEGER DEFAULT 0,
  linked_project_keys TEXT DEFAULT '[]',
  linked_todo_ids TEXT DEFAULT '[]',
  linked_context_ids TEXT DEFAULT '[]',
  created_at INTEGER DEFAULT (unixepoch()),
  updated_at INTEGER DEFAULT (unixepoch()),
  workflow_id TEXT REFERENCES agentsam_workflows(id) ON DELETE SET NULL,
  workflow_run_id TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL,
  graph_mode INTEGER DEFAULT 0,
  risk_level TEXT DEFAULT 'low',
  requires_approval INTEGER DEFAULT 0
);

-- ------------------------------------------------------------------------
-- agentsam_plans_old
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_plans_old" (
  id                   TEXT    PRIMARY KEY,
  tenant_id            TEXT    NOT NULL,
  workspace_id         TEXT,
  session_id           TEXT,
  agent_id             TEXT,
  client_id            TEXT,
  client_name          TEXT,
  plan_date            TEXT    NOT NULL,
  plan_type            TEXT    DEFAULT 'daily'
                               CHECK(plan_type IN ('daily','sprint','incident','feature','refactor')),
  title                TEXT    NOT NULL,
  status               TEXT    NOT NULL DEFAULT 'active'
                               CHECK(status IN ('draft','active','complete','abandoned')),
  morning_brief        TEXT,
  session_notes        TEXT,
  eod_summary          TEXT,
  available_providers  TEXT    DEFAULT '["anthropic","openai","google","workers_ai"]',
  blocked_providers    TEXT    DEFAULT '[]',
  budget_snapshot      TEXT    DEFAULT '{}',
  default_model        TEXT,
  token_budget         INTEGER DEFAULT NULL,
  tokens_used          INTEGER NOT NULL DEFAULT 0,
  cost_usd             REAL    NOT NULL DEFAULT 0,
  carry_over_from      TEXT,
  carry_over_count     INTEGER DEFAULT 0,
  tasks_total          INTEGER DEFAULT 0,
  tasks_done           INTEGER DEFAULT 0,
  tasks_blocked        INTEGER DEFAULT 0,
  linked_project_keys  TEXT    DEFAULT '[]',
  linked_todo_ids      TEXT    DEFAULT '[]',
  linked_context_ids   TEXT    DEFAULT '[]',
  created_at           INTEGER DEFAULT (unixepoch()),
  updated_at           INTEGER DEFAULT (unixepoch())
, workflow_id TEXT REFERENCES agentsam_mcp_workflows(id) ON DELETE SET NULL, workflow_run_id TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL, graph_mode INTEGER DEFAULT 0, risk_level TEXT DEFAULT 'low', requires_approval INTEGER DEFAULT 0);

-- ------------------------------------------------------------------------
-- agentsam_project_context
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_project_context" (
  id TEXT PRIMARY KEY DEFAULT ('ctx_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL,
  workspace_id TEXT,
  project_key TEXT NOT NULL,
  project_name TEXT NOT NULL,
  project_type TEXT,
  status TEXT DEFAULT 'active',
  priority INTEGER DEFAULT 50,
  description TEXT NOT NULL,
  goals TEXT,
  constraints TEXT,
  current_blockers TEXT,
  primary_tables TEXT,
  secondary_tables TEXT,
  workers_involved TEXT,
  r2_buckets_involved TEXT,
  domains_involved TEXT,
  mcp_services_involved TEXT,
  key_files TEXT,
  related_routes TEXT,
  tokens_budgeted INTEGER,
  tokens_used INTEGER DEFAULT 0,
  cost_usd REAL NOT NULL DEFAULT 0,
  linked_plan_id TEXT REFERENCES agentsam_plans(id) ON DELETE SET NULL,
  linked_todo_ids TEXT DEFAULT '[]',
  agent_id TEXT,
  client_id TEXT,
  session_id TEXT,
  created_by TEXT,
  notes TEXT,
  started_at INTEGER,
  target_completion INTEGER,
  completed_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_prompt_cache_keys
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_prompt_cache_keys" (
  id TEXT PRIMARY KEY DEFAULT ('pck_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  model_key TEXT NOT NULL,
  cache_key_hash TEXT NOT NULL,
  cache_type TEXT DEFAULT 'ephemeral',
  token_count INTEGER DEFAULT 0,
  write_cost_usd REAL DEFAULT 0,
  read_count INTEGER DEFAULT 0,
  total_read_savings_usd REAL DEFAULT 0,
  first_written_at TEXT NOT NULL DEFAULT (datetime('now')),
  last_read_at TEXT,
  expires_at TEXT,
  source_type TEXT,
  source_id TEXT,
  workspace_id TEXT,
  agent_id TEXT,
  session_id TEXT,
  user_id TEXT,
  prompt_version_id TEXT,
  layer_keys_json TEXT DEFAULT '[]',
  is_shared INTEGER DEFAULT 0,
  fragment_hash TEXT DEFAULT NULL,
  route_key TEXT
);

-- ------------------------------------------------------------------------
-- agentsam_prompt_routes
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_prompt_routes (
  id                    TEXT PRIMARY KEY DEFAULT ('route_' || lower(hex(randomblob(6)))),
  route_key             TEXT UNIQUE NOT NULL,
  display_name          TEXT NOT NULL,

  
  intent_labels         TEXT DEFAULT '[]',      
  command_categories    TEXT DEFAULT '[]',      
  trigger_keywords      TEXT DEFAULT '[]',      

  
  prompt_layer_keys     TEXT NOT NULL DEFAULT '["core_identity"]',

  
  tool_categories       TEXT DEFAULT '[]',      
  tool_keys             TEXT DEFAULT '[]',      
  max_tools             INTEGER DEFAULT 8,

  
  preferred_model       TEXT DEFAULT NULL,      
  fallback_model        TEXT DEFAULT NULL,

  
  include_rag           INTEGER DEFAULT 0,      
  include_active_plan   INTEGER DEFAULT 1,      
  include_recent_memory INTEGER DEFAULT 1,      
  memory_limit          INTEGER DEFAULT 5,
  include_workspace_ctx INTEGER DEFAULT 1,      

  
  token_budget          INTEGER DEFAULT 2000,

  
  is_active             INTEGER DEFAULT 1,
  priority              INTEGER DEFAULT 50,     
  tenant_id             TEXT DEFAULT NULL,      
  created_at            INTEGER DEFAULT (unixepoch()),
  updated_at            INTEGER DEFAULT (unixepoch())
);

-- ------------------------------------------------------------------------
-- agentsam_prompt_versions
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_prompt_versions (
  id TEXT PRIMARY KEY DEFAULT ('pv_' || lower(hex(randomblob(8)))),
  prompt_key TEXT NOT NULL,
  version INTEGER NOT NULL,
  prompt_hash TEXT NOT NULL,
  body TEXT NOT NULL,
  body_tokens INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 0,
  superseded_by TEXT REFERENCES agentsam_prompt_versions(id),
  notes TEXT,
  created_at INTEGER NOT NULL DEFAULT (unixepoch()), tenant_id TEXT, workspace_id TEXT, agent_id TEXT, prompt_kind TEXT, status TEXT, user_id TEXT, is_cacheable INTEGER DEFAULT 1, cache_priority INTEGER DEFAULT 50, min_tokens_for_cache INTEGER DEFAULT 100,
  UNIQUE(prompt_key, version),
  UNIQUE(prompt_hash)
);

-- ------------------------------------------------------------------------
-- agentsam_route_requirements
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_route_requirements (
  id                    TEXT PRIMARY KEY DEFAULT ('req_' || lower(hex(randomblob(6)))),
  route_key             TEXT NOT NULL REFERENCES agentsam_prompt_routes(route_key) ON DELETE CASCADE ON UPDATE CASCADE,
  task_type             TEXT DEFAULT NULL,       -- classifyIntent label (optional override)

  -- Capability constraints — NULL = no constraint
  min_context_window    INTEGER DEFAULT NULL,
  min_output_tokens     INTEGER DEFAULT NULL,
  requires_tools        INTEGER DEFAULT 0,
  requires_vision       INTEGER DEFAULT 0,
  requires_json_mode    INTEGER DEFAULT 0,
  requires_reasoning    INTEGER DEFAULT 0,
  requires_streaming    INTEGER DEFAULT 1,

  -- Cost constraints (per 1k tokens USD) — NULL = no cap
  max_cost_per_1k_in    REAL DEFAULT NULL,
  max_cost_per_1k_out   REAL DEFAULT NULL,
  max_cost_per_call     REAL DEFAULT NULL,       -- absolute ceiling per invocation

  -- Performance constraints
  max_latency_p50_ms    INTEGER DEFAULT NULL,
  min_quality_score     REAL DEFAULT NULL,

  -- Tier constraints
  preferred_tier        TEXT DEFAULT NULL CHECK(preferred_tier IN ('micro','flash','standard','power','reasoning',NULL)),
  max_tier              TEXT DEFAULT NULL CHECK(max_tier IN ('micro','flash','standard','power','reasoning',NULL)),

  -- Selection strategy when multiple candidates qualify
  budget_priority       TEXT NOT NULL DEFAULT 'balanced'
                        CHECK(budget_priority IN ('cost','quality','speed','balanced')),

  -- Preferred providers (JSON array, [] = any)
  preferred_providers   TEXT DEFAULT '[]',
  blocked_providers     TEXT DEFAULT '[]',

  is_active             INTEGER DEFAULT 1,
  UNIQUE(route_key)
);

-- ------------------------------------------------------------------------
-- agentsam_routing_arms
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_routing_arms" (
  id                    TEXT PRIMARY KEY DEFAULT ('ra_' || lower(hex(randomblob(8)))),
  task_type             TEXT NOT NULL,
  mode                  TEXT NOT NULL,
  model_key             TEXT NOT NULL,
  provider              TEXT NOT NULL,
  success_alpha         REAL NOT NULL DEFAULT 1.0,
  success_beta          REAL NOT NULL DEFAULT 1.0,
  cost_n                INTEGER NOT NULL DEFAULT 0,
  cost_mean             REAL NOT NULL DEFAULT 0,
  cost_m2               REAL NOT NULL DEFAULT 0,
  latency_n             INTEGER NOT NULL DEFAULT 0,
  latency_mean          REAL NOT NULL DEFAULT 0,
  latency_m2            REAL NOT NULL DEFAULT 0,
  decayed_score         REAL NOT NULL DEFAULT 0,
  last_decay_at         INTEGER NOT NULL DEFAULT (unixepoch()),
  is_eligible           INTEGER NOT NULL DEFAULT 1,
  is_paused             INTEGER NOT NULL DEFAULT 0,
  pause_reason          TEXT,
  updated_at            INTEGER NOT NULL DEFAULT (unixepoch()),
  ai_model_id           TEXT,
  last_chain_id         TEXT,
  last_plan_id          TEXT,
  avg_quality_score     REAL DEFAULT 0,
  quality_n             INTEGER DEFAULT 0,
  max_cost_per_call_usd REAL,
  budget_exhausted      INTEGER DEFAULT 0,
  drift_signal_id       TEXT,
  intent_slug           TEXT,
  total_executions      INTEGER DEFAULT 0,
  workflow_agent        TEXT,
  tools_json            TEXT DEFAULT '[]',
  is_active             INTEGER DEFAULT 1,
  reasoning_effort      TEXT DEFAULT 'medium',
  workspace_id          TEXT NOT NULL,
  fallback_model_key    TEXT,
  supports_tools        INTEGER DEFAULT 1,
  priority              INTEGER DEFAULT 50,
  model_catalog_id      TEXT REFERENCES agentsam_model_catalog(id) ON DELETE SET NULL,
  UNIQUE(workspace_id, task_type, mode, model_key)
);

-- ------------------------------------------------------------------------
-- agentsam_rules_document
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_rules_document (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  workspace_id TEXT,
  title TEXT NOT NULL DEFAULT 'default',
  body_markdown TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
, person_uuid TEXT);

-- ------------------------------------------------------------------------
-- agentsam_script_runs
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_script_runs (
  id              TEXT PRIMARY KEY DEFAULT ('sr_' || lower(hex(randomblob(8)))),
  script_id       TEXT NOT NULL REFERENCES agentsam_scripts(id),
  workspace_id    TEXT NOT NULL DEFAULT 'ws_inneranimalmedia',
  triggered_by    TEXT NOT NULL DEFAULT 'agent',
  trigger_source  TEXT NOT NULL DEFAULT 'agent_sam'
    CHECK(trigger_source IN ('agent_sam','cursor','manual','github_push','scheduled','cicd')),
  cicd_run_id     TEXT,
  git_commit_sha  TEXT,
  git_branch      TEXT DEFAULT 'main',
  environment     TEXT NOT NULL DEFAULT 'production'
    CHECK(environment IN ('production','sandbox','staging','dev')),
  status          TEXT NOT NULL DEFAULT 'running'
    CHECK(status IN ('running','passed','failed','skipped','cancelled')),
  exit_code       INTEGER,
  duration_ms     INTEGER,
  output_summary  TEXT,
  error_message   TEXT,
  cost_usd        REAL DEFAULT 0,
  started_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  completed_at    TEXT,
  created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ------------------------------------------------------------------------
-- agentsam_scripts
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_scripts (
  id              TEXT PRIMARY KEY,
  workspace_id    TEXT NOT NULL DEFAULT 'ws_inneranimalmedia',
  name            TEXT NOT NULL,
  path            TEXT NOT NULL,
  description     TEXT NOT NULL,
  purpose         TEXT NOT NULL CHECK(purpose IN ('deploy','build','test','ingest','benchmark','maintenance','dev','dangerous','audit')),
  runner          TEXT NOT NULL DEFAULT 'npm' CHECK(runner IN ('npm','bash','node','python','sql','wrangler')),
  requires_env    INTEGER NOT NULL DEFAULT 1,
  owner_only      INTEGER NOT NULL DEFAULT 1,
  safe_to_run     INTEGER NOT NULL DEFAULT 1,
  run_before      TEXT,
  run_after       TEXT,
  never_run_with  TEXT,
  preferred_for   TEXT,
  notes           TEXT,
  is_active       INTEGER NOT NULL DEFAULT 1,
  created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
, slug TEXT DEFAULT NULL, is_global INTEGER DEFAULT 1, body TEXT DEFAULT NULL, tenant_id TEXT DEFAULT NULL);

-- ------------------------------------------------------------------------
-- agentsam_skill
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_skill" (
  id                    TEXT PRIMARY KEY,
  tenant_id             TEXT NOT NULL,                        -- no default, must be passed
  user_id               TEXT NOT NULL,
  person_uuid           TEXT,
  workspace_id          TEXT,                                  -- NULL = all workspaces in tenant
  name                  TEXT NOT NULL,
  description           TEXT NOT NULL DEFAULT '',
  content_markdown      TEXT NOT NULL DEFAULT '',
  file_path             TEXT NOT NULL DEFAULT '',

  scope                 TEXT NOT NULL DEFAULT 'workspace'
                        CHECK(scope IN ('user','workspace','tenant','global')),

  slash_trigger         TEXT,
  globs                 TEXT DEFAULT '[]',                    -- JSON array of glob patterns
  always_apply          INTEGER NOT NULL DEFAULT 0,
  task_types_json       TEXT NOT NULL DEFAULT '[]',           -- ['code','sql','plan','debug'] etc
  route_keys_json       TEXT NOT NULL DEFAULT '[]',           -- FK-free ref to agentsam_prompt_routes

  default_model_key     TEXT,                                  -- merged ai_model_id + default_model_id
  model_constraints_json TEXT NOT NULL DEFAULT '{}',          -- {requires_tools, min_context_window…}

  access_mode           TEXT NOT NULL DEFAULT 'read_write'
                        CHECK(access_mode IN ('read_only','read_write')),

  icon                  TEXT NOT NULL DEFAULT '',
  tags_json             TEXT NOT NULL DEFAULT '[]',           -- normalized from tags + metadata_json.tags
  metadata_json         TEXT NOT NULL DEFAULT '{}',

  token_estimate        INTEGER NOT NULL DEFAULT 0,           -- approx tokens this skill injects
  invocation_count      INTEGER NOT NULL DEFAULT 0,
  last_invoked_at       TEXT,

  version               INTEGER NOT NULL DEFAULT 1,
  is_active             INTEGER NOT NULL DEFAULT 1,
  sort_order            INTEGER NOT NULL DEFAULT 0,

  created_at            TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_skill_invocation
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_skill_invocation" (
  id              TEXT PRIMARY KEY DEFAULT ('skillinv_' || lower(hex(randomblob(8)))),
  skill_id        TEXT NOT NULL REFERENCES agentsam_skill(id) ON DELETE CASCADE,
  tenant_id       TEXT NOT NULL,                              -- no default
  user_id         TEXT NOT NULL,                              -- no default
  person_uuid     TEXT,
  workspace_id    TEXT NOT NULL DEFAULT '',
  conversation_id TEXT,
  trigger_method  TEXT NOT NULL DEFAULT 'slash'
                  CHECK(trigger_method IN ('slash','at','auto','api','always_apply')),
  input_summary   TEXT,
  success         INTEGER NOT NULL DEFAULT 1,
  error_message   TEXT,
  duration_ms     INTEGER,
  model_used      TEXT,
  tokens_in       INTEGER DEFAULT 0,
  tokens_out      INTEGER DEFAULT 0,
  cost_usd        REAL DEFAULT 0.0,
  agent_id        TEXT,
  tool_chain_id   TEXT,
  ai_model_id     TEXT,
  plan_task_id    TEXT,
  invoked_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_skill_revision
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_skill_revision (
  id           TEXT PRIMARY KEY DEFAULT ('skillrev_' || lower(hex(randomblob(8)))),
  skill_id     TEXT NOT NULL,
  content_markdown TEXT NOT NULL,
  version      INTEGER NOT NULL,
  changed_by   TEXT NOT NULL DEFAULT 'sam_primeaux',
  change_note  TEXT,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (skill_id) REFERENCES agentsam_skill(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------------------
-- agentsam_slash_commands
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_slash_commands (
  id           TEXT PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description  TEXT NOT NULL,
  usage_hint   TEXT,
  handler_type TEXT NOT NULL CHECK(handler_type IN ('builtin','db_query','subagent_spawn','tool_invoke','ollama_local')),
  handler_ref  TEXT,
  handler_sql  TEXT,
  args_schema  TEXT,
  modes_json   TEXT DEFAULT '["ask","agent","auto","debug","plan"]',
  risk_level   TEXT DEFAULT 'none' CHECK(risk_level IN ('none','low','high')),
  requires_confirmation INTEGER DEFAULT 0,
  is_active    INTEGER DEFAULT 1,
  sort_order   INTEGER DEFAULT 50,
  call_count   INTEGER DEFAULT 0,
  last_called_at TEXT,
  created_at   TEXT DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- agentsam_subagent_profile
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_subagent_profile (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '',
  slug TEXT NOT NULL,
  display_name TEXT NOT NULL,
  instructions_markdown TEXT,
  allowed_tool_globs TEXT,
  default_model_id TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), personality_tone TEXT DEFAULT 'professional', personality_traits TEXT, personality_rules TEXT, description TEXT NOT NULL DEFAULT '', icon TEXT NOT NULL DEFAULT '', access_mode TEXT NOT NULL DEFAULT 'read_write' CHECK(access_mode IN ('read_only','read_write')), run_in_background INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL DEFAULT 0, agent_type TEXT DEFAULT 'custom', sandbox_mode TEXT DEFAULT 'workspace-write', model_reasoning_effort TEXT DEFAULT 'medium', nickname_candidates TEXT, can_spawn_subagents INTEGER DEFAULT 0, spawnable_agent_slugs TEXT, spawn_trigger_keywords TEXT, max_concurrent_threads INTEGER DEFAULT 6, max_spawn_depth INTEGER DEFAULT 1, job_timeout_seconds INTEGER DEFAULT 1800, mcp_servers_json TEXT, output_schema_json TEXT, is_parallelizable INTEGER DEFAULT 0, codex_compatible INTEGER DEFAULT 0, person_uuid TEXT, tenant_id TEXT, ai_model_id TEXT, is_platform_global INTEGER NOT NULL DEFAULT 0,
  UNIQUE (user_id, workspace_id, slug)
);

-- ------------------------------------------------------------------------
-- agentsam_subscription_registry
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_subscription_registry (
  id               TEXT PRIMARY KEY,
  tenant_id        TEXT NOT NULL,
  name             TEXT NOT NULL,
  provider         TEXT NOT NULL,
  model_name       TEXT,
  subscription_tier TEXT,
  linked_email     TEXT,
  notes            TEXT,
  status           TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','inactive','expired')),
  created_at       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at       TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ------------------------------------------------------------------------
-- agentsam_task_slos
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_task_slos (
  task_type TEXT PRIMARY KEY,
  sla_p95_latency_ms INTEGER NOT NULL,
  sla_avg_cost_usd REAL NOT NULL,
  sla_min_quality REAL NOT NULL,
  sla_min_schema_valid_rate REAL,
  sla_min_tool_success_rate REAL,
  alert_threshold_pct REAL NOT NULL DEFAULT 0.10,
  notes TEXT,
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
, pause_arm_on_breach INTEGER DEFAULT 0);

-- ------------------------------------------------------------------------
-- agentsam_todo
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_todo" (
  id                TEXT    PRIMARY KEY,
  tenant_id         TEXT    NOT NULL,
  workspace_id      TEXT,
  title             TEXT    NOT NULL,
  description       TEXT,
  status            TEXT    NOT NULL DEFAULT 'open',
  priority          TEXT    NOT NULL DEFAULT 'medium',
  category          TEXT,
  tags              TEXT    DEFAULT '[]',
  due_date          TEXT,
  completed_at      TEXT,
  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  created_by        TEXT    NOT NULL DEFAULT 'agentsam',
  notes             TEXT,
  linked_commit     TEXT,
  linked_route      TEXT,
  linked_table      TEXT,
  sort_order        INTEGER DEFAULT 50,
  plan_id           TEXT,
  project_key       TEXT,
  task_type         TEXT    NOT NULL DEFAULT 'execute',
  execution_status  TEXT    NOT NULL DEFAULT 'queued',
  assigned_to       TEXT    DEFAULT 'agentsam',
  depends_on        TEXT    DEFAULT '[]',
  retry_count       INTEGER NOT NULL DEFAULT 0,
  max_retries       INTEGER NOT NULL DEFAULT 2,
  timeout_seconds   INTEGER DEFAULT 300,
  context_snapshot  TEXT    DEFAULT '{}',
  output_summary    TEXT,
  error_trace       TEXT,
  token_budget      INTEGER DEFAULT NULL,
  tokens_used       INTEGER NOT NULL DEFAULT 0,
  cost_usd          REAL    NOT NULL DEFAULT 0,
  requires_approval INTEGER NOT NULL DEFAULT 0,
  approved_by       TEXT,
  approved_at       TEXT,
  started_at        TEXT
, kanban_task_id TEXT REFERENCES kanban_tasks(id) ON DELETE SET NULL, kanban_board_id TEXT REFERENCES kanban_boards(id) ON DELETE SET NULL);

-- ------------------------------------------------------------------------
-- agentsam_tool_cache
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_tool_cache (
  id TEXT PRIMARY KEY DEFAULT ('tc_' || lower(hex(randomblob(8)))),
  workspace_id TEXT NOT NULL,
  tenant_id TEXT,
  tool_key TEXT NOT NULL,
  tool_category TEXT,
  cache_key TEXT NOT NULL UNIQUE,
  input_hash TEXT NOT NULL,
  input_json TEXT,
  output_json TEXT NOT NULL,
  output_summary TEXT,
  token_savings_estimate INTEGER DEFAULT 0,
  execution_ms INTEGER DEFAULT 0,
  model_used TEXT,
  provider TEXT,
  cache_strategy TEXT DEFAULT 'ttl' CHECK(cache_strategy IN ('ttl','immutable','session','versioned','manual')),
  invalidation_reason TEXT,
  expires_at TEXT,
  last_used_at TEXT,
  hit_count INTEGER DEFAULT 0,
  source_type TEXT,
  source_identifier TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);

-- ------------------------------------------------------------------------
-- agentsam_tool_call_log
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_tool_call_log (
  id TEXT PRIMARY KEY DEFAULT ('atcl_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL,
  session_id TEXT,
  tool_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('success','error','timeout','blocked','completed','failed','pending','running','skipped','cancelled')),
  duration_ms INTEGER,
  error_message TEXT,
  cost_usd REAL DEFAULT 0,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL DEFAULT (unixepoch())
, agent_id TEXT, user_id TEXT, workflow_id TEXT, tool_category TEXT DEFAULT 'mcp', input_summary TEXT, output_summary TEXT, retry_count INTEGER DEFAULT 0, workspace_id TEXT, timed_out INTEGER DEFAULT 0, sla_breach INTEGER DEFAULT 0, timeout_ms INTEGER DEFAULT 30000, span_id TEXT DEFAULT NULL, trace_id TEXT DEFAULT NULL, batch_id TEXT DEFAULT NULL, output_json TEXT DEFAULT '{}', input_json TEXT DEFAULT '{}');

-- ------------------------------------------------------------------------
-- agentsam_tool_chain
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_tool_chain" (
  id                   TEXT    PRIMARY KEY DEFAULT ('atc_' || lower(hex(randomblob(8)))),
  tenant_id            TEXT,
  workspace_id         TEXT,
  user_id              TEXT,
  agent_id             TEXT,
  work_session_id      TEXT,
  plan_id              TEXT    REFERENCES "agentsam_plans_old"(id)        ON DELETE SET NULL,
  todo_id              TEXT    REFERENCES agentsam_todo(id)          ON DELETE SET NULL,
  command_run_id       TEXT    REFERENCES agentsam_command_run(id)  ON DELETE SET NULL,
  subagent_profile_id  TEXT,
  agent_session_id     TEXT,
  agent_message_id     TEXT,
  parent_chain_id      TEXT    REFERENCES agentsam_tool_chain(id),
  depth                INTEGER NOT NULL DEFAULT 0,
  tool_name            TEXT    NOT NULL,
  tool_id              TEXT    REFERENCES agentsam_tools(id),
  mcp_tool_ref         TEXT,
  mcp_tool_call_id     TEXT,
  terminal_session_id  TEXT,
  command_execution_id TEXT,
  tool_status          TEXT    NOT NULL DEFAULT 'pending'
                               CHECK(tool_status IN ('pending','running','completed',
                                                      'failed','skipped','cancelled','timeout')),
  input_json           TEXT    DEFAULT '{}',
  output_summary       TEXT,
  result_json          TEXT,
  error_message        TEXT,
  error_type           TEXT,
  retry_count          INTEGER NOT NULL DEFAULT 0,
  max_retries          INTEGER NOT NULL DEFAULT 2,
  duration_ms          INTEGER,
  input_tokens         INTEGER NOT NULL DEFAULT 0,
  output_tokens        INTEGER NOT NULL DEFAULT 0,
  cost_usd             REAL    NOT NULL DEFAULT 0,
  timed_out            INTEGER DEFAULT 0,
  sla_breach           INTEGER DEFAULT 0,
  timeout_ms           INTEGER DEFAULT 30000,
  requires_approval    INTEGER NOT NULL DEFAULT 0,
  approved_by          TEXT,
  approved_at          INTEGER,
  started_at           INTEGER NOT NULL DEFAULT (unixepoch()),
  completed_at         INTEGER
, execution_step_id TEXT REFERENCES agentsam_execution_steps(id) ON DELETE SET NULL, workflow_run_id TEXT 
  REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL);

-- ------------------------------------------------------------------------
-- agentsam_tool_stats_compacted
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_tool_stats_compacted" (
  id              TEXT PRIMARY KEY DEFAULT ('atsc_' || lower(hex(randomblob(8)))),
  tenant_id       TEXT NOT NULL,
  workspace_id    TEXT NOT NULL,
  tool_name       TEXT NOT NULL,
  total_calls     INTEGER DEFAULT 0,
  success_count   INTEGER DEFAULT 0,
  failure_count   INTEGER DEFAULT 0,
  success_rate    REAL DEFAULT 0,
  total_cost_usd  REAL DEFAULT 0,
  total_tokens    INTEGER DEFAULT 0,
  avg_duration_ms REAL DEFAULT 0,
  first_seen_at   INTEGER,
  last_seen_at    INTEGER,
  compacted_at    INTEGER NOT NULL DEFAULT (unixepoch()),
  agent_id        TEXT,
  timed_out_count INTEGER DEFAULT 0,
  sla_breach_count INTEGER DEFAULT 0,
  p95_duration_ms REAL DEFAULT 0,
  UNIQUE(tenant_id, workspace_id, tool_name)
);

-- ------------------------------------------------------------------------
-- agentsam_tools
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_tools (
  id TEXT PRIMARY KEY DEFAULT ('ast_' || lower(hex(randomblob(8)))),
  tool_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  tool_category TEXT NOT NULL,
  handler_type TEXT NOT NULL DEFAULT 'builtin'
    CHECK (handler_type IN ('builtin','mcp','r2','github','terminal','http','proxy','ai','d1')),
  description TEXT,
  input_schema TEXT,
  output_schema TEXT,
  linked_mcp_tool_id TEXT,
  mcp_service_url TEXT,
  handler_config TEXT DEFAULT '{}',
  intent_tags TEXT DEFAULT '[]',
  intent_category_tags TEXT,
  modes_json TEXT DEFAULT '["auto","build","chat"]',
  risk_level TEXT NOT NULL DEFAULT 'low'
    CHECK (risk_level IN ('low','medium','high','critical')),
  requires_approval INTEGER NOT NULL DEFAULT 0,
  requires_confirmation INTEGER NOT NULL DEFAULT 0,
  token_budget_per_call INTEGER DEFAULT NULL,
  max_calls_per_session INTEGER DEFAULT NULL,
  cost_per_call_usd REAL DEFAULT 0.0,
  is_active INTEGER NOT NULL DEFAULT 1,
  is_degraded INTEGER NOT NULL DEFAULT 0,
  failure_rate REAL DEFAULT 0.0,
  avg_latency_ms REAL DEFAULT NULL,
  use_count INTEGER NOT NULL DEFAULT 0,
  last_used_at INTEGER DEFAULT NULL,
  last_health_check INTEGER DEFAULT NULL,
  sort_priority INTEGER DEFAULT 50,
  workspace_scope TEXT DEFAULT '["ws_inneranimalmedia"]',
  subagent_profile_id TEXT DEFAULT NULL,
  schema_hint TEXT DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  created_at INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at INTEGER NOT NULL DEFAULT (unixepoch())
, is_global INTEGER DEFAULT 1);

-- ------------------------------------------------------------------------
-- agentsam_usage_events
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_usage_events (
  id          TEXT PRIMARY KEY DEFAULT ('ue_' || lower(hex(randomblob(8)))),
  tenant_id   TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT 'ws_inneranimalmedia',
  user_id     TEXT,
  session_id  TEXT,
  agent_name  TEXT NOT NULL DEFAULT 'agent-sam',
  provider    TEXT NOT NULL,             -- anthropic, openai, google, cloudflare_workers_ai
  model       TEXT NOT NULL,             -- resolved model key, never hardcoded
  tokens_in   INTEGER NOT NULL DEFAULT 0,
  tokens_out  INTEGER NOT NULL DEFAULT 0,
  cost_usd    REAL NOT NULL DEFAULT 0,   -- REAL not INTEGER — preserves sub-cent precision
  status      TEXT NOT NULL DEFAULT 'ok'
    CHECK(status IN ('ok','blocked','error','timeout')),
  tool_name   TEXT,                      -- if this event was triggered by a tool call
  reason      TEXT,                      -- block reason / error message
  ref_table   TEXT,                      -- source table: ai_usage_log, agentsam_tool_call_log
  ref_id      TEXT,                      -- FK to source row for dedup
  created_at  INTEGER NOT NULL DEFAULT (unixepoch()), ai_model_id TEXT, routing_arm_id TEXT, event_type TEXT, model_key TEXT, duration_ms INTEGER, total_tokens INTEGER,
  UNIQUE(ref_table, ref_id)              -- prevents duplicate ingestion
);

-- ------------------------------------------------------------------------
-- agentsam_usage_rollups_daily
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_usage_rollups_daily (
  tenant_id               TEXT NOT NULL,
  workspace_id            TEXT NOT NULL,
  day                     TEXT NOT NULL,
  ai_calls                INTEGER NOT NULL DEFAULT 0,
  tokens_in               INTEGER NOT NULL DEFAULT 0,
  tokens_out              INTEGER NOT NULL DEFAULT 0,
  cost_usd                REAL NOT NULL DEFAULT 0,
  tool_calls              INTEGER NOT NULL DEFAULT 0,
  tool_successes          INTEGER NOT NULL DEFAULT 0,
  tool_failures           INTEGER NOT NULL DEFAULT 0,
  mcp_calls               INTEGER NOT NULL DEFAULT 0,
  deployments             INTEGER NOT NULL DEFAULT 0,
  webhook_events          INTEGER NOT NULL DEFAULT 0,
  blocked_count           INTEGER NOT NULL DEFAULT 0,
  error_count             INTEGER NOT NULL DEFAULT 0,
  provider_breakdown_json TEXT DEFAULT '{}',
  top_tools_json          TEXT DEFAULT '[]',
  rollup_source           TEXT NOT NULL DEFAULT 'daily_cron',
  rolled_up_at            INTEGER NOT NULL DEFAULT (unixepoch()),
  PRIMARY KEY (tenant_id, workspace_id, day)
);

-- ------------------------------------------------------------------------
-- agentsam_user_feature_override
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_user_feature_override (
  user_id TEXT NOT NULL,
  flag_key TEXT NOT NULL,
  enabled INTEGER NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT,
  PRIMARY KEY (user_id, flag_key),
  FOREIGN KEY (flag_key) REFERENCES agentsam_feature_flag(flag_key)
);

-- ------------------------------------------------------------------------
-- agentsam_user_policy
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_user_policy (
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '',
  auto_run_mode TEXT NOT NULL DEFAULT 'allowlist',
  browser_protection INTEGER NOT NULL DEFAULT 0,
  mcp_tools_protection INTEGER NOT NULL DEFAULT 1,
  file_deletion_protection INTEGER NOT NULL DEFAULT 1,
  external_file_protection INTEGER NOT NULL DEFAULT 1,
  default_agent_location TEXT DEFAULT 'pane',
  text_size TEXT DEFAULT 'default',
  auto_clear_chat INTEGER NOT NULL DEFAULT 0,
  submit_with_mod_enter INTEGER NOT NULL DEFAULT 0,
  max_tab_count INTEGER NOT NULL DEFAULT 5,
  queue_messages_mode TEXT DEFAULT 'after_current',
  usage_summary_mode TEXT DEFAULT 'auto',
  agent_autocomplete INTEGER NOT NULL DEFAULT 1,
  web_search_enabled INTEGER NOT NULL DEFAULT 1,
  auto_accept_web_search INTEGER NOT NULL DEFAULT 0,
  web_fetch_enabled INTEGER NOT NULL DEFAULT 1,
  hierarchical_ignore INTEGER NOT NULL DEFAULT 0,
  ignore_symlinks INTEGER NOT NULL DEFAULT 0,
  inline_diffs INTEGER NOT NULL DEFAULT 1,
  jump_next_diff_on_accept INTEGER NOT NULL DEFAULT 1,
  auto_format_on_agent_finish INTEGER NOT NULL DEFAULT 0,
  legacy_terminal_tool INTEGER NOT NULL DEFAULT 1,
  toolbar_on_selection INTEGER NOT NULL DEFAULT 1,
  auto_parse_links INTEGER NOT NULL DEFAULT 0,
  themed_diff_backgrounds INTEGER NOT NULL DEFAULT 1,
  terminal_hint INTEGER NOT NULL DEFAULT 1,
  terminal_preview_box INTEGER NOT NULL DEFAULT 1,
  collapse_auto_run_commands INTEGER NOT NULL DEFAULT 1,
  voice_submit_keyword TEXT DEFAULT 'submit',
  commit_attribution INTEGER NOT NULL DEFAULT 1,
  pr_attribution INTEGER NOT NULL DEFAULT 1,
  settings_json TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), person_uuid TEXT, tenant_id TEXT DEFAULT '', superadmin_uuid TEXT, max_cost_per_session_usd  REAL DEFAULT NULL, max_cost_per_call_usd     REAL DEFAULT NULL, allowed_model_tier_max    INTEGER DEFAULT 4, tool_risk_level_max TEXT DEFAULT 'high'
  CHECK(tool_risk_level_max IN ('low','medium','high','critical')), require_allowlist_for_mcp INTEGER DEFAULT 1, allow_subagent_spawn  INTEGER DEFAULT 0, max_spawn_depth       INTEGER DEFAULT 1, max_tool_chain_depth  INTEGER DEFAULT 8, sync_layouts INTEGER NOT NULL DEFAULT 1, show_status_bar INTEGER NOT NULL DEFAULT 1, autohide_editor INTEGER NOT NULL DEFAULT 0, autoinject_code INTEGER NOT NULL DEFAULT 1, allow_platform_fallback INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, workspace_id)
);

-- ------------------------------------------------------------------------
-- agentsam_webhook_events
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_webhook_events (
  id TEXT PRIMARY KEY DEFAULT ('whe_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL DEFAULT 'tenant_sam_primeaux',
  provider TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_id TEXT,
  payload_json TEXT,
  status TEXT CHECK(status IN ('received','processing','processed','failed','ignored')) DEFAULT 'received',
  response_id TEXT,
  model_key TEXT,
  input_tokens INTEGER DEFAULT 0,
  output_tokens INTEGER DEFAULT 0,
  cost_usd REAL DEFAULT 0,
  error_message TEXT,
  processed_at TEXT,
  received_at TEXT NOT NULL DEFAULT (datetime('now'))
, endpoint_id TEXT, source TEXT, repo_full_name TEXT, branch TEXT, commit_sha TEXT, commit_message TEXT, actor TEXT, author_username TEXT, author_email TEXT, headers_json TEXT, signature_valid INTEGER DEFAULT 1, ip_address TEXT, processing_error TEXT, created_at TEXT GENERATED ALWAYS AS (received_at) VIRTUAL);

-- ------------------------------------------------------------------------
-- agentsam_webhook_weekly
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_webhook_weekly" (
  id TEXT PRIMARY KEY DEFAULT ('whw_' || lower(hex(randomblob(8)))),
  tenant_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL DEFAULT '__tenant__',
  week_start TEXT NOT NULL,
  week_end TEXT NOT NULL,
  provider TEXT NOT NULL,
  total_received INTEGER NOT NULL DEFAULT 0,
  total_processed INTEGER NOT NULL DEFAULT 0,
  total_failed INTEGER NOT NULL DEFAULT 0,
  total_cost_usd REAL DEFAULT 0,
  top_event_types TEXT DEFAULT '{}',
  top_repos TEXT DEFAULT '{}',
  notes TEXT,
  rolled_up_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(tenant_id, workspace_id, week_start, provider)
);

-- ------------------------------------------------------------------------
-- agentsam_workflow_edges
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_workflow_edges" (
  id TEXT PRIMARY KEY DEFAULT ('wedge_' || lower(hex(randomblob(8)))),
  workflow_id TEXT NOT NULL REFERENCES agentsam_workflows(id) ON DELETE CASCADE,
  from_node_key TEXT NOT NULL,
  to_node_key TEXT NOT NULL,
  condition_json TEXT DEFAULT NULL,
  condition_type TEXT DEFAULT 'always'
    CHECK(condition_type IN (
      'always','threshold','status','elapsed',
      'cost','field','risk','manual','timeout'
    )),
  priority INTEGER DEFAULT 0,
  is_fallback INTEGER DEFAULT 0,
  label TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  UNIQUE(workflow_id, from_node_key, to_node_key)
);

-- ------------------------------------------------------------------------
-- agentsam_workflow_nodes
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_workflow_nodes" (
  id TEXT PRIMARY KEY DEFAULT ('wnode_' || lower(hex(randomblob(8)))),
  workflow_id TEXT NOT NULL REFERENCES agentsam_workflows(id) ON DELETE CASCADE,
  node_key TEXT NOT NULL,
  node_type TEXT NOT NULL DEFAULT 'agent'
    CHECK(node_type IN (
      'agent','db_query','mcp_tool','script',
      'approval_gate','eval','branch','webhook','terminal',
      'retry','parallel','join'
    )),
  title TEXT NOT NULL,
  description TEXT,
  handler_key TEXT,
  input_schema_json TEXT DEFAULT '{}',
  output_schema_json TEXT DEFAULT '{}',
  timeout_ms INTEGER DEFAULT 30000,
  retry_policy_json TEXT DEFAULT '{"max_retries":2,"backoff":"exponential","delay_ms":1000}',
  quality_gate_json TEXT DEFAULT '{}',
  risk_level TEXT DEFAULT 'low'
    CHECK(risk_level IN ('low','medium','high','critical')),
  requires_approval INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  sort_order INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  UNIQUE(workflow_id, node_key)
);

-- ------------------------------------------------------------------------
-- agentsam_workflow_runs
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_workflow_runs" (
  id TEXT PRIMARY KEY DEFAULT ('wrun_' || lower(hex(randomblob(8)))),

  workflow_id TEXT NOT NULL REFERENCES agentsam_workflows(id) ON DELETE CASCADE,
  workflow_key TEXT,
  display_name TEXT,

  tenant_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL,
  project_id TEXT,

  user_id TEXT,
  d1_auth_user_id TEXT,
  user_email TEXT,
  session_id TEXT,
  run_group_id TEXT,

  trigger_type TEXT NOT NULL DEFAULT 'manual'
    CHECK(trigger_type IN ('manual','agent','cursor','github_push','scheduled','cicd','deploy','api')),

  status TEXT NOT NULL DEFAULT 'running'
    CHECK(status IN ('running','completed','failed','cancelled','timeout')),

  input_json TEXT NOT NULL DEFAULT '{}',
  output_json TEXT NOT NULL DEFAULT '{}',
  step_results_json TEXT NOT NULL DEFAULT '[]',

  steps_completed INTEGER NOT NULL DEFAULT 0,
  steps_total INTEGER NOT NULL DEFAULT 0,

  error_message TEXT,

  model_used TEXT,
  input_tokens INTEGER NOT NULL DEFAULT 0,
  output_tokens INTEGER NOT NULL DEFAULT 0,
  cost_usd REAL NOT NULL DEFAULT 0,
  duration_ms INTEGER,

  parent_run_id TEXT DEFAULT NULL,
  retry_of_run_id TEXT DEFAULT NULL,
  approval_id TEXT DEFAULT NULL,
  retry_count INTEGER NOT NULL DEFAULT 0,

  environment TEXT NOT NULL DEFAULT 'production'
    CHECK(environment IN ('production','sandbox','staging','dev')),

  git_commit_sha TEXT,
  git_branch TEXT DEFAULT 'main',

  supabase_run_id TEXT,
  supabase_sync_status TEXT NOT NULL DEFAULT 'pending'
    CHECK(supabase_sync_status IN ('pending','synced','failed','skipped')),
  supabase_synced_at TEXT,
  supabase_sync_error TEXT,
  supabase_sync_attempts INTEGER NOT NULL DEFAULT 0,

  metadata_json TEXT NOT NULL DEFAULT '{}',

  started_at INTEGER NOT NULL DEFAULT (unixepoch()),
  completed_at INTEGER,

  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),

  graph_mode INTEGER DEFAULT 0,
  current_node_key TEXT DEFAULT NULL,
  max_runtime_ms INTEGER DEFAULT 300000,
  max_cost_usd REAL DEFAULT 0.05,
  max_total_tokens INTEGER DEFAULT 20000,
  heartbeat_at INTEGER DEFAULT NULL,
  kill_reason TEXT DEFAULT NULL,

  CHECK(length(trim(tenant_id)) > 0),
  CHECK(length(trim(workspace_id)) > 0)
);

-- ------------------------------------------------------------------------
-- agentsam_workflows
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_workflows (
  id TEXT PRIMARY KEY DEFAULT ('wf_' || lower(hex(randomblob(8)))),
  tenant_id TEXT,
  workspace_id TEXT,
  workflow_key TEXT NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  workflow_type TEXT NOT NULL DEFAULT 'agentic',
  trigger_type TEXT NOT NULL DEFAULT 'manual',
  default_mode TEXT DEFAULT 'agent',
  default_task_type TEXT,
  risk_level TEXT DEFAULT 'low',
  requires_approval INTEGER DEFAULT 0,
  max_concurrent_nodes INTEGER DEFAULT 3,
  timeout_ms INTEGER DEFAULT 300000,
  quality_gate_json TEXT DEFAULT '{}',
  metadata_json TEXT DEFAULT '{}',
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), is_platform_global INTEGER NOT NULL DEFAULT 1,
  UNIQUE(workspace_id, workflow_key)
);

-- ------------------------------------------------------------------------
-- agentsam_workspace
-- ------------------------------------------------------------------------
CREATE TABLE "agentsam_workspace" (
  id                 TEXT PRIMARY KEY,
  workspace_slug     TEXT NOT NULL UNIQUE,
  tenant_id          TEXT NOT NULL,
  project_id         TEXT,
  project_slug       TEXT,
  name               TEXT NOT NULL,
  description        TEXT,
  root_path          TEXT,
  r2_bucket          TEXT,
  status             TEXT NOT NULL DEFAULT 'active'
                       CHECK(status IN ('active','archived','paused')),
  metadata_json      TEXT DEFAULT '{}',
  created_at         INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at         INTEGER NOT NULL DEFAULT (unixepoch()),
  r2_prefix          TEXT,
  github_repo        TEXT,
  default_model_id   TEXT,
  primary_subagent_id TEXT,
  display_name       TEXT
, workspace_ref_id TEXT REFERENCES workspaces(id));

-- ------------------------------------------------------------------------
-- agentsam_workspace_state
-- ------------------------------------------------------------------------
CREATE TABLE agentsam_workspace_state (
  id                TEXT PRIMARY KEY DEFAULT ('wss_' || lower(hex(randomblob(8)))),
  workspace_id      TEXT NOT NULL REFERENCES agentsam_workspace(id) ON DELETE CASCADE,
  conversation_id   TEXT,
  workspace_type    TEXT NOT NULL DEFAULT 'ide',
  active_file       TEXT,
  files_open        TEXT NOT NULL DEFAULT '[]',
  state_json        TEXT NOT NULL DEFAULT '{}',
  locked_by         TEXT,
  lock_expires_at   INTEGER,
  lock_reason       TEXT,
  agent_session_id  TEXT,
  current_task_id   TEXT,
  last_agent_action TEXT,
  created_at        INTEGER NOT NULL DEFAULT (unixepoch()),
  updated_at        INTEGER NOT NULL DEFAULT (unixepoch())
, agent_id TEXT, checkpoint_label TEXT, checkpoint_sha TEXT);
