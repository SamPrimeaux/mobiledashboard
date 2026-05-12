#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

WORKER = ROOT / "worker.js"
CMS_HTML = ROOT / "public" / "cms" / "cms-editor-index.html"
CMS_GENERATED_JS = ROOT / "src" / "generated" / "cms-editor-html.js"

LOGO_URL = "https://imagedelivery.net/g7wf09fCONpnidkRnR_5vw/ac515729-af6b-4ea5-8b10-e581a4d02100/thumbnail"

THEME_LINK = '<link rel="stylesheet" href="/api/cms/theme.css?slug=iam-tide-dark" data-cms-theme-runtime="true">'
THEME_ROUTE_START = "// AGENT_MEAUXBILITY_THEME_CSS_ROUTE_START"
THEME_ROUTE_END = "// AGENT_MEAUXBILITY_THEME_CSS_ROUTE_END"
THEME_HELPER_START = "// AGENT_MEAUXBILITY_THEME_CSS_HELPER_START"
THEME_HELPER_END = "// AGENT_MEAUXBILITY_THEME_CSS_HELPER_END"

CMS_HEADER_START = "<!-- AGENT_MEAUXBILITY_CMS_MAIN_HEADER_START -->"
CMS_HEADER_END = "<!-- AGENT_MEAUXBILITY_CMS_MAIN_HEADER_END -->"

OLD_CMS_DARK_START = "<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_START -->"
OLD_CMS_DARK_END = "<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_END -->"
OLD_GLOBAL_START = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_START -->"
OLD_GLOBAL_END = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_END -->"

CMS_HEADER_BLOCK = f"""
{CMS_HEADER_START}
<style data-cms-main-header-compat="true">
  :root {{
    --app-bg: #0b0b0c;
    --surface-hover: rgba(255,255,255,.08);
    --border: rgba(255,255,255,.10);
    --text-primary: rgba(255,255,255,.92);
    --text-muted: rgba(255,255,255,.52);
    --cms-main-header-height: 48px;
  }}

  body.cms-main-header-mounted {{
    margin: 0;
    overflow: hidden;
  }}

  body.cms-main-header-mounted .cms-editor {{
    height: calc(100vh - var(--cms-main-header-height)) !important;
    min-height: calc(100vh - var(--cms-main-header-height)) !important;
  }}

  #main-header {{
    height: var(--cms-main-header-height);
    color: var(--text-primary);
    font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  }}

  #main-header.bg-app {{
    background: var(--app-bg) !important;
  }}

  #main-header.border-border {{
    border-color: var(--border) !important;
  }}

  #main-header .nav-btn {{
    appearance: none;
    border: 0;
    background: transparent;
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 650;
    line-height: 1;
    padding: 4px 0;
    cursor: pointer;
    white-space: nowrap;
  }}

  #main-header .nav-btn:hover {{
    color: var(--text-primary);
  }}

  #main-header .nav-btn.active-nav {{
    color: #fff;
    font-weight: 800;
  }}

  #main-header .bg-surfaceHover {{
    background: var(--surface-hover) !important;
  }}

  #main-header .border-border {{
    border-color: var(--border) !important;
  }}

  #main-header .w-6 {{ width: 1.5rem; }}
  #main-header .h-6 {{ height: 1.5rem; }}
  #main-header .w-7 {{ width: 1.75rem; }}
  #main-header .h-7 {{ height: 1.75rem; }}
  #main-header .rounded {{ border-radius: .25rem; }}
  #main-header .rounded-full {{ border-radius: 9999px; }}
  #main-header .object-cover {{ object-fit: cover; }}
  #main-header .grid {{ display: grid; }}
  #main-header .grid-cols-3 {{ grid-template-columns: repeat(3, minmax(0, 1fr)); }}
  #main-header .items-center {{ align-items: center; }}
  #main-header .justify-center {{ justify-content: center; }}
  #main-header .justify-end {{ justify-content: flex-end; }}
  #main-header .flex {{ display: flex; }}
  #main-header .px-4 {{ padding-left: 1rem; padding-right: 1rem; }}
  #main-header .py-3 {{ padding-top: .75rem; padding-bottom: .75rem; }}
  #main-header .border-b {{ border-bottom-width: 1px; border-bottom-style: solid; }}
  #main-header .border {{ border-width: 1px; border-style: solid; }}
  #main-header .shrink-0 {{ flex-shrink: 0; }}
  #main-header .relative {{ position: relative; }}
  #main-header .z-10 {{ z-index: 10; }}
  #main-header .gap-4 {{ gap: 1rem; }}
  #main-header .overflow-x-auto {{ overflow-x: auto; }}
  #main-header .no-scrollbar {{ scrollbar-width: none; }}
  #main-header .no-scrollbar::-webkit-scrollbar {{ display: none; }}
  #main-header .whitespace-nowrap {{ white-space: nowrap; }}
  #main-header .text-xs {{ font-size: .75rem; line-height: 1rem; }}
</style>

<header id="main-header" class="grid grid-cols-3 items-center px-4 py-3 border-b border-border bg-app shrink-0 relative z-10">
  <div class="flex items-center">
    <img src="{LOGO_URL}" alt="Logo" class="w-6 h-6 rounded object-cover">
  </div>
  <nav class="flex items-center justify-center gap-4 overflow-x-auto no-scrollbar whitespace-nowrap">
    <button id="nav-agents"      onclick="location.href='/'"            class="nav-btn">Agents</button>
    <button id="nav-automations" onclick="location.href='/automations'" class="nav-btn">Automations</button>
    <button id="nav-dashboard"   onclick="location.href='/dashboard'"   class="nav-btn">Dashboard</button>
    <button id="nav-cms"         onclick="location.href='/cms'"         class="nav-btn active-nav">CMS</button>
  </nav>
  <div class="flex items-center justify-end">
    <div class="w-7 h-7 rounded-full bg-surfaceHover flex items-center justify-center text-xs border border-border">sp</div>
  </div>
</header>

<script>
  document.body.classList.add('cms-main-header-mounted');
</script>
{CMS_HEADER_END}
""".strip()

