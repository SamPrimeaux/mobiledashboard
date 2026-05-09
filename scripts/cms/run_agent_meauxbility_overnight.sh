#!/usr/bin/env bash
set -euo pipefail

cd /Users/samprimeaux/mobiledashboard

source scripts/cms/load-agent-meauxbility-env.sh

export AGENTSAM_BATCH_NAME="${AGENTSAM_BATCH_NAME:-agent-meauxbility-cms-editor-overnight}"
export AGENTSAM_BATCH_MODE="${AGENTSAM_BATCH_MODE:-overnight_sandbox}"

export AGENTSAM_DEFAULT_MODEL="${AGENTSAM_DEFAULT_MODEL:-gpt-5.4-nano}"
export AGENTSAM_ESCALATION_MODEL="${AGENTSAM_ESCALATION_MODEL:-gpt-5.4-mini}"
export AGENTSAM_ALLOW_ESCALATION="${AGENTSAM_ALLOW_ESCALATION:-1}"

export AGENTSAM_MAX_TOTAL_COST_USD="${AGENTSAM_MAX_TOTAL_COST_USD:-2.00}"
export AGENTSAM_MAX_PHASE_COST_USD="${AGENTSAM_MAX_PHASE_COST_USD:-0.35}"
export AGENTSAM_MAX_MODEL_CALLS="${AGENTSAM_MAX_MODEL_CALLS:-24}"
export AGENTSAM_MAX_ESCALATIONS="${AGENTSAM_MAX_ESCALATIONS:-4}"

export AGENTSAM_MAX_TOTAL_SECONDS="${AGENTSAM_MAX_TOTAL_SECONDS:-21600}"
export AGENTSAM_MAX_PHASE_SECONDS="${AGENTSAM_MAX_PHASE_SECONDS:-2700}"
export AGENTSAM_MAX_TOOL_SECONDS="${AGENTSAM_MAX_TOOL_SECONDS:-900}"

export AGENTSAM_ALLOW_LIVE_PROMOTION="${AGENTSAM_ALLOW_LIVE_PROMOTION:-0}"
export AGENTSAM_REQUIRE_R2_READBACK="${AGENTSAM_REQUIRE_R2_READBACK:-1}"
export AGENTSAM_REQUIRE_ARTIFACT_REGISTRY="${AGENTSAM_REQUIRE_ARTIFACT_REGISTRY:-1}"
export AGENTSAM_REQUIRE_USAGE_EVENTS="${AGENTSAM_REQUIRE_USAGE_EVENTS:-1}"
export AGENTSAM_REQUIRE_EXECUTION_STEPS="${AGENTSAM_REQUIRE_EXECUTION_STEPS:-1}"
export AGENTSAM_REQUIRE_DEPENDENCY_GRAPH="${AGENTSAM_REQUIRE_DEPENDENCY_GRAPH:-1}"

export AGENTSAM_R2_SAFE_PREFIX="${AGENTSAM_R2_SAFE_PREFIX:-cms/test-runs/agent-meauxbility}"
export AGENTSAM_LOCAL_RUN_DIR="${AGENTSAM_LOCAL_RUN_DIR:-tmp/agent-meauxbility/overnight}"

# Use live Agent Sam API per phase.
export AGENTSAM_PHASE_API_URL="${AGENTSAM_PHASE_API_URL:-https://inneranimalmedia.com/api/agent/chat}"
export AGENTSAM_PHASE_API_MODE="${AGENTSAM_PHASE_API_MODE:-agent}"
export AGENTSAM_STOP_ON_MISSING_DB_WRITES="${AGENTSAM_STOP_ON_MISSING_DB_WRITES:-1}"

BRANCH="$(git branch --show-current)"
if [ "$BRANCH" != "sandbox/agent-meauxbility-cms-editor" ]; then
  echo "[fail] Wrong branch: $BRANCH"
  exit 1
fi

RUN_ID="agent_meauxbility_overnight_$(date -u +%Y%m%dT%H%M%SZ)"
export AGENTSAM_RUN_ID="$RUN_ID"

RUN_DIR="${AGENTSAM_LOCAL_RUN_DIR}/${RUN_ID}"
mkdir -p "$RUN_DIR"

LOG="$RUN_DIR/run.log"
SUMMARY="$RUN_DIR/summary.json"

{
  echo "Agent Meauxbility overnight batch"
  echo "run_id=$RUN_ID"
  echo "started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "branch=$BRANCH"
  echo "default_model=$AGENTSAM_DEFAULT_MODEL"
  echo "escalation_model=$AGENTSAM_ESCALATION_MODEL"
  echo "max_total_cost_usd=$AGENTSAM_MAX_TOTAL_COST_USD"
  echo "max_phase_cost_usd=$AGENTSAM_MAX_PHASE_COST_USD"
  echo "max_total_seconds=$AGENTSAM_MAX_TOTAL_SECONDS"
  echo "live_promotion=$AGENTSAM_ALLOW_LIVE_PROMOTION"
  echo "phase_api_url=$AGENTSAM_PHASE_API_URL"
  echo ""
  echo "Git state:"
  git status --short
  echo ""
} | tee "$LOG"

START_EPOCH="$(date +%s)"

echo "[1/4] Validating DB contract..." | tee -a "$LOG"
python3 agents/agent-meauxbility-cms/agentsam_db_contract.py > "$RUN_DIR/db_contract_summary.json"

echo "[2/4] Executing live Agent Sam phases with fail-fast DB validation..." | tee -a "$LOG"
node scripts/cms/execute_agent_meauxbility_phases.mjs 2>&1 | tee -a "$LOG"

echo "[3/4] Recording current file map..." | tee -a "$LOG"
find agents apps packages scripts/cms -maxdepth 6 -type f | sort > "$RUN_DIR/file_map.txt" || true

echo "[4/4] Writing morning summary..." | tee -a "$LOG"
END_EPOCH="$(date +%s)"
ELAPSED="$((END_EPOCH - START_EPOCH))"

cat > "$SUMMARY" <<JSON
{
  "run_id": "$RUN_ID",
  "status": "completed_or_stopped_by_executor",
  "started_at": "$(date -u -r "$START_EPOCH" +%Y-%m-%dT%H:%M:%SZ)",
  "completed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "elapsed_seconds": $ELAPSED,
  "branch": "$BRANCH",
  "default_model": "$AGENTSAM_DEFAULT_MODEL",
  "escalation_model": "$AGENTSAM_ESCALATION_MODEL",
  "max_total_cost_usd": "$AGENTSAM_MAX_TOTAL_COST_USD",
  "max_phase_cost_usd": "$AGENTSAM_MAX_PHASE_COST_USD",
  "max_total_seconds": "$AGENTSAM_MAX_TOTAL_SECONDS",
  "live_promotion_enabled": "$AGENTSAM_ALLOW_LIVE_PROMOTION",
  "phase_api_url": "$AGENTSAM_PHASE_API_URL",
  "run_dir": "$RUN_DIR"
}
JSON

cat "$SUMMARY" | tee -a "$LOG"

echo ""
echo "DONE"
echo "Run dir: $RUN_DIR"
echo "Log: $LOG"
echo "Summary: $SUMMARY"
