-- CMS Table DDL Dump
-- Captured: 2026-05-09T21:19:36.573309+00:00
-- Database: inneranimalmedia-business

-- ------------------------------------------------------------------------
-- cms_3d_assets
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_activity_log
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_assets
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_collection_assets
-- ------------------------------------------------------------------------
CREATE TABLE cms_collection_assets (
    collection_id TEXT NOT NULL,
    asset_id TEXT NOT NULL,
    order_index INTEGER DEFAULT 0,
    added_at INTEGER NOT NULL,
    PRIMARY KEY (collection_id, asset_id),
    FOREIGN KEY (collection_id) REFERENCES cms_collections(id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES cms_assets(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------------------
-- cms_collections
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_component_templates
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_content
-- ------------------------------------------------------------------------
CREATE TABLE cms_content (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ------------------------------------------------------------------------
-- cms_conversion_jobs
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_conversions
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_folders
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_global_settings
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_liquid_imports
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_liquid_sections
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_live_edit_sessions
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_live_rollbacks
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_navigation_menus
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_override_versions
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_page_drafts
-- ------------------------------------------------------------------------
CREATE TABLE cms_page_drafts (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  page_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  draft_data TEXT NOT NULL, 
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),
  UNIQUE(page_id, user_id)
);

-- ------------------------------------------------------------------------
-- cms_page_overrides
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_page_sections
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_pages
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_section_components
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_site_pages
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_tenants
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_theme_preferences
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_themes
-- ------------------------------------------------------------------------
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

-- ------------------------------------------------------------------------
-- cms_video_projects
-- ------------------------------------------------------------------------
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
