#!/usr/bin/env python3
"""
part2c_patch_worker_shell_global_header.py

Fix:
  The dark Agent/Automations/Dashboard pages are served from worker.js' inline
  HTML string, not from index.html. That is why the global header showed on /cms
  but not on /, /dashboard, /automations.

This script injects the same inline global header directly into:
  - worker.js inline HTML shell
  - public/cms/cms-editor-index.html, if present
  - src/generated/cms-editor-html.js, regenerated from the CMS snapshot

No external /components assets are required.
No DB mutation.
No R2 write.
No model calls.
"""

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

START = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_START -->"
END = "<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_END -->"

CSS = """
:root {
  --am-header-height: 68px;
  --am-header-bg: rgba(7, 8, 10, 0.82);
  --am-header-panel: rgba(255,255,255,.055);
  --am-header-border: rgba(255,255,255,.11);
  --am-header-text: rgba(255,255,255,.94);
  --am-header-muted: rgba(255,255,255,.58);
  --am-header-accent: #67e8f9;
  --am-header-purple: #7c3aed;
}

html { scroll-padding-top: var(--am-header-height); }

body.agent-meauxbility-global-header-mounted {
  padding-top: var(--am-header-height) !important;
}

.agent-meauxbility-global-header {
  position: fixed;
  inset: 0 0 auto 0;
  height: var(--am-header-height);
  z-index: 2147483000;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--am-header-text);
  border-bottom: 1px solid var(--am-header-border);
  background:
    radial-gradient(circle at 10% 0%, rgba(103,232,249,.16), transparent 34%),
    radial-gradient(circle at 92% 0%, rgba(124,58,237,.18), transparent 32%),
    var(--am-header-bg);
  backdrop-filter: blur(18px) saturate(1.28);
  -webkit-backdrop-filter: blur(18px) saturate(1.28);
  box-shadow: 0 20px 70px rgba(0,0,0,.32);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.agent-meauxbility-global-header * { box-sizing: border-box; }

.agent-meauxbility-global-header__inner {
  width: min(100%, 1480px);
  height: 100%;
  display: grid;
  grid-template-columns: minmax(230px, 1fr) auto minmax(230px, 1fr);
  align-items: center;
  gap: 18px;
  padding: 0 22px;
}

.agent-meauxbility-global-header__brand {
  min-width: 0;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  color: inherit;
  text-decoration: none;
}

.agent-meauxbility-global-header__logo-shell {
  width: 39px;
  height: 39px;
  display: grid;
  place-items: center;
  border-radius: 14px;
  background: rgba(255,255,255,.07);
  border: 1px solid rgba(255,255,255,.12);
  overflow: hidden;
}

.agent-meauxbility-global-header__logo {
  width: 30px;
  height: 30px;
  object-fit: contain;
  display: block;
}

.agent-meauxbility-global-header__brand-copy {
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.02;
}

.agent-meauxbility-global-header__title {
  color: var(--am-header-text);
  font-size: 13px;
  font-weight: 800;
  letter-spacing: -0.015em;
  white-space: nowrap;
}

.agent-meauxbility-global-header__subtitle {
  margin-top: 4px;
  color: var(--am-header-muted);
  font-size: 11px;
  font-weight: 600;
  white-space: nowrap;
}

.agent-meauxbility-global-header__nav-wrap {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.agent-meauxbility-global-header__nav {
  height: 42px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px;
  border-radius: 999px;
  background: var(--am-header-panel);
  border: 1px solid rgba(255,255,255,.10);
}

.agent-meauxbility-global-header__link {
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0 13px;
  border-radius: 999px;
  color: var(--am-header-muted);
  text-decoration: none;
  font-size: 12px;
  font-weight: 720;
  letter-spacing: -0.01em;
  white-space: nowrap;
  transition: 160ms ease;
}

.agent-meauxbility-global-header__link:hover {
  color: var(--am-header-text);
  background: rgba(255,255,255,.09);
}

.agent-meauxbility-global-header__link[data-active="true"] {
  color: #061014;
  background: linear-gradient(135deg, rgba(103,232,249,.98), rgba(167,139,250,.98));
  box-shadow: 0 10px 30px rgba(103,232,249,.13);
}

.agent-meauxbility-global-header__more { position: relative; }

.agent-meauxbility-global-header__more-button {
  height: 42px;
  width: 42px;
  border: 1px solid rgba(255,255,255,.10);
  border-radius: 999px;
  color: var(--am-header-text);
  background: var(--am-header-panel);
  font-weight: 900;
  cursor: pointer;
}

.agent-meauxbility-global-header__menu {
  position: absolute;
  top: 50px;
  right: 0;
  min-width: 220px;
  display: none;
  gap: 6px;
  padding: 9px;
  border-radius: 16px;
  background: rgba(10,11,14,.96);
  border: 1px solid rgba(255,255,255,.13);
  box-shadow: 0 24px 80px rgba(0,0,0,.42);
}

.agent-meauxbility-global-header[data-menu-open="true"] .agent-meauxbility-global-header__menu {
  display: grid;
}

.agent-meauxbility-global-header__menu a {
  color: var(--am-header-text);
  text-decoration: none;
  padding: 10px 11px;
  border-radius: 11px;
  font-size: 12px;
  font-weight: 700;
}

.agent-meauxbility-global-header__menu a:hover { background: rgba(255,255,255,.075); }

.agent-meauxbility-global-header__actions {
  justify-self: end;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.agent-meauxbility-global-header__status {
  height: 32px;
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 0 11px;
  border-radius: 999px;
  color: var(--am-header-muted);
  background: var(--am-header-panel);
  border: 1px solid rgba(255,255,255,.10);
  font-size: 11px;
  font-weight: 720;
}

.agent-meauxbility-global-header__dot {
  width: 7px;
  height: 7px;
  border-radius: 999px;
  background: #34d399;
  box-shadow: 0 0 0 4px rgba(52,211,153,.13);
}

.agent-meauxbility-global-header__cta {
  height: 32px;
  display: inline-flex;
  align-items: center;
  padding: 0 13px;
  border-radius: 999px;
  color: white;
  text-decoration: none;
  font-size: 11px;
  font-weight: 820;
  background: linear-gradient(135deg, rgba(124,58,237,.92), rgba(14,165,233,.72));
  border: 1px solid rgba(255,255,255,.12);
}

.agent-meauxbility-global-header__mobile {
  display: none;
  width: 38px;
  height: 38px;
  border: 1px solid rgba(255,255,255,.11);
  border-radius: 13px;
  color: white;
  background: rgba(255,255,255,.07);
}

.agent-meauxbility-global-header__mobile span,
.agent-meauxbility-global-header__mobile::before,
.agent-meauxbility-global-header__mobile::after {
  content: "";
  width: 16px;
  height: 2px;
  margin: 4px auto;
  display: block;
  border-radius: 99px;
  background: currentColor;
}

.agent-meauxbility-global-header__mobile-panel { display: none; }

@media (max-width: 980px) {
  .agent-meauxbility-global-header__inner {
    grid-template-columns: 1fr auto;
    padding: 0 14px;
  }

  .agent-meauxbility-global-header__nav-wrap,
  .agent-meauxbility-global-header__actions {
    display: none;
  }

  .agent-meauxbility-global-header__mobile { display: block; }

  .agent-meauxbility-global-header[data-mobile-open="true"] .agent-meauxbility-global-header__mobile-panel {
    position: fixed;
    top: calc(var(--am-header-height) + 8px);
    left: 12px;
    right: 12px;
    display: grid;
    gap: 8px;
    padding: 12px;
    border-radius: 18px;
    background: rgba(10,11,14,.96);
    border: 1px solid rgba(255,255,255,.13);
    box-shadow: 0 24px 80px rgba(0,0,0,.42);
  }

  .agent-meauxbility-global-header__mobile-panel a {
    color: var(--am-header-text);
    text-decoration: none;
    padding: 12px 13px;
    border-radius: 12px;
    background: rgba(255,255,255,.055);
    font-size: 13px;
    font-weight: 750;
  }

  .agent-meauxbility-global-header__subtitle { display: none; }
}
""".strip()

