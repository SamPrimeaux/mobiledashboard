#!/usr/bin/env bash
set -euo pipefail

BASE="${AGENT_MEAUXBILITY_APP_URL:-https://agent.meauxbility.workers.dev}"

echo "== /cms =="
/usr/bin/curl -I "$BASE/cms" | /usr/bin/sed -n '1,14p'

echo ""
echo "== /cms markers =="
/usr/bin/curl -sS "$BASE/cms" | /usr/bin/grep -nE "Moon Glass CMS editor|moon-glass-editor-shell|moon-glass-workspace|Theme connected" | /usr/bin/head -20

echo ""
echo "== theme vars =="
/usr/bin/curl -sS "$BASE/api/cms/theme.css?slug=moon-glass&mode=vars" | /usr/bin/head -80

echo ""
echo "== theme full import =="
/usr/bin/curl -sS "$BASE/api/cms/theme.css?slug=moon-glass&mode=full" | /usr/bin/grep -n "@import" || true