THEME_ROUTE_BLOCK = f"""
{THEME_ROUTE_START}
  if (url.pathname === '/api/cms/theme.css') {{
    return handleAgentMeauxbilityThemeCss(request, env);
  }}
{THEME_ROUTE_END}
""".rstrip()

THEME_HELPER = """
// AGENT_MEAUXBILITY_THEME_CSS_HELPER_START
function agentMeauxbilitySafeJson(raw, fallback = {}) {
  if (!raw || typeof raw !== 'string') return fallback;
  try {
    const parsed = JSON.parse(raw);
    return parsed && typeof parsed === 'object' ? parsed : fallback;
  } catch (_) {
    return fallback;
  }
}

function agentMeauxbilityCssVarName(key) {
  const clean = String(key || '')
    .replace(/[A-Z]/g, m => '-' + m.toLowerCase())
    .replace(/[^a-z0-9_-]/gi, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
  return clean.startsWith('--') ? clean : `--${clean}`;
}

function agentMeauxbilityCssVarsFromObject(obj) {
  const lines = [];
  for (const [key, value] of Object.entries(obj || {})) {
    if (value === null || value === undefined) continue;
    if (typeof value === 'object') continue;
    const name = agentMeauxbilityCssVarName(key);
    const val = String(value).replace(/[;{}]/g, '');
    lines.push(`  ${name}: ${val};`);
  }
  return lines.join('\\n');
}

function agentMeauxbilityThemeImport(cssUrl) {
  if (!cssUrl || typeof cssUrl !== 'string') return '';
  const safe = cssUrl.trim();
  if (!safe.startsWith('https://assets.inneranimalmedia.com/')) return '';
  return `@import url("${safe}");\\n\\n`;
}

async function handleAgentMeauxbilityThemeCss(request, env) {
  const url = new URL(request.url);
  const slug = url.searchParams.get('slug') || 'iam-tide-dark';

  let theme = null;
  let warning = '';

  try {
    if (env.DB) {
      theme = await env.DB.prepare(`
        SELECT
          name,
          slug,
          css_url,
          css_vars_json,
          tokens_json,
          brand_json,
          layout_json,
          typography_json,
          components_json,
          motion_json,
          updated_at
        FROM cms_themes
        WHERE slug = ?
          AND status = 'active'
        LIMIT 1
      `).bind(slug).first();
    } else {
      warning = 'missing DB binding';
    }
  } catch (err) {
    warning = err && err.message ? err.message : String(err);
  }

  const cssVars = agentMeauxbilitySafeJson(theme && theme.css_vars_json, {});
  const tokens = agentMeauxbilitySafeJson(theme && theme.tokens_json, {});
  const brand = agentMeauxbilitySafeJson(theme && theme.brand_json, {});
  const layout = agentMeauxbilitySafeJson(theme && theme.layout_json, {});
  const typography = agentMeauxbilitySafeJson(theme && theme.typography_json, {});
  const components = agentMeauxbilitySafeJson(theme && theme.components_json, {});

  const css = `${agentMeauxbilityThemeImport(theme && theme.css_url)}
/*
  Agent Meauxbility runtime CMS theme
  slug: ${theme && theme.slug ? theme.slug : slug}
  name: ${theme && theme.name ? theme.name : 'fallback'}
  updated_at: ${theme && theme.updated_at ? theme.updated_at : 'n/a'}
  warning: ${warning || 'none'}
*/
:root {
  --app-bg: #0b0b0c;
  --surface-hover: rgba(255,255,255,.08);
  --border: rgba(255,255,255,.10);
  --text-primary: rgba(255,255,255,.92);
  --text-muted: rgba(255,255,255,.52);
  --cms-bg: #f6f8fb;
  --cms-panel: #ffffff;
  --cms-canvas-bg: #9aaabc;
  --cms-accent: #4f46e5;
${agentMeauxbilityCssVarsFromObject(cssVars)}
${agentMeauxbilityCssVarsFromObject(tokens)}
${agentMeauxbilityCssVarsFromObject(brand)}
${agentMeauxbilityCssVarsFromObject(layout)}
${agentMeauxbilityCssVarsFromObject(typography)}
${agentMeauxbilityCssVarsFromObject(components)}
}

.bg-app { background: var(--app-bg) !important; }
.bg-surfaceHover { background: var(--surface-hover) !important; }
.border-border { border-color: var(--border) !important; }
.text-muted { color: var(--text-muted) !important; }
.text-primary { color: var(--text-primary) !important; }

#main-header {
  background: var(--app-bg) !important;
  border-color: var(--border) !important;
  color: var(--text-primary) !important;
}

#main-header .nav-btn {
  color: var(--text-muted);
}

#main-header .nav-btn:hover,
#main-header .nav-btn.active-nav {
  color: var(--text-primary);
}

.cms-editor {
  background: var(--cms-bg);
}
`;

  return new Response(css, {
    status: 200,
    headers: {
      'content-type': 'text/css;charset=UTF-8',
      'cache-control': 'no-store'
    }
  });
}
// AGENT_MEAUXBILITY_THEME_CSS_HELPER_END
""".strip()


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def backup(path: Path) -> None:
    if path.exists():
        dst = path.with_suffix(path.suffix + ".backup.unify-header-theme." + stamp())
        shutil.copy2(path, dst)
        print("backup ->", dst)


