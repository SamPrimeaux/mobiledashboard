#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
README = ROOT / "README.md"

START = "<!-- AGENT_MEAUXBILITY_FILETREE_START -->"
END = "<!-- AGENT_MEAUXBILITY_FILETREE_END -->"

section = f'''{START}
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
{END}
'''

old = README.read_text() if README.exists() else "# Agent Meauxbility Dashboard\n"
pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)

if pattern.search(old):
    new = pattern.sub(section.strip(), old)
else:
    new = old.rstrip() + "\n\n" + section.strip() + "\n"

README.write_text(new)
print(f"updated {README}")
