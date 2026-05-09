#!/usr/bin/env bash
# source-safe loader: strict mode disabled for interactive sourcing

ENV_FILE="${AGENTSAM_ENV_FILE:-/Users/samprimeaux/inneranimalmedia/.env.agentsam.local}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing env file: $ENV_FILE"
  exit 1
fi

set -a
. "$ENV_FILE"
set +a

: "${IAM_D1_DB:?Missing IAM_D1_DB}"
: "${IAM_TENANT_ID:?Missing IAM_TENANT_ID}"
: "${IAM_WORKSPACE_ID:?Missing IAM_WORKSPACE_ID}"
: "${IAM_USER_ID:?Missing IAM_USER_ID}"
: "${CLOUDFLARE_R2_BUCKET:?Missing CLOUDFLARE_R2_BUCKET}"

export AGENT_MEAUXBILITY_APP_URL="${AGENT_MEAUXBILITY_APP_URL:-https://agent.meauxbility.workers.dev}"
export AGENT_MEAUXBILITY_SAFE_PREFIX="${AGENT_MEAUXBILITY_SAFE_PREFIX:-cms/test-runs/agent-meauxbility}"

echo "Loaded Agent Meauxbility env"
echo "  IAM_D1_DB=$IAM_D1_DB"
echo "  IAM_TENANT_ID=<set>"
echo "  IAM_WORKSPACE_ID=<set>"
echo "  IAM_USER_ID=<set>"
echo "  CLOUDFLARE_R2_BUCKET=$CLOUDFLARE_R2_BUCKET"
echo "  AGENT_MEAUXBILITY_APP_URL=$AGENT_MEAUXBILITY_APP_URL"

# Source-safety reset: keep interactive terminals alive.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/.nvm/versions/node/v22.22.2/bin:${PATH:-}"
set +e 2>/dev/null || true
set +u 2>/dev/null || true
set +o pipefail 2>/dev/null || true
