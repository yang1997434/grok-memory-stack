# Global memory (Grok curated)

> Hot layer for Grok only. Constitution lives in `~/.claude/CLAUDE.md` + rules.
> Shared long-form knowledge lives in vault `~/data/knowledge-base/` (qmd `kb-yp`).
> Keep entries short (≤2 lines). Prefer pointers over essays.

## Self-instructions (do not delete)

1. Do **not** store constitution/process here — SoT is `~/.claude/`. Here: facts, Grok-only prefs, vault pointers.
2. Retrieval: memory first → on miss/conflict/high-value, `qmd --index kb-yp search "…" -c kb -n 5` (not `qmd query`).
3. Promote to vault when cross-AI reusable + verified (or user asks): pitfall/pattern/decision; then leave a pointer, don't dual-write full text.

## Grok-only

- Prefer one long session per project; `/rename` by project; switch sessions with Ctrl+S. Memory is secondary to resume for same-project continuity.
- Ghostty: use dark theme for Grok TUI; pager prompt `bg = "dark"` if input bar is washed out.
- P0 write policy: confirmed `/remember` only; manual `/flush`; auto session-save and auto-dream are off in config.

## From vault / Claude (pointers only)

- Pitfalls library: `~/.claude/rules/pitfalls.md` + vault `_LLM_Memory/global/pitfall/`
- Memory architecture notes: vault `2026-07-02-记忆系统盘点与修复.md`, `2026-07-09-Codex能力对齐调研-记忆与skills系统对比与迁移方案.md`
- Fleet/workflow feedback archived 2026-07-10 — do not revive multi-agent fleet defaults without checking vault feedback_workflow_fleet_defaults

## Cross-project facts

- (add with /remember; one bullet per fact)

## Promote candidates

- (move verified cross-AI items to vault; leave pointer here)
