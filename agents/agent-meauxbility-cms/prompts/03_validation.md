# Phase 03 — Validation

Validate the generated app/library.

Required checks:
- files exist
- package config exists
- imports resolve
- schemas export
- components export
- R2 manifest can be written/read
- agentsam_artifacts row can be registered
- agentsam_tool_chain rows can be written
- agentsam_execution_steps rows can be written
- agentsam_execution_dependency_graph rows can be written for phase order
- agentsam_usage_events row is written if model calls were used

Write reports to safe R2 prefixes only:
- cms/test-runs/agent-meauxbility/<run_id>/
- analytics/agentsam/cms-live-editor/<run_id>.json
- captures/inneranimalmedia/results/<run_id>.json

Fail if any required check is zero.
