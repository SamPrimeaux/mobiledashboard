# CMS Table Schemas

Captured: `2026-05-09T21:19:36.573309+00:00`
Database: `inneranimalmedia-business`
Tables: `27`

## Notes

- This capture is read-only.
- It uses the existing Agent Meauxbility environment and Wrangler D1.
- `env.CMS / cms` is the clean CMS editor/dev bucket.
- `CLOUDFLARE_R2_BUCKET / inneranimalmedia` remains the production brand/theme/assets bucket.

## Table of contents

- [cms_3d_assets](#cms-3d-assets) — 14 rows
- [cms_activity_log](#cms-activity-log) — 1 rows
- [cms_assets](#cms-assets) — 100 rows
- [cms_collection_assets](#cms-collection-assets) — 0 rows
- [cms_collections](#cms-collections) — 5 rows
- [cms_component_templates](#cms-component-templates) — 24 rows
- [cms_content](#cms-content) — 4 rows
- [cms_conversion_jobs](#cms-conversion-jobs) — 0 rows
- [cms_conversions](#cms-conversions) — 0 rows
- [cms_folders](#cms-folders) — 6 rows
- [cms_global_settings](#cms-global-settings) — 5 rows
- [cms_liquid_imports](#cms-liquid-imports) — 0 rows
- [cms_liquid_sections](#cms-liquid-sections) — 0 rows
- [cms_live_edit_sessions](#cms-live-edit-sessions) — 0 rows
- [cms_live_rollbacks](#cms-live-rollbacks) — 0 rows
- [cms_navigation_menus](#cms-navigation-menus) — 3 rows
- [cms_override_versions](#cms-override-versions) — 0 rows
- [cms_page_drafts](#cms-page-drafts) — 0 rows
- [cms_page_overrides](#cms-page-overrides) — 0 rows
- [cms_page_sections](#cms-page-sections) — 46 rows
- [cms_pages](#cms-pages) — 17 rows
- [cms_section_components](#cms-section-components) — 93 rows
- [cms_site_pages](#cms-site-pages) — 49 rows
- [cms_tenants](#cms-tenants) — 12 rows
- [cms_theme_preferences](#cms-theme-preferences) — 4 rows
- [cms_themes](#cms-themes) — 108 rows
- [cms_video_projects](#cms-video-projects) — 3 rows

---

## cms_3d_assets

Rows: `14`
Columns: `17`
Capture latency: `3807ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `asset_id` | `TEXT` | 1 | `` | 0 |
| 2 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 3 | `meshy_task_id` | `TEXT` | 0 | `` | 0 |
| 4 | `model_type` | `TEXT` | 0 | `` | 0 |
| 5 | `prompt` | `TEXT` | 0 | `` | 0 |
| 6 | `source_image_url` | `TEXT` | 0 | `` | 0 |
| 7 | `status` | `TEXT` | 0 | `'pending'` | 0 |
| 8 | `glb_url` | `TEXT` | 0 | `` | 0 |
| 9 | `thumbnail_url` | `TEXT` | 0 | `` | 0 |
| 10 | `poly_count` | `INTEGER` | 0 | `` | 0 |
| 11 | `error_message` | `TEXT` | 0 | `` | 0 |
| 12 | `created_at` | `INTEGER` | 1 | `` | 0 |
| 13 | `completed_at` | `INTEGER` | 0 | `` | 0 |
| 14 | `r2_key` | `TEXT` | 0 | `` | 0 |
| 15 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 16 | `s3_endpoint` | `TEXT` | 0 | `` | 0 |

```sql
CREATE TABLE cms_3d_assets (
    id TEXT PRIMARY KEY,
    asset_id TEXT NOT NULL,
    tenant_id TEXT NOT NULL,
    meshy_task_id TEXT,
    model_type TEXT,
    prompt TEXT,
    source_image_url TEXT,
    status TEXT DEFAULT 'pending',
    glb_url TEXT,
    thumbnail_url TEXT,
    poly_count INTEGER,
    error_message TEXT,
    created_at INTEGER NOT NULL,
    completed_at INTEGER, r2_key TEXT, r2_bucket TEXT, s3_endpoint TEXT,
    FOREIGN KEY (asset_id) REFERENCES cms_assets(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id) ON DELETE CASCADE
);
```

---

## cms_activity_log

Rows: `1`
Columns: `10`
Capture latency: `3937ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `user_id` | `TEXT` | 0 | `` | 0 |
| 3 | `action` | `TEXT` | 1 | `` | 0 |
| 4 | `resource_type` | `TEXT` | 1 | `` | 0 |
| 5 | `resource_id` | `TEXT` | 1 | `` | 0 |
| 6 | `details` | `TEXT` | 0 | `` | 0 |
| 7 | `ip_address` | `TEXT` | 0 | `` | 0 |
| 8 | `user_agent` | `TEXT` | 0 | `` | 0 |
| 9 | `created_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_activity_log (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    user_id TEXT,
    action TEXT NOT NULL,
    resource_type TEXT NOT NULL,
    resource_id TEXT NOT NULL,
    details TEXT,
    ip_address TEXT,
    user_agent TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id) ON DELETE CASCADE
);
```

---

## cms_assets

Rows: `100`
Columns: `23`
Capture latency: `4020ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `filename` | `TEXT` | 1 | `` | 0 |
| 3 | `original_filename` | `TEXT` | 1 | `` | 0 |
| 4 | `path` | `TEXT` | 1 | `` | 0 |
| 5 | `size` | `INTEGER` | 1 | `` | 0 |
| 6 | `mime_type` | `TEXT` | 1 | `` | 0 |
| 7 | `category` | `TEXT` | 1 | `` | 0 |
| 8 | `tags` | `TEXT` | 0 | `` | 0 |
| 9 | `cloudflare_image_id` | `TEXT` | 0 | `` | 0 |
| 10 | `r2_key` | `TEXT` | 1 | `` | 0 |
| 11 | `public_url` | `TEXT` | 1 | `` | 0 |
| 12 | `thumbnail_url` | `TEXT` | 0 | `` | 0 |
| 13 | `metadata` | `TEXT` | 0 | `` | 0 |
| 14 | `created_by` | `TEXT` | 0 | `` | 0 |
| 15 | `created_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 16 | `updated_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 17 | `is_live` | `INTEGER` | 1 | `0` | 0 |
| 18 | `notes` | `TEXT` | 0 | `` | 0 |
| 19 | `builds` | `TEXT` | 0 | `` | 0 |
| 20 | `preferred_bg` | `TEXT` | 0 | `` | 0 |
| 21 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 22 | `s3_endpoint` | `TEXT` | 0 | `` | 0 |

```sql
CREATE TABLE cms_assets (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    filename TEXT NOT NULL,
    original_filename TEXT NOT NULL,
    path TEXT NOT NULL,
    size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    category TEXT NOT NULL,
    tags TEXT,
    cloudflare_image_id TEXT,
    r2_key TEXT NOT NULL,
    public_url TEXT NOT NULL,
    thumbnail_url TEXT,
    metadata TEXT,
    created_by TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP, is_live INTEGER NOT NULL DEFAULT 0, notes TEXT, builds TEXT, preferred_bg TEXT, r2_bucket TEXT, s3_endpoint TEXT,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id)
);
```

---

## cms_collection_assets

Rows: `0`
Columns: `4`
Capture latency: `4854ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `collection_id` | `TEXT` | 1 | `` | 1 |
| 1 | `asset_id` | `TEXT` | 1 | `` | 2 |
| 2 | `order_index` | `INTEGER` | 0 | `0` | 0 |
| 3 | `added_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_collection_assets (
    collection_id TEXT NOT NULL,
    asset_id TEXT NOT NULL,
    order_index INTEGER DEFAULT 0,
    added_at INTEGER NOT NULL,
    PRIMARY KEY (collection_id, asset_id),
    FOREIGN KEY (collection_id) REFERENCES cms_collections(id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES cms_assets(id) ON DELETE CASCADE
);
```

---

## cms_collections

Rows: `5`
Columns: `9`
Capture latency: `3698ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `name` | `TEXT` | 1 | `` | 0 |
| 3 | `description` | `TEXT` | 0 | `` | 0 |
| 4 | `thumbnail_url` | `TEXT` | 0 | `` | 0 |
| 5 | `is_public` | `INTEGER` | 0 | `0` | 0 |
| 6 | `created_by` | `TEXT` | 0 | `` | 0 |
| 7 | `created_at` | `INTEGER` | 1 | `` | 0 |
| 8 | `updated_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_collections (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    is_public INTEGER DEFAULT 0,
    created_by TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id) ON DELETE CASCADE
);
```

---

## cms_component_templates

Rows: `24`
Columns: `16`
Capture latency: `3909ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `template_name` | `TEXT` | 1 | `` | 0 |
| 2 | `template_type` | `TEXT` | 1 | `` | 0 |
| 3 | `category` | `TEXT` | 1 | `` | 0 |
| 4 | `preview_image_url` | `TEXT` | 0 | `` | 0 |
| 5 | `template_data` | `TEXT` | 1 | `` | 0 |
| 6 | `is_system` | `INTEGER` | 0 | `1` | 0 |
| 7 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 8 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 9 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 10 | `r2_key` | `TEXT` | 0 | `` | 0 |
| 11 | `s3_endpoint` | `TEXT` | 0 | `` | 0 |
| 12 | `tenant_id` | `TEXT` | 0 | `` | 0 |
| 13 | `source_liquid_file` | `TEXT` | 0 | `NULL` | 0 |
| 14 | `shopify_section_key` | `TEXT` | 0 | `NULL` | 0 |
| 15 | `liquid_import_id` | `TEXT` | 0 | `` | 0 |

```sql
CREATE TABLE cms_component_templates (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  template_name TEXT NOT NULL,
  template_type TEXT NOT NULL, 
  category TEXT NOT NULL, 
  preview_image_url TEXT,
  template_data TEXT NOT NULL, 
  is_system INTEGER DEFAULT 1, 
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
, r2_bucket TEXT, r2_key TEXT, s3_endpoint TEXT, tenant_id TEXT, source_liquid_file TEXT DEFAULT NULL, shopify_section_key TEXT DEFAULT NULL, liquid_import_id TEXT REFERENCES cms_liquid_imports(id) ON DELETE SET NULL);
```

---

## cms_content

Rows: `4`
Columns: `3`
Capture latency: `3779ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `key` | `TEXT` | 0 | `` | 1 |
| 1 | `value` | `TEXT` | 1 | `''` | 0 |
| 2 | `updated_at` | `TEXT` | 1 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_content (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

---

## cms_conversion_jobs

Rows: `0`
Columns: `12`
Capture latency: `4027ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `asset_id` | `TEXT` | 1 | `` | 0 |
| 3 | `service` | `TEXT` | 1 | `` | 0 |
| 4 | `status` | `TEXT` | 0 | `'pending'` | 0 |
| 5 | `input_format` | `TEXT` | 1 | `` | 0 |
| 6 | `output_format` | `TEXT` | 1 | `` | 0 |
| 7 | `job_id` | `TEXT` | 0 | `` | 0 |
| 8 | `result_url` | `TEXT` | 0 | `` | 0 |
| 9 | `error` | `TEXT` | 0 | `` | 0 |
| 10 | `created_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 11 | `completed_at` | `DATETIME` | 0 | `` | 0 |

```sql
CREATE TABLE cms_conversion_jobs (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    asset_id TEXT NOT NULL,
    service TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    input_format TEXT NOT NULL,
    output_format TEXT NOT NULL,
    job_id TEXT,
    result_url TEXT,
    error TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id),
    FOREIGN KEY (asset_id) REFERENCES cms_assets(id)
);
```

---

## cms_conversions

Rows: `0`
Columns: `13`
Capture latency: `4017ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `asset_id` | `TEXT` | 1 | `` | 0 |
| 2 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 3 | `source_format` | `TEXT` | 1 | `` | 0 |
| 4 | `target_format` | `TEXT` | 1 | `` | 0 |
| 5 | `status` | `TEXT` | 0 | `'pending'` | 0 |
| 6 | `cloudconvert_job_id` | `TEXT` | 0 | `` | 0 |
| 7 | `output_asset_id` | `TEXT` | 0 | `` | 0 |
| 8 | `output_url` | `TEXT` | 0 | `` | 0 |
| 9 | `error_message` | `TEXT` | 0 | `` | 0 |
| 10 | `started_at` | `INTEGER` | 0 | `` | 0 |
| 11 | `completed_at` | `INTEGER` | 0 | `` | 0 |
| 12 | `created_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_conversions (
    id TEXT PRIMARY KEY,
    asset_id TEXT NOT NULL,
    tenant_id TEXT NOT NULL,
    source_format TEXT NOT NULL,
    target_format TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    cloudconvert_job_id TEXT,
    output_asset_id TEXT,
    output_url TEXT,
    error_message TEXT,
    started_at INTEGER,
    completed_at INTEGER,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (asset_id) REFERENCES cms_assets(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id) ON DELETE CASCADE
);
```

---

## cms_folders

Rows: `6`
Columns: `7`
Capture latency: `4158ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `name` | `TEXT` | 1 | `` | 0 |
| 3 | `parent_id` | `TEXT` | 0 | `` | 0 |
| 4 | `path` | `TEXT` | 1 | `` | 0 |
| 5 | `created_at` | `INTEGER` | 1 | `` | 0 |
| 6 | `updated_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_folders (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    name TEXT NOT NULL,
    parent_id TEXT,
    path TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES cms_folders(id) ON DELETE CASCADE
);
```

---

## cms_global_settings

Rows: `5`
Columns: `17`
Capture latency: `5250ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `project_id` | `INTEGER` | 1 | `` | 0 |
| 2 | `site_name` | `TEXT` | 0 | `` | 0 |
| 3 | `site_logo_url` | `TEXT` | 0 | `` | 0 |
| 4 | `site_favicon_url` | `TEXT` | 0 | `` | 0 |
| 5 | `contact_email` | `TEXT` | 0 | `` | 0 |
| 6 | `contact_phone` | `TEXT` | 0 | `` | 0 |
| 7 | `social_links` | `TEXT` | 0 | `` | 0 |
| 8 | `footer_text` | `TEXT` | 0 | `` | 0 |
| 9 | `header_announcement` | `TEXT` | 0 | `` | 0 |
| 10 | `seo_defaults` | `TEXT` | 0 | `` | 0 |
| 11 | `scripts_head` | `TEXT` | 0 | `` | 0 |
| 12 | `scripts_body` | `TEXT` | 0 | `` | 0 |
| 13 | `analytics_id` | `TEXT` | 0 | `` | 0 |
| 14 | `settings_json` | `TEXT` | 0 | `` | 0 |
| 15 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 16 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_global_settings (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  project_id INTEGER NOT NULL UNIQUE,
  site_name TEXT,
  site_logo_url TEXT,
  site_favicon_url TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  social_links TEXT, 
  footer_text TEXT,
  header_announcement TEXT,
  seo_defaults TEXT, 
  scripts_head TEXT, 
  scripts_body TEXT, 
  analytics_id TEXT,
  settings_json TEXT, 
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
```

---

## cms_liquid_imports

Rows: `0`
Columns: `17`
Capture latency: `4409ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `'liq_' || lower(hex(randomblob(8)))` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `workspace_id` | `TEXT` | 0 | `` | 0 |
| 3 | `source_type` | `TEXT` | 1 | `` | 0 |
| 4 | `source_path` | `TEXT` | 1 | `` | 0 |
| 5 | `theme_name` | `TEXT` | 0 | `` | 0 |
| 6 | `status` | `TEXT` | 1 | `'pending'` | 0 |
| 7 | `sections_found` | `INTEGER` | 0 | `0` | 0 |
| 8 | `snippets_found` | `INTEGER` | 0 | `0` | 0 |
| 9 | `templates_found` | `INTEGER` | 0 | `0` | 0 |
| 10 | `sections_mapped` | `INTEGER` | 0 | `0` | 0 |
| 11 | `pages_created` | `INTEGER` | 0 | `0` | 0 |
| 12 | `error_log` | `TEXT` | 0 | `` | 0 |
| 13 | `workflow_run_id` | `TEXT` | 0 | `` | 0 |
| 14 | `started_at` | `INTEGER` | 0 | `unixepoch()` | 0 |
| 15 | `completed_at` | `INTEGER` | 0 | `` | 0 |
| 16 | `created_at` | `INTEGER` | 0 | `unixepoch()` | 0 |

```sql
CREATE TABLE cms_liquid_imports (
  id                TEXT PRIMARY KEY DEFAULT ('liq_' || lower(hex(randomblob(8)))),
  tenant_id         TEXT NOT NULL,
  workspace_id      TEXT,
  source_type       TEXT NOT NULL CHECK(source_type IN ('local','shopify_api','r2','zip')),
  source_path       TEXT NOT NULL,
  theme_name        TEXT,
  status            TEXT NOT NULL DEFAULT 'pending'
                    CHECK(status IN ('pending','extracting','parsing','mapping','registering','validating','complete','failed')),
  sections_found    INTEGER DEFAULT 0,
  snippets_found    INTEGER DEFAULT 0,
  templates_found   INTEGER DEFAULT 0,
  sections_mapped   INTEGER DEFAULT 0,
  pages_created     INTEGER DEFAULT 0,
  error_log         TEXT,
  workflow_run_id   TEXT REFERENCES agentsam_workflow_runs(id) ON DELETE SET NULL,
  started_at        INTEGER DEFAULT (unixepoch()),
  completed_at      INTEGER,
  created_at        INTEGER DEFAULT (unixepoch())
);
```

---

## cms_liquid_sections

Rows: `0`
Columns: `15`
Capture latency: `4543ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `'lsec_' || lower(hex(randomblob(8)))` | 1 |
| 1 | `import_id` | `TEXT` | 1 | `` | 0 |
| 2 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 3 | `file_name` | `TEXT` | 1 | `` | 0 |
| 4 | `section_key` | `TEXT` | 1 | `` | 0 |
| 5 | `section_type` | `TEXT` | 0 | `` | 0 |
| 6 | `liquid_source` | `TEXT` | 0 | `` | 0 |
| 7 | `schema_json` | `TEXT` | 0 | `'{}'` | 0 |
| 8 | `settings_map_json` | `TEXT` | 0 | `'{}'` | 0 |
| 9 | `render_deps` | `TEXT` | 0 | `'[]'` | 0 |
| 10 | `mapped_template_id` | `TEXT` | 0 | `` | 0 |
| 11 | `mapped_section_id` | `TEXT` | 0 | `` | 0 |
| 12 | `parse_status` | `TEXT` | 1 | `'pending'` | 0 |
| 13 | `parse_error` | `TEXT` | 0 | `` | 0 |
| 14 | `created_at` | `INTEGER` | 0 | `unixepoch()` | 0 |

```sql
CREATE TABLE cms_liquid_sections (
  id                  TEXT PRIMARY KEY DEFAULT ('lsec_' || lower(hex(randomblob(8)))),
  import_id           TEXT NOT NULL REFERENCES cms_liquid_imports(id) ON DELETE CASCADE,
  tenant_id           TEXT NOT NULL,
  file_name           TEXT NOT NULL,
  section_key         TEXT NOT NULL,
  section_type        TEXT,
  liquid_source       TEXT,
  schema_json         TEXT DEFAULT '{}',
  settings_map_json   TEXT DEFAULT '{}',
  render_deps         TEXT DEFAULT '[]',
  mapped_template_id  TEXT REFERENCES cms_component_templates(id) ON DELETE SET NULL,
  mapped_section_id   TEXT REFERENCES cms_page_sections(id) ON DELETE SET NULL,
  parse_status        TEXT NOT NULL DEFAULT 'pending'
                      CHECK(parse_status IN ('pending','parsed','mapped','registered','failed')),
  parse_error         TEXT,
  created_at          INTEGER DEFAULT (unixepoch())
);
```

---

## cms_live_edit_sessions

Rows: `0`
Columns: `7`
Capture latency: `4955ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `page_id` | `TEXT` | 1 | `` | 0 |
| 2 | `user_id` | `TEXT` | 1 | `` | 0 |
| 3 | `session_token` | `TEXT` | 1 | `` | 0 |
| 4 | `is_active` | `INTEGER` | 0 | `1` | 0 |
| 5 | `last_activity` | `TEXT` | 0 | `datetime('now')` | 0 |
| 6 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_live_edit_sessions (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  page_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  session_token TEXT NOT NULL UNIQUE,
  is_active INTEGER DEFAULT 1,
  last_activity TEXT DEFAULT (datetime('now')),
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (page_id) REFERENCES cms_site_pages(id) ON DELETE CASCADE
);
```

---

## cms_live_rollbacks

Rows: `0`
Columns: `8`
Capture latency: `4247ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `page_id` | `TEXT` | 1 | `` | 0 |
| 2 | `project_id` | `TEXT` | 1 | `` | 0 |
| 3 | `slug` | `TEXT` | 1 | `` | 0 |
| 4 | `previous_html` | `TEXT` | 0 | `` | 0 |
| 5 | `previous_r2_key` | `TEXT` | 0 | `` | 0 |
| 6 | `deployed_html_hash` | `TEXT` | 0 | `` | 0 |
| 7 | `created_at` | `INTEGER` | 1 | `` | 0 |

```sql
CREATE TABLE cms_live_rollbacks (
  id TEXT PRIMARY KEY,
  page_id TEXT NOT NULL,
  project_id TEXT NOT NULL,
  slug TEXT NOT NULL,
  previous_html TEXT,
  previous_r2_key TEXT,
  deployed_html_hash TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (page_id) REFERENCES "cms_pages_backup_20260428"(id)
);
```

---

## cms_navigation_menus

Rows: `3`
Columns: `14`
Capture latency: `3916ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `project_id` | `TEXT` | 1 | `` | 0 |
| 2 | `project_slug` | `TEXT` | 0 | `` | 0 |
| 3 | `tenant_id` | `TEXT` | 0 | `` | 0 |
| 4 | `menu_name` | `TEXT` | 1 | `` | 0 |
| 5 | `menu_type` | `TEXT` | 0 | `'site'` | 0 |
| 6 | `menu_items` | `TEXT` | 1 | `` | 0 |
| 7 | `is_active` | `INTEGER` | 0 | `1` | 0 |
| 8 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 9 | `r2_key` | `TEXT` | 0 | `` | 0 |
| 10 | `r2_url` | `TEXT` | 0 | `` | 0 |
| 11 | `s3_endpoint` | `TEXT` | 0 | `` | 0 |
| 12 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 13 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_navigation_menus (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),

  project_id TEXT NOT NULL,
  project_slug TEXT,
  tenant_id TEXT,

  menu_name TEXT NOT NULL,
  menu_type TEXT DEFAULT 'site',
  menu_items TEXT NOT NULL,

  is_active INTEGER DEFAULT 1,

  r2_bucket TEXT,
  r2_key TEXT,
  r2_url TEXT,
  s3_endpoint TEXT,

  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),

  UNIQUE(project_id, menu_name)
);
```

---

## cms_override_versions

Rows: `0`
Columns: `11`
Capture latency: `3828ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(8)))` | 1 |
| 1 | `override_id` | `TEXT` | 1 | `` | 0 |
| 2 | `project_id` | `INTEGER` | 1 | `` | 0 |
| 3 | `project_slug` | `TEXT` | 1 | `` | 0 |
| 4 | `path` | `TEXT` | 1 | `` | 0 |
| 5 | `section` | `TEXT` | 1 | `` | 0 |
| 6 | `overrides_json` | `TEXT` | 1 | `` | 0 |
| 7 | `version` | `INTEGER` | 1 | `` | 0 |
| 8 | `status` | `TEXT` | 1 | `` | 0 |
| 9 | `created_by` | `TEXT` | 0 | `'user-sam-primeaux'` | 0 |
| 10 | `created_at` | `TEXT` | 1 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_override_versions (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
  override_id TEXT NOT NULL,             
  project_id INTEGER NOT NULL,
  project_slug TEXT NOT NULL,
  path TEXT NOT NULL,
  section TEXT NOT NULL,
  overrides_json TEXT NOT NULL,
  version INTEGER NOT NULL,
  status TEXT NOT NULL,
  created_by TEXT DEFAULT 'user-sam-primeaux',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (override_id) REFERENCES cms_page_overrides(id) ON DELETE CASCADE
);
```

---

## cms_page_drafts

Rows: `0`
Columns: `6`
Capture latency: `4016ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `page_id` | `TEXT` | 1 | `` | 0 |
| 2 | `user_id` | `TEXT` | 1 | `` | 0 |
| 3 | `draft_data` | `TEXT` | 1 | `` | 0 |
| 4 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 5 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_page_drafts (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  page_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  draft_data TEXT NOT NULL, 
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  UNIQUE(page_id, user_id)
);
```

---

## cms_page_overrides

Rows: `0`
Columns: `13`
Capture latency: `3673ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(8)))` | 1 |
| 1 | `project_id` | `INTEGER` | 1 | `` | 0 |
| 2 | `project_slug` | `TEXT` | 1 | `` | 0 |
| 3 | `path` | `TEXT` | 1 | `` | 0 |
| 4 | `section` | `TEXT` | 1 | `'hero'` | 0 |
| 5 | `overrides_json` | `TEXT` | 1 | `'{}'` | 0 |
| 6 | `status` | `TEXT` | 1 | `'draft'` | 0 |
| 7 | `version` | `INTEGER` | 1 | `1` | 0 |
| 8 | `published_at` | `TEXT` | 0 | `` | 0 |
| 9 | `published_by` | `TEXT` | 0 | `` | 0 |
| 10 | `created_by` | `TEXT` | 0 | `'user-sam-primeaux'` | 0 |
| 11 | `created_at` | `TEXT` | 1 | `datetime('now')` | 0 |
| 12 | `updated_at` | `TEXT` | 1 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_page_overrides (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
  project_id INTEGER NOT NULL,           
  project_slug TEXT NOT NULL,            
  path TEXT NOT NULL,                    
  section TEXT NOT NULL DEFAULT 'hero',  
  overrides_json TEXT NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','published','archived')),
  version INTEGER NOT NULL DEFAULT 1,
  published_at TEXT,
  published_by TEXT,
  created_by TEXT DEFAULT 'user-sam-primeaux',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(project_id, path, section)
);
```

---

## cms_page_sections

Rows: `46`
Columns: `13`
Capture latency: `3628ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `page_id` | `TEXT` | 1 | `` | 0 |
| 2 | `section_type` | `TEXT` | 1 | `` | 0 |
| 3 | `section_name` | `TEXT` | 1 | `` | 0 |
| 4 | `section_data` | `TEXT` | 1 | `'{}'` | 0 |
| 5 | `sort_order` | `INTEGER` | 0 | `0` | 0 |
| 6 | `is_visible` | `INTEGER` | 0 | `1` | 0 |
| 7 | `css_classes` | `TEXT` | 0 | `` | 0 |
| 8 | `custom_css` | `TEXT` | 0 | `` | 0 |
| 9 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 10 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 11 | `liquid_section_id` | `TEXT` | 0 | `` | 0 |
| 12 | `shopify_section_key` | `TEXT` | 0 | `NULL` | 0 |

```sql
CREATE TABLE cms_page_sections (
  id TEXT PRIMARY KEY,
  page_id TEXT NOT NULL,
  section_type TEXT NOT NULL,
  section_name TEXT NOT NULL,
  section_data TEXT NOT NULL DEFAULT '{}',
  sort_order INTEGER DEFAULT 0,
  is_visible INTEGER DEFAULT 1,
  css_classes TEXT,
  custom_css TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')), liquid_section_id TEXT REFERENCES cms_liquid_sections(id) ON DELETE SET NULL, shopify_section_key TEXT DEFAULT NULL,
  FOREIGN KEY (page_id)
    REFERENCES cms_pages(id)
    ON DELETE CASCADE
);
```

---

## cms_pages

Rows: `17`
Columns: `40`
Capture latency: `3541ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `project_id` | `TEXT` | 1 | `` | 0 |
| 2 | `project_slug` | `TEXT` | 1 | `` | 0 |
| 3 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 4 | `workspace_id` | `TEXT` | 0 | `` | 0 |
| 5 | `worker_id` | `TEXT` | 0 | `` | 0 |
| 6 | `person_uuid` | `TEXT` | 0 | `` | 0 |
| 7 | `slug` | `TEXT` | 1 | `` | 0 |
| 8 | `path` | `TEXT` | 1 | `` | 0 |
| 9 | `route_path` | `TEXT` | 1 | `` | 0 |
| 10 | `page_type` | `TEXT` | 1 | `` | 0 |
| 11 | `title` | `TEXT` | 1 | `` | 0 |
| 12 | `meta_description` | `TEXT` | 0 | `` | 0 |
| 13 | `description` | `TEXT` | 0 | `` | 0 |
| 14 | `status` | `TEXT` | 1 | `'draft'` | 0 |
| 15 | `seo_title` | `TEXT` | 0 | `` | 0 |
| 16 | `canonical_url` | `TEXT` | 0 | `` | 0 |
| 17 | `robots` | `TEXT` | 0 | `'index,follow'` | 0 |
| 18 | `og_image_asset_id` | `TEXT` | 0 | `` | 0 |
| 19 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 20 | `r2_key` | `TEXT` | 0 | `` | 0 |
| 21 | `r2_url` | `TEXT` | 0 | `` | 0 |
| 22 | `content_type` | `TEXT` | 0 | `'text/html'` | 0 |
| 23 | `content_size_bytes` | `INTEGER` | 0 | `0` | 0 |
| 24 | `config_json` | `TEXT` | 0 | `'{}'` | 0 |
| 25 | `seo_json` | `TEXT` | 0 | `'{}'` | 0 |
| 26 | `analytics_json` | `TEXT` | 0 | `'{}'` | 0 |
| 27 | `metadata_json` | `TEXT` | 0 | `'{}'` | 0 |
| 28 | `is_homepage` | `INTEGER` | 0 | `0` | 0 |
| 29 | `is_system_page` | `INTEGER` | 0 | `0` | 0 |
| 30 | `requires_auth` | `INTEGER` | 0 | `0` | 0 |
| 31 | `is_active` | `INTEGER` | 0 | `1` | 0 |
| 32 | `sort_order` | `INTEGER` | 0 | `0` | 0 |
| 33 | `created_by` | `TEXT` | 0 | `` | 0 |
| 34 | `updated_by` | `TEXT` | 0 | `` | 0 |
| 35 | `published_by` | `TEXT` | 0 | `` | 0 |
| 36 | `created_at` | `INTEGER` | 1 | `` | 0 |
| 37 | `updated_at` | `INTEGER` | 1 | `` | 0 |
| 38 | `published_at` | `INTEGER` | 0 | `` | 0 |
| 39 | `archived_at` | `INTEGER` | 0 | `` | 0 |

```sql
CREATE TABLE cms_pages (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  project_slug TEXT NOT NULL,
  tenant_id TEXT NOT NULL,
  workspace_id TEXT,
  worker_id TEXT,
  person_uuid TEXT,

  slug TEXT NOT NULL,
  path TEXT NOT NULL,
  route_path TEXT NOT NULL,
  page_type TEXT NOT NULL CHECK (page_type IN (
    'home','about','services','work','case_study','contact','pricing',
    'privacy','terms','faq','product','collection','blog','post',
    'landing','portal','dashboard','auth','sitemap','custom'
  )),

  title TEXT NOT NULL,
  meta_description TEXT,
  description TEXT,

  status TEXT NOT NULL DEFAULT 'draft'
    CHECK(status IN ('draft','published','archived','scheduled')),

  seo_title TEXT,
  canonical_url TEXT,
  robots TEXT DEFAULT 'index,follow',
  og_image_asset_id TEXT,

  r2_bucket TEXT,
  r2_key TEXT,
  r2_url TEXT,
  content_type TEXT DEFAULT 'text/html',
  content_size_bytes INTEGER DEFAULT 0,

  config_json TEXT DEFAULT '{}',
  seo_json TEXT DEFAULT '{}',
  analytics_json TEXT DEFAULT '{}',
  metadata_json TEXT DEFAULT '{}',

  is_homepage INTEGER DEFAULT 0,
  is_system_page INTEGER DEFAULT 0,
  requires_auth INTEGER DEFAULT 0,
  is_active INTEGER DEFAULT 1,
  sort_order INTEGER DEFAULT 0,

  created_by TEXT,
  updated_by TEXT,
  published_by TEXT,

  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  published_at INTEGER,
  archived_at INTEGER,

  UNIQUE(project_id, slug),
  UNIQUE(project_id, route_path)
);
```

---

## cms_section_components

Rows: `93`
Columns: `10`
Capture latency: `3977ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(16)))` | 1 |
| 1 | `section_id` | `TEXT` | 1 | `` | 0 |
| 2 | `component_type` | `TEXT` | 1 | `` | 0 |
| 3 | `component_data` | `TEXT` | 1 | `'{}'` | 0 |
| 4 | `sort_order` | `INTEGER` | 0 | `0` | 0 |
| 5 | `is_visible` | `INTEGER` | 0 | `1` | 0 |
| 6 | `tenant_id` | `TEXT` | 0 | `` | 0 |
| 7 | `project_id` | `TEXT` | 0 | `` | 0 |
| 8 | `created_at` | `TEXT` | 0 | `datetime('now')` | 0 |
| 9 | `updated_at` | `TEXT` | 0 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_section_components (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  section_id TEXT NOT NULL,
  component_type TEXT NOT NULL,
  component_data TEXT NOT NULL DEFAULT '{}',
  sort_order INTEGER DEFAULT 0,
  is_visible INTEGER DEFAULT 1,
  tenant_id TEXT,
  project_id TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (section_id) REFERENCES cms_page_sections(id) ON DELETE CASCADE
);
```

---

## cms_site_pages

Rows: `49`
Columns: `25`
Capture latency: `3837ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `lower(hex(randomblob(8)))` | 1 |
| 1 | `project_id` | `INTEGER` | 1 | `` | 0 |
| 2 | `project_slug` | `TEXT` | 1 | `` | 0 |
| 3 | `path` | `TEXT` | 1 | `` | 0 |
| 4 | `title` | `TEXT` | 1 | `` | 0 |
| 5 | `description` | `TEXT` | 0 | `` | 0 |
| 6 | `is_active` | `INTEGER` | 0 | `1` | 0 |
| 7 | `sort_order` | `INTEGER` | 0 | `0` | 0 |
| 8 | `page_type` | `TEXT` | 0 | `'page'` | 0 |
| 9 | `created_at` | `TEXT` | 1 | `datetime('now')` | 0 |
| 10 | `updated_at` | `TEXT` | 1 | `datetime('now')` | 0 |
| 11 | `tenant_id` | `TEXT` | 0 | `` | 0 |
| 12 | `workspace_id` | `TEXT` | 0 | `` | 0 |
| 13 | `worker_id` | `TEXT` | 0 | `` | 0 |
| 14 | `person_uuid` | `TEXT` | 0 | `` | 0 |
| 15 | `seo_title` | `TEXT` | 0 | `` | 0 |
| 16 | `canonical_url` | `TEXT` | 0 | `` | 0 |
| 17 | `robots` | `TEXT` | 0 | `'index,follow'` | 0 |
| 18 | `r2_bucket` | `TEXT` | 0 | `` | 0 |
| 19 | `r2_key` | `TEXT` | 0 | `` | 0 |
| 20 | `r2_url` | `TEXT` | 0 | `` | 0 |
| 21 | `content_type` | `TEXT` | 0 | `'text/html'` | 0 |
| 22 | `status` | `TEXT` | 0 | `'draft'` | 0 |
| 23 | `published_at` | `TEXT` | 0 | `` | 0 |
| 24 | `metadata_json` | `TEXT` | 0 | `'{}'` | 0 |

```sql
CREATE TABLE cms_site_pages (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
  project_id INTEGER NOT NULL,
  project_slug TEXT NOT NULL,
  path TEXT NOT NULL,                    
  title TEXT NOT NULL,
  description TEXT,
  is_active INTEGER DEFAULT 1,
  sort_order INTEGER DEFAULT 0,
  page_type TEXT DEFAULT 'page'
    CHECK (page_type IN ('page','post','product','landing','custom')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')), tenant_id TEXT, workspace_id TEXT, worker_id TEXT, person_uuid TEXT, seo_title TEXT, canonical_url TEXT, robots TEXT DEFAULT 'index,follow', r2_bucket TEXT, r2_key TEXT, r2_url TEXT, content_type TEXT DEFAULT 'text/html', status TEXT DEFAULT 'draft', published_at TEXT, metadata_json TEXT DEFAULT '{}',
  UNIQUE(project_id, path)
);
```

---

## cms_tenants

Rows: `12`
Columns: `13`
Capture latency: `3420ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `name` | `TEXT` | 1 | `` | 0 |
| 2 | `slug` | `TEXT` | 1 | `` | 0 |
| 3 | `logo_url` | `TEXT` | 0 | `` | 0 |
| 4 | `primary_color` | `TEXT` | 0 | `'#1a73e8'` | 0 |
| 5 | `secondary_color` | `TEXT` | 0 | `'#174ea6'` | 0 |
| 6 | `theme` | `TEXT` | 0 | `'light'` | 0 |
| 7 | `created_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 8 | `updated_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 9 | `domain` | `TEXT` | 0 | `` | 0 |
| 10 | `settings` | `TEXT` | 0 | `` | 0 |
| 11 | `is_active` | `INTEGER` | 0 | `1` | 0 |
| 12 | `tenant_ref_id` | `TEXT` | 0 | `` | 0 |

```sql
CREATE TABLE cms_tenants (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    logo_url TEXT,
    primary_color TEXT DEFAULT '#1a73e8',
    secondary_color TEXT DEFAULT '#174ea6',
    theme TEXT DEFAULT 'light',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
, domain TEXT, settings TEXT, is_active INTEGER DEFAULT 1, tenant_ref_id TEXT REFERENCES tenants(id) ON DELETE SET NULL);
```

---

## cms_theme_preferences

Rows: `4`
Columns: `12`
Capture latency: `3616ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `'default'` | 0 |
| 2 | `user_id` | `TEXT` | 0 | `NULL` | 0 |
| 3 | `workspace_id` | `TEXT` | 0 | `NULL` | 0 |
| 4 | `project_id` | `TEXT` | 0 | `NULL` | 0 |
| 5 | `page_id` | `TEXT` | 0 | `NULL` | 0 |
| 6 | `theme_id` | `TEXT` | 1 | `` | 0 |
| 7 | `theme_slug` | `TEXT` | 1 | `` | 0 |
| 8 | `scope` | `TEXT` | 1 | `'workspace'` | 0 |
| 9 | `is_active` | `INTEGER` | 1 | `1` | 0 |
| 10 | `created_at` | `TEXT` | 1 | `datetime('now')` | 0 |
| 11 | `updated_at` | `TEXT` | 1 | `datetime('now')` | 0 |

```sql
CREATE TABLE cms_theme_preferences (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL DEFAULT 'default',
  user_id TEXT DEFAULT NULL,
  workspace_id TEXT DEFAULT NULL,
  project_id TEXT DEFAULT NULL,
  page_id TEXT DEFAULT NULL,
  theme_id TEXT NOT NULL,
  theme_slug TEXT NOT NULL,
  scope TEXT NOT NULL DEFAULT 'workspace'
    CHECK (scope IN ('user_global','tenant','workspace','project','page')),
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(tenant_id, user_id, workspace_id, project_id, page_id, scope)
);
```

---

## cms_themes

Rows: `108`
Columns: `31`
Capture latency: `3453ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 0 | `` | 0 |
| 2 | `name` | `TEXT` | 1 | `` | 0 |
| 3 | `slug` | `TEXT` | 1 | `` | 0 |
| 4 | `css_url` | `TEXT` | 0 | `` | 0 |
| 5 | `config` | `TEXT` | 1 | `` | 0 |
| 6 | `is_system` | `BOOLEAN` | 0 | `0` | 0 |
| 7 | `created_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 8 | `wcag_scores` | `TEXT` | 0 | `` | 0 |
| 9 | `contrast_flags` | `TEXT` | 0 | `` | 0 |
| 10 | `theme_family` | `TEXT` | 0 | `'custom'` | 0 |
| 11 | `sort_order` | `INTEGER` | 0 | `100` | 0 |
| 12 | `workspace_id` | `TEXT` | 0 | `NULL` | 0 |
| 13 | `monaco_theme` | `TEXT` | 1 | `'vs-dark'` | 0 |
| 14 | `monaco_bg` | `TEXT` | 1 | `'#1e293b'` | 0 |
| 15 | `monaco_theme_data` | `TEXT` | 0 | `` | 0 |
| 16 | `tokens_json` | `TEXT` | 1 | `'{}'` | 0 |
| 17 | `css_vars_json` | `TEXT` | 1 | `'{}'` | 0 |
| 18 | `brand_json` | `TEXT` | 1 | `'{}'` | 0 |
| 19 | `layout_json` | `TEXT` | 1 | `'{}'` | 0 |
| 20 | `typography_json` | `TEXT` | 1 | `'{}'` | 0 |
| 21 | `components_json` | `TEXT` | 1 | `'{}'` | 0 |
| 22 | `motion_json` | `TEXT` | 1 | `'{}'` | 0 |
| 23 | `css_r2_key` | `TEXT` | 0 | `NULL` | 0 |
| 24 | `compiled_css_hash` | `TEXT` | 0 | `NULL` | 0 |
| 25 | `preview_image_url` | `TEXT` | 0 | `NULL` | 0 |
| 26 | `status` | `TEXT` | 1 | `'active'` | 0 |
| 27 | `updated_at` | `TEXT` | 0 | `NULL` | 0 |
| 28 | `visibility` | `TEXT` | 1 | `'public'` | 0 |
| 29 | `alias_of_theme_id` | `TEXT` | 0 | `NULL` | 0 |
| 30 | `css_r2_bucket` | `TEXT` | 0 | `NULL` | 0 |

```sql
CREATE TABLE cms_themes (
    id TEXT PRIMARY KEY,
    tenant_id TEXT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    css_url TEXT,
    config TEXT NOT NULL,
    is_system BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, wcag_scores TEXT, contrast_flags TEXT, theme_family TEXT DEFAULT 'custom', sort_order INTEGER DEFAULT 100, workspace_id TEXT DEFAULT NULL, monaco_theme TEXT NOT NULL DEFAULT 'vs-dark', monaco_bg TEXT NOT NULL DEFAULT '#1e293b', monaco_theme_data TEXT, tokens_json TEXT NOT NULL DEFAULT '{}', css_vars_json TEXT NOT NULL DEFAULT '{}', brand_json TEXT NOT NULL DEFAULT '{}', layout_json TEXT NOT NULL DEFAULT '{}', typography_json TEXT NOT NULL DEFAULT '{}', components_json TEXT NOT NULL DEFAULT '{}', motion_json TEXT NOT NULL DEFAULT '{}', css_r2_key TEXT DEFAULT NULL, compiled_css_hash TEXT DEFAULT NULL, preview_image_url TEXT DEFAULT NULL, status TEXT NOT NULL DEFAULT 'active', updated_at TEXT DEFAULT NULL, visibility TEXT NOT NULL DEFAULT 'public', alias_of_theme_id TEXT DEFAULT NULL, css_r2_bucket TEXT DEFAULT NULL,
    UNIQUE(tenant_id, slug)
);
```

---

## cms_video_projects

Rows: `3`
Columns: `10`
Capture latency: `4064ms`

| cid | name | type | notnull | default | pk |
|---:|---|---|---:|---|---:|
| 0 | `id` | `TEXT` | 0 | `` | 1 |
| 1 | `tenant_id` | `TEXT` | 1 | `` | 0 |
| 2 | `name` | `TEXT` | 1 | `` | 0 |
| 3 | `description` | `TEXT` | 0 | `` | 0 |
| 4 | `assets` | `TEXT` | 0 | `` | 0 |
| 5 | `timeline_data` | `TEXT` | 0 | `` | 0 |
| 6 | `thumbnail_url` | `TEXT` | 0 | `` | 0 |
| 7 | `status` | `TEXT` | 0 | `'draft'` | 0 |
| 8 | `created_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |
| 9 | `updated_at` | `DATETIME` | 0 | `CURRENT_TIMESTAMP` | 0 |

```sql
CREATE TABLE cms_video_projects (
    id TEXT PRIMARY KEY,
    tenant_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    assets TEXT,
    timeline_data TEXT,
    thumbnail_url TEXT,
    status TEXT DEFAULT 'draft',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES cms_tenants(id)
);
```

---
