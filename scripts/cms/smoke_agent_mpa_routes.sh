#!/usr/bin/env bash
set -euo pipefail
BASE="${AGENT_MEAUXBILITY_APP_URL:-https://agent.meauxbility.workers.dev}"

for path in / /automations /dashboard /cms; do
  echo "== ${path} =="
  /usr/bin/curl -I "${BASE}${path}" | /usr/bin/sed -n "1,12p"
done
