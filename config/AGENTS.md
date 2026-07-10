<!-- grok-memory-stack:start -->
# Grok global adapter (thin — do not duplicate Claude constitution)

## Constitution (SoT elsewhere)

- **Behavior rules SoT**: `~/.claude/CLAUDE.md` + `~/.claude/rules/*.md` (already injected via compat when available).
- **Do not restate** language / prod-auth / delivery policy here. If a scene rule is not already in context, **Read** the file listed in CLAUDE.md's rules table before acting.
- Claude-only mechanisms (Skill tool mutual calls, AskUserQuestion UI, `_commit_helper` Claude hooks) may be unavailable — use Grok-native equivalents (skills list, `ask_user_question` if present, normal git commit flow).

## Memory protocol (Grok-native hot layer)

Storage: `~/.grok/memory/` (global MEMORY.md + per-workspace MEMORY.md + session logs).

### Self-rules (always)

1. **This is not the constitution.** Do not store process/policy that belongs in CLAUDE.md/rules. Here: facts, project experience, Grok-only prefs, and short pointers.
2. **Read waterfall**: use injected/searchable Grok memory first → on miss, low confidence, conflict with repo evidence, or high-value topics (prod incidents, cross-AI continuity, architecture decisions, known pitfalls) run `qmd --index kb-yp search "<q>" -c kb -n 5` (BM25; never default to `qmd query`) against vault `~/data/knowledge-base/`. Code/runtime evidence beats memory; vault verified facts beat Grok session fluff.
3. **Write waterfall (P0)**: durable facts only via user-confirmed `/remember` (or explicit “记住…”). Manual `/flush` for session digests. Do **not** auto-promote session noise. **Promote to vault** when: cross-AI preference, verified prod incident, cross-repo architecture decision, reusable pitfall/pattern, or user explicitly wants Claude/Codex continuity — then write vault schema and leave a short pointer here.

### Buckets

- Default: start Grok **inside a project repo** → per-origin workspace memory.
- Cross-repo coordination only: cwd `/data/Claude` (label entries `[repoA + repoB]`).
- `keleclaw-api` and `keleclaw-api-marketing` share origin → **one product-family workspace**; prefix entries `[api]` / `[marketing]`.

### Conflict priority

1. Live user instruction  
2. Constitution (CLAUDE.md / rules / repo AGENTS)  
3. Current code & runtime evidence  
4. Vault verified knowledge  
5. Grok curated global/workspace MEMORY  
6. Grok session summaries (clues only — re-verify)

## Grok-only notes

- Session UX: prefer **one long session per project** + `/rename <project>`; switch with **Ctrl+S** / `/resume`. Auto-compact keeps long sessions usable.
- Prompt contrast: `~/.grok/pager.toml` uses `scrollback.blocks.prompt.bg = "dark"` (Ghostty light themes washed out light bubbles).
- Vault path: `~/data/knowledge-base/`; qmd index `kb-yp`, collection `kb`.
- Escape hatch: `grok --no-memory` or `/memory off` for a session.
<!-- grok-memory-stack:end -->
