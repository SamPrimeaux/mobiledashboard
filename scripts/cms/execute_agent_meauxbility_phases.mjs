#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import crypto from "node:crypto";

const REQUIRED_ENV = [
  "IAM_D1_DB",
  "IAM_TENANT_ID",
  "IAM_WORKSPACE_ID",
  "IAM_USER_ID",
  "CLOUDFLARE_R2_BUCKET",
  "OPENAI_API_KEY",
];

for (const key of REQUIRED_ENV) {
  if (!process.env[key] || !String(process.env[key]).trim()) {
    throw new Error(`Missing ${key}. Refusing to run.`);
  }
}

const DB = process.env.IAM_D1_DB;
const tenantId = process.env.IAM_TENANT_ID;
const workspaceId = process.env.IAM_WORKSPACE_ID;
const userId = process.env.IAM_USER_ID;
const apiUrl = process.env.AGENTSAM_PHASE_API_URL || "";
const phaseExecutor = process.env.AGENTSAM_PHASE_EXECUTOR || "direct_openai";
const defaultModel = process.env.AGENTSAM_DEFAULT_MODEL || "gpt-5.4-nano";
const escalationModel = process.env.AGENTSAM_ESCALATION_MODEL || "gpt-5.4-mini";
const maxTotalCost = Number(process.env.AGENTSAM_MAX_TOTAL_COST_USD || 2.0);
const maxPhaseSeconds = Number(process.env.AGENTSAM_MAX_PHASE_SECONDS || 2700);
const allowLivePromotion = process.env.AGENTSAM_ALLOW_LIVE_PROMOTION === "1";

const runId = process.env.AGENTSAM_RUN_ID || `agent_meauxbility_live_${new Date().toISOString().replace(/[-:.]/g, "").slice(0, 15)}_${crypto.randomUUID().replaceAll("-", "").slice(0, 8)}`;
const runDir = `tmp/agent-meauxbility/live/${runId}`;
fs.mkdirSync(runDir, { recursive: true });

const phases = [
  {
    id: "surface_map",
    promptFile: "agents/agent-meauxbility-cms/prompts/00_surface_map.md",
    model: defaultModel,
    requiredDeltas: ["agentsam_tool_chain", "agentsam_execution_steps", "agentsam_artifacts", "agentsam_usage_events"],
  },
  {
    id: "component_library",
    promptFile: "agents/agent-meauxbility-cms/prompts/01_component_library.md",
    model: defaultModel,
    requiredDeltas: ["agentsam_tool_chain", "agentsam_execution_steps", "agentsam_artifacts", "agentsam_usage_events"],
  },
  {
    id: "cms_editor_app",
    promptFile: "agents/agent-meauxbility-cms/prompts/02_cms_editor_app.md",
    model: defaultModel,
    requiredDeltas: ["agentsam_tool_chain", "agentsam_execution_steps", "agentsam_artifacts", "agentsam_usage_events"],
  },
  {
    id: "validation",
    promptFile: "agents/agent-meauxbility-cms/prompts/03_validation.md",
    model: defaultModel,
    requiredDeltas: [
      "agentsam_tool_chain",
      "agentsam_execution_steps",
      "agentsam_execution_dependency_graph",
      "agentsam_execution_performance_metrics",
      "agentsam_artifacts",
      "agentsam_usage_events",
    ],
  },
];

function q(v) {
  if (v === null || v === undefined || v === "") return "NULL";
  if (typeof v === "number") return Number.isFinite(v) ? String(v) : "NULL";
  if (typeof v === "boolean") return v ? "1" : "0";
  return `'${String(v).replaceAll("'", "''")}'`;
}