def strip_between(text: str, start: str, end: str) -> str:
    return re.sub(re.escape(start) + r".*?" + re.escape(end), "", text, flags=re.S)


def ensure_theme_link_in_head(html: str) -> str:
    html = re.sub(r'\s*<link[^>]+data-cms-theme-runtime="true"[^>]*>', "", html)
    match = re.search(r"</head\s*>", html, flags=re.I)
    if not match:
        raise SystemExit("Could not find </head>.")
    return html[:match.start()] + "\n  " + THEME_LINK + "\n" + html[match.start():]


def inject_cms_header(html: str) -> str:
    html = strip_between(html, CMS_HEADER_START, CMS_HEADER_END)
    html = strip_between(html, OLD_CMS_DARK_START, OLD_CMS_DARK_END)
    html = strip_between(html, OLD_GLOBAL_START, OLD_GLOBAL_END)

    html = ensure_theme_link_in_head(html)

    match = re.search(r"<body[^>]*>", html, flags=re.I)
    if not match:
        raise SystemExit("Could not find <body> in CMS HTML.")

    return html[:match.end()] + "\n" + CMS_HEADER_BLOCK + "\n" + html[match.end():]


def patch_cms() -> None:
    if not CMS_HTML.exists():
        raise SystemExit(f"Missing CMS HTML: {CMS_HTML}")

    backup(CMS_HTML)
    CMS_HTML.write_text(inject_cms_header(CMS_HTML.read_text(errors="replace")))
    print("patched ->", CMS_HTML)

    CMS_GENERATED_JS.parent.mkdir(parents=True, exist_ok=True)
    html = CMS_HTML.read_text(errors="replace")
    CMS_GENERATED_JS.write_text(
        "// Generated by scripts/cms/part4_unify_cms_header_and_theme_css.py\n"
        "// Source: public/cms/cms-editor-index.html\n\n"
        "export const CMS_EDITOR_HTML = " + json.dumps(html) + ";\n"
    )
    print("regenerated ->", CMS_GENERATED_JS)


