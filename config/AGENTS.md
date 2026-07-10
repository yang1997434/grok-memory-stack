<!-- grok-memory-stack:start -->
# Grok global adapter (thin — do not duplicate Claude constitution)

## Role of agents on this machine

- **Grok = primary executor** (implement, debug, commit-ready work, long project sessions).
- **Claude = consultant** (deeper planning/reasoning reference when Grok's plan is thin; not the default code driver).
- Shared durable knowledge must land in **vault** so consulting Claude can retrieve it via qmd / memory index — do not leave cross-AI facts only in Grok memory.

## Constitution (SoT elsewhere)

- **Behavior rules SoT**: `~/.claude/CLAUDE.md` + `~/.claude/rules/*.md` (compat injects CLAUDE.md; scene rules: Read when CLAUDE.md table says so).
- Do not restate language / prod-auth / delivery policy here.
- Claude-only mechanisms may be unavailable — use Grok-native equivalents.

## Memory protocol

Storage: `~/.grok/memory/` (global MEMORY.md + per-workspace MEMORY.md + session logs).  
Vault: `~/data/knowledge-base/` · qmd: `--index kb-yp -c kb` · schema: `ai-memory-stack/docs/conventions.md`.

### Self-rules

1. **Not the constitution.** Facts, Grok-only prefs, vault pointers only.
2. **Read waterfall (P1)** — see below.
3. **Write waterfall** — confirmed `/remember` or explicit「记住…」; manual `/flush` for digests. Auto session-save / dream stay off in config.
4. **Promote (P2)** — when criteria match **or** user says any of: 晋升 / 加到知识库 / 加入知识库 / 加入了知识库 / 记到知识库 / 写进知识库 / 同步到 vault / 给 Claude 用 / promote to vault — run skill `promote-to-vault` (or its steps). Never promote raw session logs.

### Read waterfall (P1)

**Always start** from injected / `memory_search` Grok memory.

**Also run vault qmd (do not wait for a total miss)** when any of:

| Trigger | Why |
|---------|-----|
| Cross-AI continuity (Claude will consult later) | Shared SoT is vault |
| Production / remote / money-path / credentials-adjacent | High cost of wrong memory |
| Architecture / ADR / multi-repo decisions | Need audited notes |
| Known pitfall / 「之前踩过」「我们定过」 | Vault has schema pitfalls |
| Grok memory hits but **conflicts with repo evidence** | Evidence wins; re-check vault |
| User asks about history / research / 调研 / 决策 | Cold library |
| Low confidence or thin plan before large edits | Pull prior art |

Commands (prefer BM25; never default to `qmd query` on CPU-only hosts):

```bash
qmd --index kb-yp search "<q>" -c kb -n 5
# semantic if BM25 empty: qmd --index kb-yp vsearch "<q>" -c kb -n 5
# fallback: rg -i "<q>" ~/data/knowledge-base/
```

**Evidence order:** live user instruction → constitution → **current code/runtime** → vault verified → Grok curated MEMORY → session summaries (clues only).

Chinese queries: include both Chinese keywords and any English identifiers (paths, tool names) — FTS may split CJK poorly.

### Write & promote (P2)

**Write to Grok memory** when: project experience, Grok UX prefs, short working facts, pointers.

**Must promote to vault** (after user confirm unless user already said「记到知识库/晋升」):

- Long-term prefs every agent should follow  
- Verified production incident conclusions  
- Architecture decisions affecting other repos/agents  
- Reusable pitfall / pattern  
- User wants Claude consulting continuity  

**Promote steps** (or invoke skill `promote-to-vault`):

1. Search vault first (no duplicate).  
2. Write one file under `~/data/knowledge-base/_LLM_Memory/global/<type>/` with full frontmatter (see conventions).  
3. Add ≤150 char index line to vault `_LLM_Memory/global/MEMORY.md`.  
4. In Grok MEMORY: replace full text with pointer `- [title] — vault: path or id` (no dual full body).  
5. Never put credentials in either store.

Helper: `python3 ~/.grok/skills/promote-to-vault/scripts/scaffold_entry.py --type pitfall --title "..." --description "..."`

### Buckets

- Default: start Grok **inside a project repo** → per-origin workspace memory.  
- Cross-repo only: cwd multi-repo root; label `[repoA + repoB]`.  
- `keleclaw-api` + `keleclaw-api-marketing` share origin → product-family bucket; prefix `[api]` / `[marketing]`.

### Sessions (executor lifestyle)

- Prefer **one long session per project** + `/rename <project>`; switch with **Ctrl+S** / `/resume`.  
- Auto-compact keeps long sessions usable; still `/remember` durable conclusions that must survive a *new* session or Claude consult.  
- Escape: `grok --no-memory` or `/memory off`.

## Grok-only notes

- Prompt contrast: `~/.grok/pager.toml` → `scrollback.blocks.prompt.bg = "dark"`.  
- Ghostty: prefer dark theme for TUI readability.  
- Stack repo: `https://github.com/yang1997434/grok-memory-stack`
<!-- grok-memory-stack:end -->