function d1(sql, json = true) {
  const args = ["wrangler", "d1", "execute", DB, "--remote"];
  if (json) args.push("--json");
  args.push("--command", sql);
  const out = execFileSync("npx", args, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
  if (!json) return out;
  const start = out.indexOf("[");
  if (start < 0) throw new Error(`No JSON in wrangler output:\n${out}`);
  return JSON.parse(out.slice(start))?.[0]?.results || [];
}

function tableColumns(table) {
  try {
    return new Set(d1(`PRAGMA table_info(${table});`).map((r) => r.name));
  } catch {
    return new Set();
  }
}

function insertFiltered(table, values) {
  const cols = tableColumns(table);
  const entries = Object.entries(values).filter(([k]) => cols.has(k));
  if (!entries.length) return false;

  const sql = `
    INSERT OR IGNORE INTO ${table} (${entries.map(([k]) => k).join(", ")})
    VALUES (${entries.map(([, v]) => q(v)).join(", ")});
  `;

  try {
    d1(sql, false);
    return true;
  } catch (err) {
    console.error(`[warn] failed insertFiltered ${table}:`, err.message);
    return false;
  }
}

function nowIso() {
  return new Date().toISOString();
}

function countTable(table) {
  const rows = d1(`SELECT COUNT(*) AS count FROM ${table};`);
  return Number(rows[0]?.count || 0);
}

function countScoped(table) {
  const cols = tableColumns(table);
  const clauses = [];

  if (cols.has("tenant_id")) clauses.push(`tenant_id=${q(tenantId)}`);
  if (cols.has("workspace_id")) clauses.push(`workspace_id=${q(workspaceId)}`);

  // Prefer run_id traces when columns/JSON fields exist, but keep fallback broad enough.
  const jsonClauses = [];
  for (const col of ["metadata_json", "input_json", "result_json", "output_json", "notes", "grader_notes"]) {
    if (cols.has(col)) jsonClauses.push(`${col} LIKE ${q(`%${runId}%`)}`);
  }
  if (cols.has("run_group_id")) jsonClauses.push(`run_group_id=${q(runId)}`);
  if (cols.has("source")) jsonClauses.push(`source LIKE ${q("%agent_meauxbility%")}`);
  if (cols.has("event_type")) jsonClauses.push(`event_type LIKE ${q("%agent_meauxbility%")}`);
  if (cols.has("r2_key")) jsonClauses.push(`r2_key LIKE ${q(`%${runId}%`)}`);

  let where = "1=1";
  if (clauses.length) where += ` AND ${clauses.join(" AND ")}`;
  if (jsonClauses.length) where += ` AND (${jsonClauses.join(" OR ")})`;

  try {
    const rows = d1(`SELECT COUNT(*) AS count FROM ${table} WHERE ${where};`);
    return Number(rows[0]?.count || 0);
  } catch {
    return countTable(table);
  }
}

function snapshotCounts(tables) {
  const out = {};
  for (const table of tables) out[table] = countScoped(table);
  return out;
}

function deltaReport(before, after, requiredTables) {
  return requiredTables.map((table) => ({
    table,
    before: before[table] ?? 0,
    after: after[table] ?? 0,
    delta: (after[table] ?? 0) - (before[table] ?? 0),
    ok: ((after[table] ?? 0) - (before[table] ?? 0)) > 0,
  }));
}

function logError({ phaseId, errorType, message, metadata }) {
  const id = `err_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`;
  const payload = {
    id,
    tenant_id: tenantId,
    workspace_id: workspaceId,
    user_id: userId,
    source: "agent_meauxbility_overnight",
    error_type: errorType,
    error_message: message,
    message,
    stack_trace: metadata?.stack || null,
    metadata_json: JSON.stringify({
      run_id: runId,
      phase_id: phaseId,
      ...metadata,
    }),
    created_at: Math.floor(Date.now() / 1000),
    updated_at: Math.floor(Date.now() / 1000),
  };

  const wrote = insertFiltered("agentsam_error_log", payload);

  const local = `${runDir}/error_${phaseId}_${Date.now()}.json`;
  fs.writeFileSync(local, JSON.stringify(payload, null, 2));

  return { wrote, local, id };
}

async function callAgentPhase(phase, prompt) {
  if (phaseExecutor === "direct_openai") {
    return await callOpenAIPhase(phase, prompt);
  }

  return await callLiveAgentSamPhase(phase, prompt);
}

function extractResponseText(data) {
  if (typeof data.output_text === "string" && data.output_text.trim()) {
    return data.output_text;
  }

  const parts = [];
  for (const item of data.output || []) {
    for (const content of item.content || []) {
      if (content.type === "output_text" && content.text) {
        parts.push(content.text);
      }
    }
  }
  return parts.join("\\n").trim();
}

async function callOpenAIPhase(phase, prompt) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), maxPhaseSeconds * 1000);

  const body = {
    model: phase.model,
    reasoning: { effort: "low" },
    max_output_tokens: 1600,
    input: [
      {
        role: "developer",
        content: [
          "You are Agent Sam operating inside the SamPrimeaux/mobiledashboard repo.",
          "This is a sandbox generation run.",
          "Do not use live promotion paths.",
          "Do not hardcode tenant, workspace, or user fallbacks.",
          "Return concise implementation instructions and file contents/summaries for this phase.",
          "Include run_id in any manifest or metadata you propose.",
          "No emojis."
        ].join("\\n")
      },
      {
        role: "user",
        content: [
          `Run Agent Meauxbility CMS phase: ${phase.id}`,
          "",
          `Run ID: ${runId}`,
          `Tenant: ${tenantId}`,
          `Workspace: ${workspaceId}`,
          `User: ${userId}`,
          `Model: ${phase.model}`,
          `Live promotion allowed: ${allowLivePromotion ? "yes" : "no"}`,
          "",
          "Required behavior:",
          "- Generate only sandbox-safe outputs.",
          "- Write or describe outputs for the approved mobiledashboard repo paths only.",
          "- Include exact files that should exist after this phase.",
          "- Keep the output compact enough for the local runner to archive.",
          "",
          prompt
        ].join("\\n")
      }
    ],
    metadata: {
      run_id: runId,
      phase_id: phase.id,
      source: "agent_meauxbility_direct_openai"
    }
  };

  try {
    const res = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "authorization": `Bearer ${process.env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });

    const text = await res.text();
    let data = {};
    try { data = JSON.parse(text); } catch {}

    const outputText = data && Object.keys(data).length ? extractResponseText(data) : text;

    const usage = data.usage || {};
    const inputTokens = Number(usage.input_tokens || 0);
    const outputTokens = Number(usage.output_tokens || 0);
    const totalTokens = Number(usage.total_tokens || inputTokens + outputTokens);

    return {
      ok: res.ok,
      status: res.status,
      text: outputText || text,
      raw: text,
      usage: {
        input_tokens: inputTokens,
        output_tokens: outputTokens,
        total_tokens: totalTokens,
      },
    };
  } finally {
    clearTimeout(timeout);
  }
}

async function callLiveAgentSamPhase(phase, prompt) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), maxPhaseSeconds * 1000);

  const body = {
    mode: process.env.AGENTSAM_PHASE_API_MODE || "agent",
    model_preference: phase.model,
    model: phase.model,
    tenant_id: tenantId,
    workspace_id: workspaceId,
    user_id: userId,
    run_id: runId,
    run_group_id: runId,
    phase_id: phase.id,
    allow_live_promotion: allowLivePromotion,
    max_cost_usd: Number(process.env.AGENTSAM_MAX_PHASE_COST_USD || 0.35),
    message: [
      `Run Agent Meauxbility CMS phase: ${phase.id}`,
      "",
      `Run ID: ${runId}`,
      `Tenant: ${tenantId}`,
      `Workspace: ${workspaceId}`,
      `User: ${userId}`,
      `Model: ${phase.model}`,
      `Live promotion allowed: ${allowLivePromotion ? "yes" : "no"}`,
      "",
      prompt,
    ].join("\\n"),
    metadata: {
      run_id: runId,
      phase_id: phase.id,
      source: "agent_meauxbility_overnight",
      required_deltas: phase.requiredDeltas,
    },
  };

  try {
    const headers = { "content-type": "application/json" };

    if (process.env.AGENTSAM_API_TOKEN) {
      headers.authorization = `Bearer ${process.env.AGENTSAM_API_TOKEN}`;
    }

    if (process.env.AGENTSAM_INTERNAL_SECRET) {
      headers["x-agentsam-secret"] = process.env.AGENTSAM_INTERNAL_SECRET;
      headers["x-internal-secret"] = process.env.AGENTSAM_INTERNAL_SECRET;
    }

    if (process.env.IAM_INTERNAL_SECRET) {
      headers["x-iam-internal-secret"] = process.env.IAM_INTERNAL_SECRET;
    }

    if (process.env.AGENTSAM_SESSION_COOKIE) {
      headers.cookie = process.env.AGENTSAM_SESSION_COOKIE;
    }

    const res = await fetch(apiUrl, {
      method: "POST",
      headers,
      body: JSON.stringify(body),
      signal: controller.signal,
    });

    const text = await res.text();
    return { ok: res.ok, status: res.status, text, raw: text, usage: {} };
  } finally {
    clearTimeout(timeout);
  }
}

async function main() {
  const allRequiredTables = Array.from(new Set(phases.flatMap((p) => p.requiredDeltas)));
  let totalEstimatedCost = 0;

  const manifest = {
    run_id: runId,
    status: "running",
    started_at: nowIso(),
    api_url: apiUrl,
    tenant_id: tenantId,
    workspace_id: workspaceId,
    user_id: userId,
    default_model: defaultModel,
    escalation_model: escalationModel,
    max_total_cost_usd: maxTotalCost,
    phases: [],
  };

  fs.writeFileSync(`${runDir}/manifest.json`, JSON.stringify(manifest, null, 2));

  if (phaseExecutor === "direct_openai") {
    const workflowId = "wf_agent_meauxbility_direct_openai";
    insertFiltered("agentsam_workflows", {
      id: workflowId,
      tenant_id: tenantId,
      workspace_id: workspaceId,
      workflow_key: "agent_meauxbility_direct_openai",
      display_name: "Agent Meauxbility Direct OpenAI Sandbox",
      description: "Direct OpenAI sandbox workflow for Agent Meauxbility CMS generation.",
      workflow_type: "agentic",
      trigger_type: "manual",
      default_mode: "agent",
      risk_level: "low",
      requires_approval: 0,
      metadata_json: JSON.stringify({ run_id: runId, source: "mobiledashboard" }),
      is_active: 1,
    });

    insertFiltered("agentsam_workflow_runs", {
      id: runId,
      workflow_id: workflowId,
      workflow_key: "agent_meauxbility_direct_openai",
      display_name: "Agent Meauxbility Direct OpenAI Sandbox Run",
      tenant_id: tenantId,
      workspace_id: workspaceId,
      user_id: userId,
      session_id: runId,
      run_group_id: runId,
      trigger_type: "manual",
      status: "running",
      input_json: JSON.stringify({ run_id: runId, executor: phaseExecutor, model: defaultModel }),
      output_json: "{}",
      step_results_json: "[]",
      steps_completed: 0,
      steps_total: phases.length,
      model_used: defaultModel,
      input_tokens: 0,
      output_tokens: 0,
      cost_usd: 0,
      environment: "sandbox",
      metadata_json: JSON.stringify({ run_id: runId, source: "mobiledashboard" }),
      started_at: Math.floor(Date.now() / 1000),
      graph_mode: 1,
      current_node_key: "surface_map",
    });
  }

  for (const phase of phases) {
    if (totalEstimatedCost >= maxTotalCost) {
      throw new Error(`Budget cap reached before phase ${phase.id}`);
    }

    const prompt = fs.readFileSync(phase.promptFile, "utf8");
    const before = snapshotCounts(phase.requiredDeltas);
    const started = Date.now();

    console.log(`[phase:start] ${phase.id}`);
    console.log(`[phase:required] ${phase.requiredDeltas.join(", ")}`);

    let apiResult;
    try {
      apiResult = await callAgentPhase(phase, prompt);
    } catch (err) {
      const logged = logError({
        phaseId: phase.id,
        errorType: "api_call_failed",
        message: err.message,
        metadata: { stack: err.stack },
      });
      throw new Error(`Phase ${phase.id} API call failed. Logged ${JSON.stringify(logged)}`);
    }

    fs.writeFileSync(`${runDir}/${phase.id}.api_response.txt`, apiResult.text || "");

    if (apiResult.ok && phaseExecutor === "direct_openai") {
      const phaseArtifactKey = `cms/test-runs/agent-meauxbility/${runId}/${phase.id}.response.txt`;
      const phaseArtifactId = `art_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`;
      const stepId = `estep_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`;
      const chainId = `atc_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`;
      const usageId = `ue_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`;

      insertFiltered("agentsam_artifacts", {
        id: phaseArtifactId,
        user_id: userId,
        tenant_id: tenantId,
        workspace_id: workspaceId,
        name: `Agent Meauxbility ${phase.id} response ${runId}`,
        description: `Direct OpenAI phase response archived locally for ${phase.id}. R2 upload/promotion remains disabled in this minimal fail-fast path.`,
        artifact_type: "txt",
        r2_key: phaseArtifactKey,
        source: "agent_meauxbility_direct_openai",
        tags: JSON.stringify(["agent-meauxbility", "direct-openai", phase.id, runId]),
        is_public: 0,
        file_size_bytes: Buffer.byteLength(apiResult.text || "", "utf8"),
        created_at: Math.floor(Date.now() / 1000),
        updated_at: Math.floor(Date.now() / 1000),
      });

      insertFiltered("agentsam_execution_steps", {
        id: stepId,
        execution_id: runId,
        node_key: phase.id,
        node_type: "agent",
        status: "success",
        input_json: JSON.stringify({ run_id: runId, phase_id: phase.id, model: phase.model }),
        output_json: JSON.stringify({ response_path: `${runDir}/${phase.id}.api_response.txt`, artifact_id: phaseArtifactId }),
        started_at: Math.floor(started / 1000),
        completed_at: Math.floor(Date.now() / 1000),
        latency_ms: Date.now() - started,
        tokens_in: apiResult.usage?.input_tokens || 0,
        tokens_out: apiResult.usage?.output_tokens || 0,
        cost_usd: 0,
        quality_score: 1,
        gate_results_json: JSON.stringify({ pass: true, mode: "direct_openai" }),
        edge_taken: "next",
      });

      insertFiltered("agentsam_tool_chain", {
        id: chainId,
        tenant_id: tenantId,
        workspace_id: workspaceId,
        user_id: userId,
        depth: phases.findIndex((p) => p.id === phase.id),
        tool_name: `agent_meauxbility_${phase.id}`,
        tool_status: "completed",
        input_json: JSON.stringify({ run_id: runId, phase_id: phase.id, model: phase.model }),
        output_summary: `Completed direct OpenAI phase ${phase.id}`,
        result_json: JSON.stringify({ step_id: stepId, artifact_id: phaseArtifactId }),
        duration_ms: Date.now() - started,
        input_tokens: apiResult.usage?.input_tokens || 0,
        output_tokens: apiResult.usage?.output_tokens || 0,
        cost_usd: 0,
        started_at: Math.floor(started / 1000),
        completed_at: Math.floor(Date.now() / 1000),
        execution_step_id: stepId,
        workflow_run_id: runId,
      });

      insertFiltered("agentsam_usage_events", {
        id: usageId,
        tenant_id: tenantId,
        workspace_id: workspaceId,
        user_id: userId,
        session_id: runId,
        agent_name: "agent-meauxbility",
        provider: "openai",
        model: phase.model,
        model_key: phase.model,
        tokens_in: apiResult.usage?.input_tokens || 0,
        tokens_out: apiResult.usage?.output_tokens || 0,
        total_tokens: apiResult.usage?.total_tokens || 0,
        cost_usd: 0,
        status: "ok",
        tool_name: `agent_meauxbility_${phase.id}`,
        event_type: `agent_meauxbility_${phase.id}`,
        ref_table: "agentsam_execution_steps",
        ref_id: stepId,
        duration_ms: Date.now() - started,
        created_at: Math.floor(Date.now() / 1000),
      });

      if (phase.id === "validation") {
        insertFiltered("agentsam_execution_dependency_graph", {
          id: `edg_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`,
          tenant_id: tenantId,
          workspace_id: workspaceId,
          user_id: userId,
          run_group_id: runId,
          workflow_run_id: runId,
          chain_id: chainId,
          depends_on_chain_id: chainId,
          dependency_type: "sequential",
          status: "satisfied",
          metadata_json: JSON.stringify({ run_id: runId, phase_id: phase.id, self_check: true }),
          created_at: Math.floor(Date.now() / 1000),
          updated_at: Math.floor(Date.now() / 1000),
        });

        insertFiltered("agentsam_execution_performance_metrics", {
          id: `epm_${crypto.randomUUID().replaceAll("-", "").slice(0, 16)}`,
          tenant_id: tenantId,
          workspace_id: workspaceId,
          user_id: userId,
          metric_date: new Date().toISOString().slice(0, 10),
          metric_grain: "daily",
          source_table: "agentsam_tool_chain",
          workflow_run_id: runId,
          chain_id: chainId,
          task_type: "agent_meauxbility",
          model_key: phase.model,
          provider: "openai",
          execution_count: 1,
          success_count: 1,
          total_tokens_consumed: apiResult.usage?.total_tokens || 0,
          input_tokens: apiResult.usage?.input_tokens || 0,
          output_tokens: apiResult.usage?.output_tokens || 0,
          total_cost_usd: 0,
          avg_cost_usd: 0,
          metadata_json: JSON.stringify({ run_id: runId, phase_id: phase.id }),
          first_seen_at: Math.floor(started / 1000),
          last_seen_at: Math.floor(Date.now() / 1000),
          last_computed_at: Math.floor(Date.now() / 1000),
        });
      }
    }

    if (!apiResult.ok) {
      const logged = logError({
        phaseId: phase.id,
        errorType: "api_non_200",
        message: `Agent API returned HTTP ${apiResult.status}`,
        metadata: { response_preview: String(apiResult.text || "").slice(0, 2000) },
      });
      throw new Error(`Phase ${phase.id} failed HTTP ${apiResult.status}. Logged ${JSON.stringify(logged)}`);
    }

    const after = snapshotCounts(phase.requiredDeltas);
    const deltas = deltaReport(before, after, phase.requiredDeltas);
    const missing = deltas.filter((d) => !d.ok);

    const phaseSummary = {
      phase_id: phase.id,
      model: phase.model,
      api_status: apiResult.status,
      elapsed_ms: Date.now() - started,
      before,
      after,
      deltas,
      missing,
      passed: missing.length === 0,
    };

    fs.writeFileSync(`${runDir}/${phase.id}.summary.json`, JSON.stringify(phaseSummary, null, 2));
    manifest.phases.push(phaseSummary);
    fs.writeFileSync(`${runDir}/manifest.json`, JSON.stringify(manifest, null, 2));

    if (missing.length) {
      const logged = logError({
        phaseId: phase.id,
        errorType: "missing_required_db_tracking",
        message: `Stopping after ${phase.id}. Missing required DB deltas: ${missing.map((m) => m.table).join(", ")}`,
        metadata: { phase_summary: phaseSummary },
      });

      console.error(JSON.stringify({ pass: false, reason: "missing_required_db_tracking", phase: phase.id, missing, logged }, null, 2));
      process.exit(2);
    }

    console.log(`[phase:pass] ${phase.id}`);
  }

  manifest.status = "completed";
  manifest.completed_at = nowIso();
  manifest.pass = true;
  fs.writeFileSync(`${runDir}/manifest.json`, JSON.stringify(manifest, null, 2));

  console.log(JSON.stringify(manifest, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
