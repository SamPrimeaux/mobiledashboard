# Agent Meauxbility CMS Skill

## Purpose

Build, validate, and evolve the Agent Meauxbility CMS editor and component library inside SamPrimeaux/mobiledashboard using low-cost Agent Sam model routing.

## Scope

This skill operates only inside the mobiledashboard repo.

Allowed source paths:

apps/agent-meauxbility/
packages/cms-editor/
packages/cms-components/
packages/cms-schemas/
packages/agentsam-runtime/
scripts/cms/
agents/agent-meauxbility-cms/
tmp/agent-meauxbility/

Allowed R2 prefixes:

cms/test-runs/agent-meauxbility/
dev/agent-meauxbility/
analytics/agentsam/cms-live-editor/
captures/inneranimalmedia/results/

## Required environment

The runner must require these values explicitly:

IAM_D1_DB
IAM_TENANT_ID
IAM_WORKSPACE_ID
IAM_USER_ID
CLOUDFLARE_R2_BUCKET

Never fallback to Sam-specific IDs in reusable scripts.

## Model routing

Use gpt-5.4-nano for scaffolding, small components, schema summaries, manifests, artifact registry rows, validation reports, low-risk edits, and dry-run planning.

Use gpt-5.4-mini for architectural reconciliation, multi-file refactors, failed Nano repair, build/test failure diagnosis, component cleanup, and final consistency passes.

## Required outputs per run

Every meaningful generation run must produce:

1. R2 manifest JSON
2. R2 analytics JSON
3. R2 capture JSON
4. agentsam_artifacts rows
5. agentsam_tool_chain phase rows
6. agentsam_execution_steps rows
7. agentsam_execution_dependency_graph rows when phases depend on each other
8. agentsam_execution_performance_metrics row
9. agentsam_usage_events row if a model call was made

## Validation gates

A run is not complete unless app source files exist, package/build config exists, component exports exist, schema exports exist, R2 manifest write/readback works, artifact rows exist, execution steps exist, dependency graph exists for multi-phase runs, and usage/cost telemetry exists for model calls.

## Promotion gate

Dry runs may write only to safe prefixes.

Live promotion requires AGENTSAM_ALLOW_LIVE_PROMOTION=1 and an explicit approval row or approval note in Agent Sam runtime metadata.

## UI requirements

- dark minimal Agent Platform style
- glassy panels where appropriate
- clean typography
- no emojis
- schema-driven preview
- responsive layout
- left navigation or rail
- editor panel
- theme panel
- live preview panel
- artifact panel

## Failure policy

If any required row or artifact is missing:

1. Do not continue generating more app code.
2. Write a failure capture to R2.
3. Register the failure artifact.
4. Return exact missing labels.
5. Recommend the smallest repair script.

## Agent Sam DB contract

This skill must use the repo-local DB contract before planning or generation:

agents/agent-meauxbility-cms/agentsam_db_contract.py

That contract defines:

- required agentsam_* runtime tables
- required cms_* tables
- required E2E nonzero counts
- required tool-chain/execution/artifact/usage touchpoints
- safe R2 prefixes
- blocked live-promotion prefixes
- model routing policy
- multi-tenant safety policy

A run is not valid if it only creates files. It must also prove the Agent Sam runtime chain through planning, workflow graph, prompt routing, tool execution, dependency graph, artifacts, usage, and performance metrics.