JS = """
(function AgentMeauxbilityGlobalHeaderInline() {
  "use strict";

  var LOGO_URL = "__LOGO_URL__";

  var PRIMARY = [
    { path: "/", label: "Agents" },
    { path: "/automations", label: "Automations" },
    { path: "/dashboard", label: "Dashboard" },
    { path: "/cms", label: "CMS Editor" }
  ];

  var SECONDARY = [
    { path: "/cms?view=pages", label: "Pages" },
    { path: "/cms?view=themes", label: "Themes" },
    { path: "/cms?view=assets", label: "Assets" },
    { path: "/dashboard?view=runs", label: "Runs" },
    { path: "/dashboard?view=db", label: "Database" },
    { path: "/dashboard?view=settings", label: "Settings" }
  ];

  function normalize(pathname) {
    var path = pathname || "/";
    path = path.replace(/\\/+$/, "");
    return path || "/";
  }

  function activeFor(path) {
    var current = normalize(window.location.pathname);
    var clean = String(path || "/").split("?")[0];
    return normalize(clean) === current;
  }

  function link(route, className) {
    return [
      "<a class='" + className + "'",
      " href='" + route.path + "'",
      " data-active='" + (activeFor(route.path) ? "true" : "false") + "'",
      ">" + route.label + "</a>"
    ].join("");
  }

  function links(routes, className) {
    return routes.map(function(route) { return link(route, className); }).join("");
  }

  function hideOldNav() {
    Array.prototype.slice.call(document.querySelectorAll("header,nav")).forEach(function(el) {
      if (el.classList && el.classList.contains("agent-meauxbility-global-header")) return;

      var text = (el.textContent || "").replace(/\\s+/g, " ").trim();
      if (
        text.indexOf("Agents") !== -1 &&
        text.indexOf("Automations") !== -1 &&
        text.indexOf("Dashboard") !== -1
      ) {
        el.setAttribute("data-agent-legacy-hidden", "true");
        el.style.display = "none";
      }
    });
  }

  function mount() {
    if (document.querySelector(".agent-meauxbility-global-header")) return;

    var header = document.createElement("header");
    header.className = "agent-meauxbility-global-header";
    header.setAttribute("data-menu-open", "false");
    header.setAttribute("data-mobile-open", "false");

    header.innerHTML = [
      "<div class='agent-meauxbility-global-header__inner'>",
      "  <a class='agent-meauxbility-global-header__brand' href='/'>",
      "    <span class='agent-meauxbility-global-header__logo-shell'>",
      "      <img class='agent-meauxbility-global-header__logo' src='" + LOGO_URL + "' alt='Meauxbility logo'>",
      "    </span>",
      "    <span class='agent-meauxbility-global-header__brand-copy'>",
      "      <span class='agent-meauxbility-global-header__title'>Agent Meauxbility</span>",
      "      <span class='agent-meauxbility-global-header__subtitle'>Agent platform + CMS studio</span>",
      "    </span>",
      "  </a>",
      "  <div class='agent-meauxbility-global-header__nav-wrap'>",
      "    <nav class='agent-meauxbility-global-header__nav'>",
      links(PRIMARY, "agent-meauxbility-global-header__link"),
      "    </nav>",
      "    <div class='agent-meauxbility-global-header__more'>",
      "      <button class='agent-meauxbility-global-header__more-button' type='button' aria-label='More routes'>•••</button>",
      "      <div class='agent-meauxbility-global-header__menu'>",
      links(SECONDARY, "agent-meauxbility-global-header__menu-link"),
      "      </div>",
      "    </div>",
      "  </div>",
      "  <div class='agent-meauxbility-global-header__actions'>",
      "    <span class='agent-meauxbility-global-header__status'><span class='agent-meauxbility-global-header__dot'></span>Live</span>",
      "    <a class='agent-meauxbility-global-header__cta' href='/cms'>Open CMS</a>",
      "  </div>",
      "  <button class='agent-meauxbility-global-header__mobile' type='button' aria-label='Toggle navigation'><span></span></button>",
      "</div>",
      "<div class='agent-meauxbility-global-header__mobile-panel'>",
      links(PRIMARY.concat(SECONDARY), "agent-meauxbility-global-header__mobile-link"),
      "</div>"
    ].join("");

    document.body.insertBefore(header, document.body.firstChild);
    document.body.classList.add("agent-meauxbility-global-header-mounted");

    var more = header.querySelector(".agent-meauxbility-global-header__more-button");
    if (more) {
      more.addEventListener("click", function() {
        header.setAttribute("data-menu-open", header.getAttribute("data-menu-open") === "true" ? "false" : "true");
      });
    }

    var mobile = header.querySelector(".agent-meauxbility-global-header__mobile");
    if (mobile) {
      mobile.addEventListener("click", function() {
        header.setAttribute("data-mobile-open", header.getAttribute("data-mobile-open") === "true" ? "false" : "true");
      });
    }

    document.addEventListener("click", function(event) {
      if (!header.contains(event.target)) {
        header.setAttribute("data-menu-open", "false");
        header.setAttribute("data-mobile-open", "false");
      }
    });
  }

  function boot() {
    mount();
    hideOldNav();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
""".replace("__LOGO_URL__", LOGO_URL).strip()


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def backup(path: Path) -> None:
    if path.exists():
        dst = path.with_suffix(path.suffix + ".backup." + stamp())
        shutil.copy2(path, dst)
        print("backup ->", dst)