def insert_route_block(worker: str) -> str:
    worker = re.sub(
        re.escape(THEME_ROUTE_START) + r".*?" + re.escape(THEME_ROUTE_END),
        "",
        worker,
        flags=re.S,
    )

    patterns = [
        r"(const\s+url\s*=\s*new\s+URL\s*\(\s*request\.url\s*\)\s*;)",
        r"(let\s+url\s*=\s*new\s+URL\s*\(\s*request\.url\s*\)\s*;)",
        r"(var\s+url\s*=\s*new\s+URL\s*\(\s*request\.url\s*\)\s*;)",
    ]

    for pattern in patterns:
        m = re.search(pattern, worker)
        if m:
            return worker[:m.end()] + "\n" + THEME_ROUTE_BLOCK + worker[m.end():]

    raise SystemExit("Could not find `new URL(request.url)` in worker.js for route insertion.")


def insert_helper(worker: str) -> str:
    worker = re.sub(
        re.escape(THEME_HELPER_START) + r".*?" + re.escape(THEME_HELPER_END),
        "",
        worker,
        flags=re.S,
    )
    return worker.rstrip() + "\n\n" + THEME_HELPER + "\n"


def patch_worker() -> None:
    if not WORKER.exists():
        raise SystemExit("Missing worker.js")

    backup(WORKER)
    worker = WORKER.read_text(errors="replace")
    worker = insert_route_block(worker)
    worker = insert_helper(worker)
    worker = re.sub(r'\s*<link[^>]+data-cms-theme-runtime="true"[^>]*>', "", worker)
    worker = worker.replace("</head>", "  " + THEME_LINK + "\n</head>", 1)

    WORKER.write_text(worker)
    print("patched ->", WORKER)


def main() -> int:
    patch_worker()
    patch_cms()

    print()
    print("Next:")
    print("  npx wrangler deploy --dry-run -c wrangler.json")
    print("  npx wrangler deploy -c wrangler.json")
    print("  open https://agent.meauxbility.workers.dev/")
    print("  open https://agent.meauxbility.workers.dev/cms")
    print("  curl -sS https://agent.meauxbility.workers.dev/api/cms/theme.css?slug=iam-tide-dark | head -60")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
