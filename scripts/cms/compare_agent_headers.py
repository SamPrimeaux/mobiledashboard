#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
from pathlib import Path
from html import unescape

ROOT = Path(".")
OUT = ROOT / "tmp/agent-meauxbility/header-compare"
OUT.mkdir(parents=True, exist_ok=True)

PAGES = {
    "root": "https://agent.meauxbility.workers.dev/",
    "automations": "https://agent.meauxbility.workers.dev/automations",
    "dashboard": "https://agent.meauxbility.workers.dev/dashboard",
    "cms": "https://agent.meauxbility.workers.dev/cms",
}

PATTERNS = {
    "main_header": re.compile(r'<header[^>]+id=["\']main-header["\'][\s\S]*?</header>', re.I),
    "cms_dark_header": re.compile(r'<header[^>]+class=["\'][^"\']*agent-cms-dark-header[^"\']*["\'][\s\S]*?</header>', re.I),
    "global_header_block": re.compile(r'<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_START -->[\s\S]*?<!-- AGENT_MEAUXBILITY_GLOBAL_HEADER_END -->', re.I),
    "cms_dark_header_block": re.compile(r'<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_START -->[\s\S]*?<!-- AGENT_MEAUXBILITY_CMS_DARK_HEADER_END -->', re.I),
}

def curl(url: str) -> str:
    return subprocess.check_output(["/usr/bin/curl", "-sS", url], text=True)

def normalize(s: str) -> str:
    s = unescape(s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()

def extract(name: str, html: str) -> dict[str, str]:
    found = {}
    for key, rx in PATTERNS.items():
        m = rx.search(html)
        if m:
            found[key] = m.group(0)
            (OUT / f"{name}.{key}.html").write_text(m.group(0) + "\n")
            (OUT / f"{name}.{key}.normalized.txt").write_text(normalize(m.group(0)) + "\n")
    return found

summary = []
for name, url in PAGES.items():
    html = curl(url)
    (OUT / f"{name}.live.html").write_text(html)
    found = extract(name, html)

    summary.append({
        "page": name,
        "url": url,
        "has_main_header": "main_header" in found,
        "has_cms_dark_header": "cms_dark_header" in found,
        "has_old_global_header": "global_header_block" in found,
        "has_cms_dark_block": "cms_dark_header_block" in found,
    })

lines = ["# Agent Meauxbility Header Compare", ""]
for row in summary:
    lines.append(f"## {row['page']}")
    lines.append(f"- URL: `{row['url']}`")
    lines.append(f"- main_header: `{row['has_main_header']}`")
    lines.append(f"- cms_dark_header: `{row['has_cms_dark_header']}`")
    lines.append(f"- old_global_header_block: `{row['has_old_global_header']}`")
    lines.append(f"- cms_dark_header_block: `{row['has_cms_dark_block']}`")
    lines.append("")

lines.append("## Files")
for path in sorted(OUT.glob("*")):
    lines.append(f"- `{path}`")

(OUT / "summary.md").write_text("\n".join(lines) + "\n")
print(f"wrote {OUT}/summary.md")
