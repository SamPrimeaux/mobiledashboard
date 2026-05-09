#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
INDEX = ROOT / "index.html"
WORKER = ROOT / "worker.js"
SMOKE = ROOT / "scripts" / "cms" / "smoke_agent_mpa_routes.sh"

START = "<!-- AGENT_MEAUXBILITY_MPA_ROUTE_BRIDGE_START -->"
END = "<!-- AGENT_MEAUXBILITY_MPA_ROUTE_BRIDGE_END -->"

ROUTE_BRIDGE = """
<!-- AGENT_MEAUXBILITY_MPA_ROUTE_BRIDGE_START -->
<script>
(function AgentMeauxbilityMpaRouteBridge() {
  "use strict";

  var ROUTES = {
    "/": { key: "agents", label: "Agents", title: "Agent Meauxbility — Agents" },
    "/automations": { key: "automations", label: "Automations", title: "Agent Meauxbility — Automations" },
    "/dashboard": { key: "dashboard", label: "Dashboard", title: "Agent Meauxbility — Dashboard" },
    "/cms": { key: "cms", label: "CMS", title: "Agent Meauxbility — CMS" }
  };

  function normalizePath(pathname) {
    var path = pathname || "/";
    path = path.replace(/\\/+$/, "");
    if (!path) path = "/";
    return ROUTES[path] ? path : "/";
  }

  function currentRoute() {
    return ROUTES[normalizePath(window.location.pathname)];
  }

  function cleanText(el) {
    return (el.textContent || "").replace(/\\s+/g, " ").trim().toLowerCase();
  }

  function allControls() {
    return Array.prototype.slice.call(
      document.querySelectorAll("a,button,[role='tab'],[data-route],[data-view],[data-tab]")
    );
  }

  function findControl(label) {
    var target = String(label || "").toLowerCase();
    var items = allControls();
    for (var i = 0; i < items.length; i += 1) {
      if (cleanText(items[i]).indexOf(target) !== -1) return items[i];
    }
    return null;
  }

  function ensureCmsNav() {
    if (findControl("CMS")) return;

    var nav = document.querySelector("nav") || document.querySelector("header") || document.querySelector("[role='navigation']");
    if (!nav) return;

    var a = document.createElement("a");
    a.href = "/cms";
    a.textContent = "CMS";
    a.setAttribute("data-agent-route", "/cms");
    a.style.marginLeft = "12px";
    nav.appendChild(a);
  }

  function wireNav() {
    Object.keys(ROUTES).forEach(function(path) {
      var route = ROUTES[path];
      var el = findControl(route.label);
      if (!el) return;

      el.setAttribute("data-agent-route", path);

      if (el.tagName && el.tagName.toLowerCase() === "a") {
        el.setAttribute("href", path);
      }

      el.addEventListener("click", function(event) {
        if (window.__AGENT_MPA_ACTIVATING__) return;

        var modified = event.metaKey || event.ctrlKey || event.shiftKey || event.altKey;
        if (modified) return;

        var now = normalizePath(window.location.pathname);
        if (now !== path) {
          event.preventDefault();
          window.location.assign(path);
        }
      }, true);
    });
  }

  function markActive(route) {
    Object.keys(ROUTES).forEach(function(path) {
      var r = ROUTES[path];
      var el = findControl(r.label);
      if (!el) return;

      if (r.key === route.key) {
        el.setAttribute("aria-current", "page");
        el.setAttribute("data-active-route", "true");
      } else {
        el.removeAttribute("aria-current");
        el.removeAttribute("data-active-route");
      }
    });

    document.documentElement.setAttribute("data-agent-route", route.key);
    document.body.setAttribute("data-agent-route", route.key);
    document.title = route.title;
  }

  function activateExistingView(route) {
    var el = findControl(route.label);
    if (!el) return false;

    try {
      window.__AGENT_MPA_ACTIVATING__ = true;
      el.click();
      return true;
    } catch (err) {
      return false;
    } finally {
      window.__AGENT_MPA_ACTIVATING__ = false;
    }
  }

  function ensureCmsFallback(route) {
    if (route.key !== "cms") return;

    var main = document.querySelector("main") || document.querySelector("#app") || document.querySelector("#root") || document.body;
    if (!main) return;

    var existing = cleanText(main);
    if (existing.indexOf("cms editor") !== -1 || existing.indexOf("section library") !== -1) return;

    var panel = document.createElement("section");
    panel.setAttribute("data-agent-route", "cms-view");
    panel.setAttribute("aria-label", "CMS editor route shell");
    panel.style.margin = "24px auto";
    panel.style.maxWidth = "1180px";
    panel.style.padding = "20px";
    panel.style.border = "1px solid rgba(255,255,255,0.12)";
    panel.style.borderRadius = "18px";
    panel.style.background = "rgba(255,255,255,0.04)";
    panel.style.backdropFilter = "blur(16px)";

    panel.innerHTML = [
      "<div style='display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap'>",
      "  <div>",
      "    <p style='margin:0 0 6px 0;opacity:.7;font-size:12px;letter-spacing:.08em;text-transform:uppercase'>CMS route shell</p>",
      "    <h1 style='margin:0;font-size:28px;line-height:1.1'>CMS Editor</h1>",
      "    <p style='margin:10px 0 0 0;opacity:.72;max-width:720px'>The CMS route is now addressable at /cms. Next step is wiring this shell to /api/cms/pages and /api/cms/sections/library while preserving the current UI.</p>",
      "  </div>",
      "  <div style='display:flex;gap:8px;flex-wrap:wrap'>",
      "    <span style='padding:8px 10px;border-radius:999px;background:rgba(255,255,255,.08)'>DB: pending health check</span>",
      "    <span style='padding:8px 10px;border-radius:999px;background:rgba(255,255,255,.08)'>CMS bucket: pending health check</span>",
      "  </div>",
      "</div>",
      "<div style='display:grid;grid-template-columns:260px 1fr 300px;gap:14px;margin-top:18px'>",
      "  <aside style='min-height:360px;border:1px solid rgba(255,255,255,.10);border-radius:14px;padding:14px;background:rgba(0,0,0,.14)'>Section Library</aside>",
      "  <section style='min-height:360px;border:1px solid rgba(255,255,255,.10);border-radius:14px;padding:14px;background:rgba(0,0,0,.10)'>Page Canvas</section>",
      "  <aside style='min-height:360px;border:1px solid rgba(255,255,255,.10);border-radius:14px;padding:14px;background:rgba(0,0,0,.14)'>Settings</aside>",
      "</div>"
    ].join("");

    main.appendChild(panel);
  }

  function boot() {
    var route = currentRoute();

    ensureCmsNav();
    wireNav();
    markActive(route);
    activateExistingView(route);
    markActive(route);
    ensureCmsFallback(route);

    window.AgentMeauxbilityRoutes = {
      current: route,
      routes: ROUTES,
      normalizePath: normalizePath
    };
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
</script>
<!-- AGENT_MEAUXBILITY_MPA_ROUTE_BRIDGE_END -->
""".strip()


def stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def backup(path: Path) -> None:
    dst = path.with_suffix(path.suffix + ".backup." + stamp())
    shutil.copy2(path, dst)
    print("backup ->", dst)


def replace_block(text: str, block: str) -> str:
    if START in text and END in text:
        before = text.split(START, 1)[0].rstrip()
        after = text.split(END, 1)[1].lstrip()
        return before + "\n" + block + "\n" + after

    lower = text.lower()
    idx = lower.rfind("</body>")
    if idx != -1:
        return text[:idx].rstrip() + "\n\n" + block + "\n\n" + text[idx:]

    return text.rstrip() + "\n\n" + block + "\n"


def patch_index(no_backup: bool) -> None:
    if not INDEX.exists():
        raise SystemExit("index.html not found. Run from /Users/samprimeaux/mobiledashboard.")
    if not no_backup:
        backup(INDEX)
    INDEX.write_text(replace_block(INDEX.read_text(), ROUTE_BRIDGE))
    print("patched index.html")


def write_smoke() -> None:
    SMOKE.parent.mkdir(parents=True, exist_ok=True)
    SMOKE.write_text(
        "#!/usr/bin/env bash\n"
        "set -euo pipefail\n"
        'BASE="${AGENT_MEAUXBILITY_APP_URL:-https://agent.meauxbility.workers.dev}"\n'
        "\n"
        "for path in / /automations /dashboard /cms; do\n"
        '  echo "== ${path} =="\n'
        '  /usr/bin/curl -I "${BASE}${path}" | /usr/bin/sed -n "1,12p"\n'
        "done\n"
    )
    SMOKE.chmod(0o755)
    print("wrote", SMOKE)


def inspect_worker() -> None:
    if not WORKER.exists():
        print("worker.js missing; skipped worker inspection")
        return
    text = WORKER.read_text(errors="ignore")
    missing = [p for p in ["/automations", "/dashboard", "/cms"] if p not in text]
    if missing:
        print("worker.js does not explicitly mention:", ", ".join(missing))
        print("This may be OK because live Worker already returned 200 for these SPA fallback routes.")
    else:
        print("worker.js already mentions target routes")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-backup", action="store_true")
    args = parser.parse_args()

    patch_index(args.no_backup)
    write_smoke()
    inspect_worker()

    print("")
    print("Next:")
    print("  npx wrangler deploy --dry-run -c wrangler.json")
    print("  npx wrangler deploy -c wrangler.json")
    print("  scripts/cms/smoke_agent_mpa_routes.sh")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
