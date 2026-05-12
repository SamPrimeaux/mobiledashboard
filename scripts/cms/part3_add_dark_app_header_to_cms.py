#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

CMS_HTML = ROOT / "public" / "cms" / "cms-editor-index.html"
CMS_GENERATED_JS = ROOT / "src" / "generated" / "cms-editor-html.js"

LOGO_URL = "https://imagedelivery.net/g7wf09fCONpnidkRnR_5vw/ac515729-af6b-4ea5-8b10-e581a4d02100/thumbnail"

START = "<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_START -->"
END = "<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_END -->"

OLD_GLOBAL_START = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_START -->"
OLD_GLOBAL_END = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_END -->"

CSS = """
:root {
  --agent-cms-header-height: 48px;
  --agent-cms-header-bg: #0b0b0c;
  --agent-cms-header-border: rgba(255,255,255,.10);
  --agent-cms-header-text: rgba(255,255,255,.92);
  --agent-cms-header-muted: rgba(255,255,255,.52);
}

body.agent-cms-has-dark-header {
  margin: 0;
  overflow: hidden;
}

body.agent-cms-has-dark-header .cms-editor {
  height: calc(100vh - var(--agent-cms-header-height)) !important;
  min-height: calc(100vh - var(--agent-cms-header-height)) !important;
}

.agent-cms-dark-header {
  height: var(--agent-cms-header-height);
  display: grid;
  grid-template-columns: minmax(160px, 1fr) auto minmax(160px, 1fr);
  align-items: center;
  gap: 16px;
  padding: 0 16px;
  background: var(--agent-cms-header-bg);
  color: var(--agent-cms-header-text);
  border-bottom: 1px solid var(--agent-cms-header-border);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  position: relative;
  z-index: 10000;
}

.agent-cms-dark-header * {
  box-sizing: border-box;
}

.agent-cms-dark-header__brand {
  display: inline-flex;
  align-items: center;
  justify-self: start;
  gap: 10px;
  color: inherit;
  text-decoration: none;
  min-width: 0;
}

.agent-cms-dark-header__mark {
  width: 24px;
  height: 24px;
  border-radius: 8px;
  display: inline-grid;
  place-items: center;
  background: rgba(255,255,255,.04);
  border: 1px solid rgba(255,255,255,.08);
  overflow: hidden;
}

.agent-cms-dark-header__mark img {
  width: 18px;
  height: 18px;
  object-fit: contain;
  display: block;
}

.agent-cms-dark-header__brand-text {
  display: none;
  color: var(--agent-cms-header-muted);
  font-size: 12px;
  font-weight: 650;
  white-space: nowrap;
}

.agent-cms-dark-header__nav {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 18px;
  min-width: 0;
}

.agent-cms-dark-header__link {
  appearance: none;
  border: 0;
  background: transparent;
  color: var(--agent-cms-header-muted);
  text-decoration: none;
  font-size: 13px;
  line-height: 1;
  font-weight: 650;
  padding: 4px 0;
  cursor: pointer;
  white-space: nowrap;
}

.agent-cms-dark-header__link:hover {
  color: var(--agent-cms-header-text);
}

.agent-cms-dark-header__link[data-active="true"] {
  color: #fff;
  font-weight: 800;
}

.agent-cms-dark-header__right {
  justify-self: end;
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.agent-cms-dark-header__avatar {
  width: 28px;
  height: 28px;
  display: inline-grid;
  place-items: center;
  border-radius: 999px;
  color: rgba(255,255,255,.78);
  background: rgba(255,255,255,.08);
  font-size: 11px;
  font-weight: 750;
  text-decoration: none;
}

@media (min-width: 900px) {
  .agent-cms-dark-header__brand-text {
    display: inline-flex;
  }
}

@media (max-width: 680px) {
  .agent-cms-dark-header {
    grid-template-columns: auto 1fr auto;
    padding: 0 12px;
    gap: 10px;
  }

  .agent-cms-dark-header__nav {
    justify-content: flex-start;
    gap: 12px;
    overflow-x: auto;
    scrollbar-width: none;
  }

  .agent-cms-dark-header__nav::-webkit-scrollbar {
    display: none;
  }

  .agent-cms-dark-header__link {
    font-size: 12px;
  }
}
""".strip()

HEADER_HTML_TEMPLATE = """
{start}
<style>
{css}
</style>

<header class="agent-cms-dark-header" data-agent-cms-header="true">
  <a class="agent-cms-dark-header__brand" href="/" aria-label="Agent Meauxbility home">
    <span class="agent-cms-dark-header__mark">
      <img src="{logo_url}" alt="Meauxbility">
    </span>
    <span class="agent-cms-dark-header__brand-text">Agent Meauxbility</span>
  </a>

  <nav class="agent-cms-dark-header__nav" aria-label="Primary navigation">
    <a class="agent-cms-dark-header__link" href="/">Agents</a>
    <a class="agent-cms-dark-header__link" href="/automations">Automations</a>
    <a class="agent-cms-dark-header__link" href="/dashboard">Dashboard</a>
    <a class="agent-cms-dark-header__link" href="/cms" data-active="true">CMS</a>
  </nav>

  <div class="agent-cms-dark-header__right">
    <a class="agent-cms-dark-header__avatar" href="/dashboard" aria-label="Dashboard profile">sp</a>
  </div>
</header>

<script>
  document.body.classList.add('agent-cms-has-dark-header');
</script>
{end}
""".strip()


def header_block() -> str:
    return HEADER_HTML_TEMPLATE.format(start=START, end=END, css=CSS, logo_url=LOGO_URL)


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def backup(path: Path) -> None:
    if path.exists():
        dst = path.with_suffix(path.suffix + ".backup.cms-dark-header." + stamp())
        shutil.copy2(path, dst)
        print("backup ->", dst)


def strip_block(text: str, start: str, end: str) -> str:
    return re.sub(re.escape(start) + r".*?" + re.escape(end), "", text, flags=re.S)


def inject_after_body_open(html: str) -> str:
    html = strip_block(html, START, END)
    html = strip_block(html, OLD_GLOBAL_START, OLD_GLOBAL_END)

    match = re.search(r"<body[^>]*>", html, flags=re.I)
    if not match:
        raise SystemExit("Could not find <body> in CMS HTML.")

    return html[:match.end()] + "\n" + header_block() + "\n" + html[match.end():]


def patch_cms_html() -> None:
    if not CMS_HTML.exists():
        raise SystemExit(f"Missing CMS HTML: {CMS_HTML}")

    backup(CMS_HTML)
    original = CMS_HTML.read_text(errors="replace")
    updated = inject_after_body_open(original)
    CMS_HTML.write_text(updated)
    print("patched ->", CMS_HTML)


def regenerate_cms_module() -> None:
    CMS_GENERATED_JS.parent.mkdir(parents=True, exist_ok=True)
    html = CMS_HTML.read_text(errors="replace")
    CMS_GENERATED_JS.write_text(
        "// Generated by scripts/cms/part3_add_dark_app_header_to_cms.py\n"
        "// Source: public/cms/cms-editor-index.html\n\n"
        "export const CMS_EDITOR_HTML = " + json.dumps(html) + ";\n"
    )
    print("regenerated ->", CMS_GENERATED_JS)


def main() -> int:
    patch_cms_html()
    regenerate_cms_module()

    print()
    print("Next:")
    print("  npx wrangler deploy --dry-run -c wrangler.json")
    print("  npx wrangler deploy -c wrangler.json")
    print("  open https://agent.meauxbility.workers.dev/cms")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
