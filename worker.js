const HTML = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Agent Platform</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            app: 'var(--bg-app)',
            surface: 'var(--bg-surface)',
            surfaceHover: 'var(--bg-surface-hover)',
            border: 'var(--border-main)',
            primary: 'var(--primary)',
            textMain: 'var(--text-main)',
            textMuted: 'var(--text-muted)',
            diffAddBg: '#10331b',
            diffAddText: '#4ade80',
            diffSubBg: '#3f1115',
            diffSubText: '#f87171',
          },
          fontFamily: {
            sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
            mono: ['JetBrains Mono', 'Menlo', 'Monaco', 'monospace'],
          }
        }
      }
    }
  </script>
  <style>
    :root {
      --bg-app: #0e0e0e;
      --bg-surface: #181818;
      --bg-surface-hover: #242424;
      --border-main: #2a2a2a;
      --primary: #3b82f6;
      --text-main: #ececec;
      --text-muted: #8b8b8b;
    }
    body {
      -webkit-tap-highlight-color: transparent;
      background-color: var(--bg-app);
      color: var(--text-main);
      overflow-x: hidden;
    }
    .no-scrollbar::-webkit-scrollbar { display: none; }
    .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

    .drawer { transform: translateY(100%); transition: transform 0.3s cubic-bezier(0.4,0,0.2,1); }
    .drawer.open { transform: translateY(0); }
    .overlay { opacity: 0; pointer-events: none; transition: opacity 0.3s ease; }
    .overlay.open { opacity: 1; pointer-events: auto; }

    .screen { display: none; }
    .screen.active { display: flex; }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(6px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .screen.active { animation: fadeIn 0.18s ease-out forwards; }

    .file-content { display: none; }
    .file-content.expanded { display: block; }
    .file-header.expanded .caret-icon { transform: rotate(90deg); }
    .auto-caret { transition: transform 0.2s ease; }
    .auto-caret.expanded { transform: rotate(180deg); }
    .caret-icon { transition: transform 0.2s ease; }
  </style>
</head>
<body class="h-screen w-screen overflow-hidden flex flex-col font-sans text-sm">

  <!-- ═══════════════════════════════════════════════
       PERSISTENT MAIN NAV — always visible except chat
  ════════════════════════════════════════════════════ -->
  <header id="main-header" class="grid grid-cols-3 items-center px-4 py-3 border-b border-border bg-app shrink-0 relative z-10">
    <div class="flex items-center">
      <img src="https://imagedelivery.net/g7wf09fCONpnidkRnR_5vw/ac515729-af6b-4ea5-8b10-e581a4d02100/thumbnail"
           alt="Logo" class="w-6 h-6 rounded object-cover">
    </div>
    <nav class="flex items-center justify-center gap-4 overflow-x-auto no-scrollbar whitespace-nowrap">
      <button id="nav-agents"      onclick="switchTab('agents')"      class="nav-btn active-nav">Agents</button>
      <button id="nav-automations" onclick="switchTab('automations')" class="nav-btn">Automations</button>
      <button id="nav-dashboard"   onclick="switchTab('dashboard')"   class="nav-btn">Dashboard</button>
    </nav>
    <div class="flex items-center justify-end">
      <div class="w-7 h-7 rounded-full bg-surfaceHover flex items-center justify-center text-xs border border-border">sp</div>
    </div>
  </header>

  <style>
    .nav-btn { color: var(--text-muted); font-size:.875rem; transition: color .15s; }
    .nav-btn:hover { color: var(--text-main); }
    .nav-btn.active-nav { color: var(--text-main); font-weight: 500; }
  </style>

  <!-- ═══════════════════════════════════
       SCREEN: AGENTS
  ════════════════════════════════════════ -->
  <div id="screen-agents" class="screen active flex-col flex-1 overflow-hidden w-full">
    <main class="flex-1 overflow-y-auto no-scrollbar p-4 flex flex-col gap-6">

      <!-- Composer -->
      <div class="flex flex-col gap-3">
        <div class="bg-surface border border-border rounded-xl p-3 flex flex-col gap-3">
          <textarea class="bg-transparent text-textMain placeholder-textMuted resize-none outline-none w-full h-12"
                    placeholder="Ask the Agent to build, fix bugs, explore..."></textarea>
          <div class="flex items-center justify-between text-textMuted mt-1">
            <div class="flex items-center gap-2">
              <button class="flex items-center gap-1 text-xs hover:text-textMain bg-surfaceHover px-2 py-1 rounded-md">
                Composer 2 <i class="ph ph-caret-down"></i>
              </button>
              <button class="flex items-center gap-1 text-xs hover:text-textMain bg-surfaceHover px-2 py-1 rounded-md">
                <i class="ph ph-brain text-blue-400"></i> <i class="ph ph-caret-down"></i>
              </button>
              <button class="flex items-center gap-1 text-xs text-orange-400 border border-orange-900/50 bg-orange-900/10 px-2 py-1 rounded-md">
                <i class="ph ph-funnel"></i> No test
              </button>
            </div>
            <div class="flex items-center gap-3">
              <button class="hover:text-textMain"><i class="ph ph-image text-lg"></i></button>
              <button class="bg-textMain text-app rounded-full p-1 hover:opacity-80"><i class="ph-fill ph-microphone text-sm"></i></button>
            </div>
          </div>
        </div>
        <button onclick="toggleRepoDrawer()" class="flex items-center gap-1 text-textMuted text-xs hover:text-textMain self-start">
          SamPrimeaux/inneranimalmedia-a... <i class="ph ph-caret-down"></i> main <i class="ph ph-caret-down"></i>
        </button>
      </div>

      <div class="h-px bg-border w-full"></div>

      <!-- Conversation History -->
      <div class="flex flex-col gap-4 pb-8" id="conversation-list">
        <div class="flex items-center text-textMuted">
          <i class="ph ph-magnifying-glass text-lg"></i>
        </div>

        <div class="flex flex-col gap-2">
          <h3 class="text-xs text-textMuted font-medium mb-1">Today</h3>
          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg hover:bg-surface cursor-pointer" onclick="openChat('Most efficient model','2h')">
            <i class="ph ph-check-circle text-textMuted self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between items-center">
                <span class="text-textMain">Most efficient model</span>
                <span class="text-textMuted text-xs">2h</span>
              </div>
              <div class="flex items-center gap-2 text-textMuted text-xs mt-0.5">
                <span class="truncate max-w-[200px]">inneranimalmedia-agentsam-dashboa...</span>
                <span>Composer...</span>
              </div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <h3 class="text-xs text-textMuted font-medium mb-1 mt-2">This Month</h3>

          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg hover:bg-surface cursor-pointer" onclick="openChat('Hello message','1w')">
            <i class="ph ph-check-circle text-textMuted self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between"><span class="text-textMain">Hello message</span><span class="text-textMuted text-xs">1w</span></div>
              <div class="flex gap-2 text-textMuted text-xs mt-0.5"><span>dashboard</span><span>Opus 4.6 High</span></div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>

          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg bg-surface border border-border cursor-pointer" onclick="openChat('Platform UI stability','1w')">
            <i class="ph ph-git-branch text-purple-400 self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between"><span class="text-textMain">Platform UI stability</span><span class="text-textMuted text-xs">1w</span></div>
              <div class="flex gap-2 text-xs mt-0.5">
                <span class="text-green-400">+1892</span><span class="text-red-400">-82</span>
                <span class="text-textMuted truncate max-w-[180px]">inneranimalmedia-agentsam-dashboard</span>
              </div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>

          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg hover:bg-surface cursor-pointer" onclick="openChat('Build information summary','3w')">
            <i class="ph ph-git-branch text-purple-400 self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between"><span class="text-textMain">Build information summary</span><span class="text-textMuted text-xs">3w</span></div>
              <div class="flex gap-2 text-textMuted text-xs mt-0.5"><span>iam-pty</span><span>Sonnet 4.6 High</span></div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>
        </div>

        <div class="flex flex-col gap-2">
          <h3 class="text-xs text-textMuted font-medium mb-1 mt-2">Older</h3>
          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg hover:bg-surface cursor-pointer" onclick="openChat('Footer login link consistency','1mo')">
            <i class="ph ph-git-branch text-purple-400 self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between"><span class="text-textMain">Footer login link consistency</span><span class="text-textMuted text-xs">1mo</span></div>
              <div class="flex gap-2 text-xs mt-0.5"><span class="text-green-400">+4173</span><span class="text-red-400">-724</span><span class="text-textMuted">dashboard</span></div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>
          <div class="flex items-center gap-3 p-2 -mx-2 rounded-lg hover:bg-surface cursor-pointer" onclick="openChat('Durable object class missing','1mo')">
            <i class="ph ph-git-branch text-purple-400 self-start mt-0.5"></i>
            <div class="flex-1 flex flex-col">
              <div class="flex justify-between"><span class="text-textMain">Durable object class missing</span><span class="text-textMuted text-xs">1mo</span></div>
              <div class="flex gap-2 text-xs mt-0.5"><span class="text-green-400">+4168</span><span class="text-red-400">-3675</span><span class="text-textMuted">dashboard</span></div>
            </div>
            <i class="ph ph-caret-right text-textMuted/40 text-lg"></i>
          </div>
        </div>
      </div>
    </main>
  </div>

  <!-- ═══════════════════════════════════
       SCREEN: AUTOMATIONS
  ════════════════════════════════════════ -->
  <div id="screen-automations" class="screen flex-col flex-1 overflow-hidden w-full">
    <main class="flex-1 overflow-y-auto no-scrollbar p-4 flex flex-col gap-6 pb-12">
      <h1 class="text-xl text-textMain font-medium">Automations</h1>

      <div class="flex flex-col gap-2">
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Total</span><span class="text-lg text-textMain">0</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Successful · 7d</span><span class="text-lg text-textMain">0</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Failed · 7d</span><span class="text-lg text-textMain">0</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex items-center justify-between cursor-pointer hover:bg-surfaceHover">
          <span class="text-sm text-textMuted">Run History</span>
          <i class="ph ph-arrow-right text-textMuted"></i>
        </div>
      </div>

      <div class="h-px bg-border w-full my-2"></div>

      <div class="bg-surface border border-border rounded-xl p-3 flex flex-col gap-2">
        <textarea class="bg-transparent text-textMuted resize-none outline-none w-full h-16 text-sm"
                  placeholder="Review every new pull request for security issues..."></textarea>
        <div class="flex justify-end">
          <button class="bg-surfaceHover text-textMuted rounded-full p-1.5 border border-border hover:text-textMain">
            <i class="ph ph-arrow-up text-sm"></i>
          </button>
        </div>
      </div>

      <div class="flex flex-col gap-4 mt-2">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4 text-sm">
            <button class="bg-surfaceHover text-textMain px-3 py-1 rounded-md border border-border">Mine</button>
            <button class="text-textMuted hover:text-textMain">All</button>
          </div>
          <div class="flex items-center gap-3">
            <i class="ph ph-magnifying-glass text-textMuted text-lg cursor-pointer hover:text-textMain"></i>
            <button class="bg-surfaceHover text-textMain px-3 py-1.5 rounded-md border border-border text-xs flex items-center gap-1">
              <i class="ph ph-plus"></i> New
            </button>
          </div>
        </div>
        <div class="text-center text-textMuted text-sm py-6 border-b border-border">No Automations Yet</div>
      </div>

      <div class="flex flex-col gap-3 mt-2">
        <h3 class="text-sm text-textMuted">Suggested Templates</h3>

        <!-- Template cards -->
        <div class="bg-surface border border-border rounded-xl flex flex-col overflow-hidden">
          <div class="p-4 flex items-start gap-3 cursor-pointer hover:bg-surfaceHover" onclick="toggleAutomation('auto-1',this)">
            <div class="w-6 h-6 rounded bg-app border border-border flex items-center justify-center text-textMuted shrink-0 mt-0.5"><i class="ph ph-shield-check"></i></div>
            <div class="flex-1 flex flex-col gap-1">
              <div class="flex justify-between items-center">
                <h4 class="text-textMain text-sm font-medium">Find vulnerabilities</h4>
                <i class="ph ph-caret-down text-textMuted auto-caret"></i>
              </div>
              <p class="text-textMuted text-xs leading-relaxed">Review pull requests for exploitable security issues and flag only validated findings before merge</p>
            </div>
          </div>
          <div id="auto-1" class="hidden bg-app border-t border-border p-4 flex-col gap-4">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs text-textMuted">Target Repositories</label>
              <select class="bg-surface border border-border rounded-lg p-2 text-sm text-textMain outline-none w-full">
                <option>All Repositories</option>
                <option>inneranimalmedia-agentsam-dashboard</option>
              </select>
            </div>
            <button class="bg-surfaceHover border border-border text-textMain py-2 rounded-lg text-sm font-medium flex items-center justify-center gap-2">
              <i class="ph ph-plus"></i> Create Automation
            </button>
          </div>
        </div>

        <div class="bg-surface border border-border rounded-xl flex flex-col overflow-hidden">
          <div class="p-4 flex items-start gap-3 cursor-pointer hover:bg-surfaceHover" onclick="toggleAutomation('auto-2',this)">
            <div class="w-6 h-6 rounded bg-app border border-border flex items-center justify-center text-textMuted shrink-0 mt-0.5"><i class="ph ph-git-merge"></i></div>
            <div class="flex-1 flex flex-col gap-1">
              <div class="flex justify-between items-center">
                <h4 class="text-textMain text-sm font-medium">Assign PR reviewers</h4>
                <i class="ph ph-caret-down text-textMuted auto-caret"></i>
              </div>
              <p class="text-textMuted text-xs leading-relaxed">Assign reviewers based on code changes and auto-approve low-risk PRs</p>
            </div>
          </div>
          <div id="auto-2" class="hidden bg-app border-t border-border p-4 flex-col gap-4">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs text-textMuted">Code Path Match (Glob)</label>
              <input type="text" placeholder="e.g. src/components/**/*.tsx" class="bg-surface border border-border rounded-lg p-2 text-sm text-textMain outline-none w-full">
            </div>
            <button class="bg-surfaceHover border border-border text-textMain py-2 rounded-lg text-sm font-medium flex items-center justify-center gap-2">
              <i class="ph ph-plus"></i> Create Automation
            </button>
          </div>
        </div>

        <div class="bg-surface border border-border rounded-xl flex flex-col overflow-hidden">
          <div class="p-4 flex items-start gap-3 cursor-pointer hover:bg-surfaceHover" onclick="toggleAutomation('auto-3',this)">
            <div class="w-6 h-6 rounded bg-app border border-border flex items-center justify-center text-textMuted shrink-0 mt-0.5"><i class="ph ph-envelope-simple"></i></div>
            <div class="flex-1 flex flex-col gap-1">
              <div class="flex justify-between items-center">
                <h4 class="text-textMain text-sm font-medium">Summarize changes daily</h4>
                <i class="ph ph-caret-down text-textMuted auto-caret"></i>
              </div>
              <p class="text-textMuted text-xs leading-relaxed">Post a daily digest summarizing notable repository changes and risks</p>
            </div>
          </div>
          <div id="auto-3" class="hidden bg-app border-t border-border p-4 flex-col gap-4">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs text-textMuted">Slack Webhook URL</label>
              <input type="password" placeholder="https://hooks.slack.com/services/..." class="bg-surface border border-border rounded-lg p-2 text-sm text-textMain outline-none w-full">
            </div>
            <button class="bg-surfaceHover border border-border text-textMain py-2 rounded-lg text-sm font-medium flex items-center justify-center gap-2">
              <i class="ph ph-plus"></i> Create Automation
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>

  <!-- ═══════════════════════════════════
       SCREEN: DASHBOARD
  ════════════════════════════════════════ -->
  <div id="screen-dashboard" class="screen flex-col flex-1 overflow-hidden w-full">
    <main class="flex-1 overflow-y-auto no-scrollbar p-4 flex flex-col gap-6 pb-12">
      <div class="flex items-center justify-between">
        <h1 class="text-xl text-textMain font-medium">Dashboard</h1>
        <span id="ws-label" class="text-xs text-textMuted bg-surface border border-border px-2 py-1 rounded-md">ws_agent</span>
      </div>

      <!-- Health status -->
      <div id="health-row" class="bg-surface border border-border rounded-xl p-4 flex items-center justify-between">
        <div class="flex items-center gap-2">
          <div id="health-dot" class="w-2 h-2 rounded-full bg-textMuted animate-pulse"></div>
          <span class="text-sm text-textMuted">API</span>
        </div>
        <span id="health-status" class="text-xs text-textMuted">checking...</span>
      </div>

      <!-- Stat cards -->
      <div class="grid grid-cols-2 gap-2">
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Conversations</span>
          <span id="stat-conversations" class="text-2xl text-textMain font-light">—</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Runs Today</span>
          <span id="stat-runs" class="text-2xl text-textMain font-light">—</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Tokens Used</span>
          <span id="stat-tokens" class="text-2xl text-textMain font-light">—</span>
        </div>
        <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-1">
          <span class="text-xs text-textMuted">Cost · Today</span>
          <span id="stat-cost" class="text-2xl text-textMain font-light">—</span>
        </div>
      </div>

      <!-- Workspace info -->
      <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-3">
        <h3 class="text-sm text-textMain font-medium">Workspace</h3>
        <div class="flex flex-col gap-2 text-xs">
          <div class="flex justify-between"><span class="text-textMuted">ID</span><span class="text-textMain font-mono">ws_agent</span></div>
          <div class="flex justify-between"><span class="text-textMuted">Org</span><span class="text-textMain">Inner Animal Media</span></div>
          <div class="flex justify-between"><span class="text-textMuted">Environment</span><span class="text-textMain">production</span></div>
          <div class="flex justify-between"><span class="text-textMuted">DB</span><span class="text-textMain font-mono">cc3db6f4</span></div>
        </div>
      </div>

      <!-- Mode configs -->
      <div class="flex flex-col gap-2">
        <h3 class="text-sm text-textMuted">Active Modes</h3>
        <div class="flex flex-wrap gap-2">
          <span class="bg-blue-500/10 border border-blue-500/30 text-blue-400 text-xs px-3 py-1 rounded-full">Agent</span>
          <span class="bg-purple-500/10 border border-purple-500/30 text-purple-400 text-xs px-3 py-1 rounded-full">Plan</span>
          <span class="bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs px-3 py-1 rounded-full">Ask</span>
          <span class="bg-orange-500/10 border border-orange-500/30 text-orange-400 text-xs px-3 py-1 rounded-full">Debug</span>
          <span class="bg-pink-500/10 border border-pink-500/30 text-pink-400 text-xs px-3 py-1 rounded-full">Subagent</span>
        </div>
      </div>

      <div class="flex flex-col gap-2">
        <h3 class="text-sm text-textMuted">Recent Runs</h3>
        <div id="recent-runs" class="flex flex-col gap-2">
          <div class="text-center text-textMuted text-sm py-6 border border-border rounded-xl">No runs yet</div>
        </div>
      </div>
    </main>
  </div>

  <!-- ═══════════════════════════════════
       SCREEN: CHAT (drill-down, own header)
  ════════════════════════════════════════ -->
  <div id="screen-chat" class="screen flex-col flex-1 overflow-hidden w-full">
    <header class="flex items-center justify-between px-4 py-3 border-b border-border bg-app shrink-0">
      <div class="flex items-center gap-3">
        <button onclick="closeChat()" class="text-textMuted hover:text-textMain p-1 -ml-1">
          <i class="ph ph-caret-left text-xl"></i>
        </button>
        <h1 id="chat-title" class="text-textMain font-medium truncate max-w-[200px]">Chat</h1>
      </div>
      <div class="flex items-center gap-3">
        <button class="text-textMuted"><i class="ph ph-dots-three text-xl"></i></button>
        <button class="bg-surface border border-border text-textMain px-3 py-1 text-xs rounded-md">View PR</button>
      </div>
    </header>

    <div class="flex items-center gap-2 px-4 py-2 border-b border-border bg-app shrink-0">
      <button onclick="switchChatTab('chat')" id="tab-chat" class="px-3 py-1 rounded-md bg-surface text-textMain text-xs font-medium">Chat</button>
      <button onclick="switchChatTab('diff')" id="tab-diff" class="px-3 py-1 rounded-md text-textMuted text-xs font-medium">Diff</button>
    </div>

    <main id="content-chat" class="flex-1 overflow-y-auto no-scrollbar p-4 flex flex-col gap-4">
      <div class="bg-surface border border-border rounded-xl p-4 flex flex-col gap-3">
        <div class="font-mono text-xs text-textMuted whitespace-pre-wrap">-- Fast keyword search
SELECT id, title, slug, doc_type FROM context_index</div>
        <div class="text-xs text-textMuted border-b border-border pb-3">Worked for 3m 5s</div>
        <h2 class="text-textMain font-bold text-base mt-2">Audit</h2>
        <p class="text-textMain text-sm">Relevant assembly points in <code class="bg-surfaceHover px-1 py-0.5 rounded text-xs">worker.js</code>:</p>
        <ul class="list-disc pl-5 text-textMain text-sm space-y-2">
          <li><code class="bg-surfaceHover px-1 py-0.5 rounded text-xs">compiled_context</code> / cache: ~5850-5970</li>
          <li><strong>RAG block:</strong> ~5928-5952 (<code class="bg-surfaceHover px-1 py-0.5 rounded text-xs">vectorizeRagSearch</code>)</li>
          <li><strong>Final system string:</strong> ~6125-6135 <code class="bg-surfaceHover px-1 py-0.5 rounded text-xs">buildModeContext()</code></li>
        </ul>
      </div>

      <div class="mt-auto pt-4 flex flex-col gap-3">
        <div class="flex gap-2">
          <button class="border border-border bg-surface text-textMain px-3 py-1.5 rounded-full text-xs font-medium">Fix merge conflicts</button>
        </div>
        <div class="bg-surface border border-border rounded-xl p-3 flex flex-col gap-3">
          <input type="text" class="bg-transparent text-textMain placeholder-textMuted outline-none w-full text-sm" placeholder="Add a follow up">
          <div class="flex items-center justify-between text-textMuted mt-1">
            <button class="text-xs hover:text-textMain">Composer 2</button>
            <div class="flex items-center gap-3">
              <button><i class="ph ph-image text-lg"></i></button>
              <button class="bg-textMain text-app rounded-full p-1"><i class="ph-fill ph-microphone text-sm"></i></button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <main id="content-diff" class="flex-1 overflow-y-auto no-scrollbar p-2 hidden flex-col gap-2">
      <div class="border border-border rounded-lg bg-app overflow-hidden">
        <div class="file-header expanded flex items-center justify-between p-3 bg-surface cursor-pointer" onclick="toggleFile('file-1',this)">
          <div class="flex items-center gap-2">
            <i class="ph ph-caret-right caret-icon text-textMuted"></i>
            <span class="text-textMain text-xs font-mono">dashboard/auth-signin.html</span>
          </div>
          <div class="flex items-center gap-3">
            <span class="text-green-400 text-xs">+28</span>
            <span class="text-red-400 text-xs">-1</span>
          </div>
        </div>
        <div id="file-1" class="file-content expanded bg-app border-t border-border font-mono text-[11px] leading-relaxed overflow-x-auto">
          <div class="flex text-textMuted bg-surfaceHover px-2 py-1 text-[10px] items-center gap-2 border-b border-border">
            <i class="ph ph-caret-up"></i> 526 unmodified lines
          </div>
          <div class="flex px-2 py-0.5 bg-diffSubBg text-diffSubText relative">
            <div class="absolute left-0 top-0 bottom-0 w-1 bg-red-500/50"></div>
            <span class="w-6 text-right mr-3 opacity-70">531</span> &lt;div style="margin: 20px 0;"&gt;
          </div>
          <div class="flex px-2 py-0.5 bg-diffAddBg text-diffAddText relative">
            <div class="absolute left-0 top-0 bottom-0 w-1 bg-green-500/50"></div>
            <span class="w-6 text-right mr-3 opacity-70">531</span> &lt;div id="oauthProviderRow"&gt;
          </div>
          <div class="flex px-2 py-0.5 bg-diffAddBg text-diffAddText relative">
            <div class="absolute left-0 top-0 bottom-0 w-1 bg-green-500/50"></div>
            <span class="w-6 text-right mr-3 opacity-70">532</span>     &lt;a id="googleSignIn" href="/api/oauth..."&gt;
          </div>
        </div>
      </div>
    </main>
  </div>

  <!-- REPO DRAWER -->
  <div id="drawer-overlay" class="overlay fixed inset-0 bg-black/60 z-40" onclick="closeRepoDrawer()"></div>
  <div id="repo-drawer" class="drawer fixed bottom-0 left-0 right-0 bg-surface rounded-t-2xl z-50 border-t border-border flex flex-col max-h-[70vh]">
    <div class="w-12 h-1.5 bg-border rounded-full mx-auto mt-3 mb-2"></div>
    <div class="p-4 border-b border-border">
      <h3 class="text-textMain font-medium">Select Repository</h3>
      <div class="mt-3 relative">
        <i class="ph ph-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-textMuted"></i>
        <input type="text" placeholder="Search repos..." class="w-full bg-app border border-border rounded-lg py-2 pl-9 pr-3 text-sm text-textMain outline-none focus:border-primary">
      </div>
    </div>
    <div class="overflow-y-auto p-2">
      <button class="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-surfaceHover text-left" onclick="closeRepoDrawer()">
        <i class="ph-fill ph-check-circle text-primary"></i>
        <div>
          <div class="text-textMain text-sm">SamPrimeaux/inneranimalmedia-agentsam-dashboard</div>
          <div class="text-textMuted text-xs">main</div>
        </div>
      </button>
      <button class="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-surfaceHover text-left" onclick="closeRepoDrawer()">
        <div class="w-4 h-4 rounded-full border border-border ml-0.5"></div>
        <div>
          <div class="text-textMain text-sm">SamPrimeaux/mobiledashboard</div>
          <div class="text-textMuted text-xs">main</div>
        </div>
      </button>
    </div>
  </div>

  <script>
    // ─── State ───────────────────────────────────────
    let currentTab = 'agents';
    const SCREENS = ['agents','automations','dashboard','chat'];

    // ─── Tab Navigation ───────────────────────────────
    function switchTab(tab) {
      // Deactivate all screens
      SCREENS.forEach(s => {
        document.getElementById('screen-' + s).classList.remove('active');
      });
      // Activate target
      document.getElementById('screen-' + tab).classList.add('active');

      // Nav button states
      ['agents','automations','dashboard'].forEach(t => {
        const btn = document.getElementById('nav-' + t);
        if (btn) btn.classList.toggle('active-nav', t === tab);
      });

      // Show/hide main header (chat has its own)
      document.getElementById('main-header').style.display = tab === 'chat' ? 'none' : '';

      currentTab = tab;
      if (tab === 'dashboard') loadDashboard();
    }

    // ─── Chat ─────────────────────────────────────────
    function openChat(title, age) {
      document.getElementById('chat-title').textContent = title || 'Chat';
      switchTab('chat');
    }

    function closeChat() {
      switchTab(currentTab === 'chat' ? 'agents' : currentTab);
      // Restore nav to agents since we came from there
      switchTab('agents');
    }

    // ─── Chat inner tabs ──────────────────────────────
    function switchChatTab(name) {
      const isChat = name === 'chat';
      document.getElementById('tab-chat').className = 'px-3 py-1 rounded-md text-xs font-medium ' + (isChat ? 'bg-surface text-textMain' : 'text-textMuted');
      document.getElementById('tab-diff').className = 'px-3 py-1 rounded-md text-xs font-medium ' + (!isChat ? 'bg-surface text-textMain' : 'text-textMuted');
      document.getElementById('content-chat').classList.toggle('hidden', !isChat);
      document.getElementById('content-chat').classList.toggle('flex', isChat);
      document.getElementById('content-diff').classList.toggle('hidden', isChat);
      document.getElementById('content-diff').classList.toggle('flex', !isChat);
    }

    // ─── Repo Drawer ──────────────────────────────────
    function toggleRepoDrawer() {
      document.getElementById('repo-drawer').classList.add('open');
      document.getElementById('drawer-overlay').classList.add('open');
    }
    function closeRepoDrawer() {
      document.getElementById('repo-drawer').classList.remove('open');
      document.getElementById('drawer-overlay').classList.remove('open');
    }

    // ─── Automations accordion ────────────────────────
    function toggleAutomation(id, header) {
      const el = document.getElementById(id);
      const caret = header.querySelector('.auto-caret');
      const hidden = el.classList.contains('hidden');
      el.classList.toggle('hidden', !hidden);
      el.classList.toggle('flex', hidden);
      caret.classList.toggle('expanded', hidden);
    }

    // ─── File diff accordion ──────────────────────────
    function toggleFile(id, header) {
      const el = document.getElementById(id);
      const expanded = el.classList.contains('expanded');
      el.classList.toggle('expanded', !expanded);
      header.classList.toggle('expanded', !expanded);
    }

    // ─── Dashboard data load ──────────────────────────
    async function loadDashboard() {
      try {
        const res = await fetch('/api/health');
        const data = await res.json();
        document.getElementById('health-dot').className = 'w-2 h-2 rounded-full ' + (data.ok ? 'bg-green-400' : 'bg-red-400');
        document.getElementById('health-status').textContent = data.ok ? 'connected · ' + data.db : 'error';
        if (data.stats) {
          document.getElementById('stat-conversations').textContent = data.stats.conversations ?? '0';
          document.getElementById('stat-runs').textContent = data.stats.runs_today ?? '0';
          document.getElementById('stat-tokens').textContent = fmtNum(data.stats.tokens_today);
          document.getElementById('stat-cost').textContent = data.stats.cost_today != null ? '$' + data.stats.cost_today.toFixed(4) : '$0.00';
        }
      } catch(e) {
        document.getElementById('health-status').textContent = 'unreachable';
        document.getElementById('health-dot').className = 'w-2 h-2 rounded-full bg-red-400';
      }
    }

    function fmtNum(n) {
      if (!n) return '0';
      if (n >= 1000000) return (n/1000000).toFixed(1) + 'M';
      if (n >= 1000) return (n/1000).toFixed(1) + 'K';
      return String(n);
    }
  </script>
</body>
</html>`;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const { pathname } = url;

    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }

    const json = (data, status = 200) =>
      new Response(JSON.stringify(data), {
        status,
        headers: { 'Content-Type': 'application/json', ...cors },
      });

    // ── API Routes ────────────────────────────────────────
    if (pathname.startsWith('/api/')) {

      // GET /api/health
      if (pathname === '/api/health' && request.method === 'GET') {
        try {
          const [convRow, runsRow, telRow] = await Promise.all([
            env.DB.prepare(`SELECT COUNT(*) as c FROM agent_conversations WHERE workspace_id = 'ws_agent'`).first(),
            env.DB.prepare(`SELECT COUNT(*) as c FROM agentsam_agent_run WHERE workspace_id = 'ws_agent' AND started_at >= unixepoch() - 86400`).first(),
            env.DB.prepare(`SELECT SUM(tokens_in + tokens_out) as tokens, SUM(cost_usd) as cost FROM agent_telemetry WHERE workspace_id = 'ws_agent' AND recorded_at >= unixepoch() - 86400`).first(),
          ]);
          return json({
            ok: true,
            db: 'cc3db6f4',
            workspace: 'ws_agent',
            stats: {
              conversations: convRow?.c ?? 0,
              runs_today: runsRow?.c ?? 0,
              tokens_today: telRow?.tokens ?? 0,
              cost_today: telRow?.cost ?? 0,
            },
          });
        } catch (e) {
          return json({ ok: false, error: e.message }, 500);
        }
      }

      // GET /api/workspace
      if (pathname === '/api/workspace' && request.method === 'GET') {
        const ws = await env.DB.prepare(`
          SELECT w.*, o.name as org_name
          FROM workspaces w
          JOIN organizations o ON o.id = w.org_id
          WHERE w.id = 'ws_agent'
        `).first();
        return ws ? json({ ok: true, workspace: ws }) : json({ ok: false, error: 'not found' }, 404);
      }

      // GET /api/conversations
      if (pathname === '/api/conversations' && request.method === 'GET') {
        const { results } = await env.DB.prepare(`
          SELECT id, title, model, mode, created_at
          FROM agent_conversations
          WHERE workspace_id = 'ws_agent'
          ORDER BY created_at DESC
          LIMIT 50
        `).all();
        return json({ ok: true, conversations: results });
      }

      return json({ ok: false, error: 'not found' }, 404);
    }

    // ── Serve SPA ─────────────────────────────────────────
    return new Response(HTML, {
      headers: { 'Content-Type': 'text/html;charset=UTF-8' },
    });
  },
};