def inline_block() -> str:
    return "\n".join([
        START,
        "<style>",
        CSS,
        "</style>",
        "<script>",
        JS,
        "</script>",
        END,
    ])


def remove_old_header_assets(text: str) -> str:
    text = re.sub(r'\s*<link[^>]+agent-global-header\.css[^>]*>', "", text)
    text = re.sub(r'\s*<script[^>]+agent-global-header\.js[^>]*></script>', "", text)
    text = re.sub(
        re.escape(START) + r".*?" + re.escape(END),
        "",
        text,
        flags=re.S,
    )
    return text


def inject_before_head_close(text: str) -> str:
    text = remove_old_header_assets(text)

    match = re.search(r"</head\s*>", text, flags=re.I)
    if not match:
      raise SystemExit("Could not find </head> in target text.")

    return text[:match.start()] + "\n" + inline_block() + "\n" + text[match.start():]


def patch_file(path: Path) -> None:
    if not path.exists():
        raise SystemExit(f"Missing file: {path}")
    backup(path)
    path.write_text(inject_before_head_close(path.read_text(errors="replace")))
    print("patched ->", path)


def patch_worker() -> None:
    if not WORKER.exists():
        raise SystemExit("Missing worker.js")
    backup(WORKER)
    text = WORKER.read_text(errors="replace")
    updated = inject_before_head_close(text)
    WORKER.write_text(updated)
    print("patched ->", WORKER)


