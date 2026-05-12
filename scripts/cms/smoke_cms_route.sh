#!/usr/bin/env bash
set -euo pipefail
BASE="${AGENT_MEAUXBILITY_APP_URL:-https://agent.meauxbility.workers.dev}"
echo "== /cms headers =="
/usr/bin/curl -I "${BASE}/cms" | /usr/bin/sed -n "1,14p"
echo ""
echo "== /cms body markers =="
/usr/bin/curl -sS "${BASE}/cms" | /usr/bin/grep -Ei "cms-editor|Start Building Your Page|Section Library|Page Settings|AGENT_MEAUXBILITY_MPA_ROUTE_BRIDGE" | /usr/bin/head -20 || true
