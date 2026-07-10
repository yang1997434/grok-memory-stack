# Global memory (Grok curated)

> Hot layer for **Grok-as-executor**. Constitution: `~/.claude/CLAUDE.md` + rules.  
> Shared library for Claude consult + all agents: vault `~/data/knowledge-base/` (qmd `kb-yp`).  
> Keep entries short (≤2 lines). Prefer pointers over essays.

## Self-instructions (do not delete)

1. Do **not** store constitution/process here — SoT is `~/.claude/`. Here: facts, Grok-only prefs, vault pointers.
2. **Read (P1):** memory first; **also qmd** on cross-AI / prod / architecture / pitfall / conflict / 调研·决策 / thin plans. Use `qmd --index kb-yp search` (not `query`). Mix 中文 + English identifiers in queries.
3. **Promote (P2):** cross-AI prefs, verified prod incidents, multi-repo architecture, reusable pitfall/pattern, or user phrasing like 晋升/加到知识库/加入知识库/记到知识库/写进知识库/给 Claude 用 → skill `promote-to-vault` → vault file + index line → leave pointer here only.

## Grok-only

- Role: Grok executes; Claude consults on heavy planning/reasoning. Promote shared conclusions to vault.
- Sessions: one long session per project; `/rename`; Ctrl+S switch. Memory supplements new sessions, not same-session resume.
- P0 write policy remains: confirmed `/remember`; manual `/flush`; auto session-save and auto-dream off.
- Ghostty dark + pager prompt `bg=dark` for input readability.

## From vault / Claude (pointers only)

- Pitfalls: `~/.claude/rules/pitfalls.md` + vault `_LLM_Memory/global/pitfall/`
- Conventions: `ai-memory-stack/docs/conventions.md` (under `/data/Claude/ai-memory-stack` or clone)
- Stack install: `https://github.com/yang1997434/grok-memory-stack`

## Cross-project facts

- (add with /remember; one bullet per fact)

## Promote candidates

- (items waiting for vault promotion — clear after promote-to-vault)
