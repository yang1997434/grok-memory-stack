# Architecture

## Three layers

1. **Constitution** — `~/.claude/CLAUDE.md` + `~/.claude/rules/*` (SoT). Grok loads via `compat.claude`; thin `~/.grok/AGENTS.md` only adds Grok-native protocol.
2. **Hot memory** — Grok native `~/.grok/memory/` (global + per-origin workspace). First-turn injection, `/remember`, optional `/flush`.
3. **Cold library** — Obsidian vault + `qmd` (`kb-yp`). Shared with Claude/Codex. Promote verified cross-AI facts here.

## P0 write policy

- `save_on_end = false`, `dream.enabled = false`, `compaction.memory_flush.enabled = false`
- Confirmed `/remember` only; manual `/flush`
- Promote to vault: cross-AI prefs, prod incidents, architecture decisions, reusable pitfalls, user-requested continuity

## Session vs memory

- Long per-project sessions + `/resume` / `Ctrl+S` carry conversation automatically.
- Memory is for cross-session / new-session recall, not required for resume of the same session.

## Buckets

- Default: start Grok inside a git repo → per-origin workspace memory.
- Cross-repo: cwd parent workspace (e.g. multi-repo root); label entries `[repoA + repoB]`.
- Same origin paths share a workspace (e.g. two clones of one product) — use `[component]` prefixes.

## Explicitly not done

- Dual-write everything
- Bidirectional vault↔Grok sync / bulk vault backfill (P3)
- Cloning Claude hooks into Grok (`compat.claude.hooks = false`)