def regenerate_cms_module() -> None:
    if not CMS_HTML.exists():
        print("skip generated cms module; missing", CMS_HTML)
        return

    CMS_GENERATED_JS.parent.mkdir(parents=True, exist_ok=True)
    html = CMS_HTML.read_text(errors="replace")
    CMS_GENERATED_JS.write_text(
        "// Generated by scripts/cms/part2c_patch_worker_shell_global_header.py\n"
        "// Source: public/cms/cms-editor-index.html\n\n"
        "export const CMS_EDITOR_HTML = " + json.dumps(html) + ";\n"
    )
    print("regenerated ->", CMS_GENERATED_JS)


def main() -> int:
    patch_worker()

    if CMS_HTML.exists():
        patch_file(CMS_HTML)
        regenerate_cms_module()
    else:
        print("CMS snapshot missing; skipped", CMS_HTML)

    print()
    print("Next:")
    print("  npx wrangler deploy --dry-run -c wrangler.json")
    print("  npx wrangler deploy -c wrangler.json")
    print("  open https://agent.meauxbility.workers.dev/")
    print("  open https://agent.meauxbility.workers.dev/dashboard")
    print("  open https://agent.meauxbility.workers.dev/automations")
    print("  open https://agent.meauxbility.workers.dev/cms")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
