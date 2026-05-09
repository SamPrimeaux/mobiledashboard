# Agent Meauxbility CMS Editor Agent Pack

This agent pack coordinates low-cost Nano/Mini model runs to build and validate the Agent Meauxbility CMS editor, component library, and R2-backed artifact workflow inside the existing SamPrimeaux/mobiledashboard repo.

## Source of truth

GitHub repo: SamPrimeaux/mobiledashboard

Working branch: sandbox/agent-meauxbility-cms-editor

Git is the source of truth for app/library code. R2 is only for generated previews, manifests, reports, captures, and compiled artifacts.

## Runtime target

https://agent.meauxbility.workers.dev

## Primary goals

1. Build a production-structured full stack CMS editor shell.
2. Build a reusable CMS component library.
3. Build schema-driven sections, themes, and templates.
4. Generate safe R2 previews and manifests.
5. Register generated outputs in agentsam_artifacts.
6. Track validation, tool-chain, execution-step, dependency, usage, and performance rows in Agent Sam tables.
7. Keep default generation cheap with gpt-5.4-nano.
8. Escalate only when needed to gpt-5.4-mini.

## Required repo layout

apps/agent-meauxbility/
packages/cms-editor/
packages/cms-components/
packages/cms-schemas/
packages/agentsam-runtime/
scripts/cms/
agents/agent-meauxbility-cms/

## Non-negotiables

- Do not create a new repo.
- Do not move this into the InnerAnimalMedia repo.
- Do not make R2 the source of truth.
- Do not hardcode tenant, workspace, or user fallbacks.
- Do not touch live production paths unless AGENTSAM_ALLOW_LIVE_PROMOTION=1.
- Do not write to live CMS theme/page/component paths during dry runs.
- No emojis in UI or generated app copy.
- First pass should be small, real, and buildable.

## Safe R2 prefixes

cms/test-runs/agent-meauxbility/<run_id>/
dev/agent-meauxbility/<run_id>/
analytics/agentsam/cms-live-editor/<run_id>.json
captures/inneranimalmedia/results/<run_id>.json

## Model policy

Default model: gpt-5.4-nano
Escalation model: gpt-5.4-mini

Escalate only when schema inference fails, build fails twice, generated code is incomplete, validation says required rows/artifacts are missing, or Nano output is too shallow for architectural decisions.

## Batch order

1. Surface map, read-only.
2. Component library scaffold.
3. CMS editor app scaffold.
4. Runtime/artifact wiring.
5. E2E validation.
6. Optional mini refinement.
7. Commit summary and next actions.
