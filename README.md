# grok-memory-stack

Thin **Grok Build CLI** memory + constitution adapter for machines that already use Claude Code global config (`~/.claude/CLAUDE.md` + rules) and an Obsidian/qmd vault.

> Grok-native memory is the **hot** working memory.  
> Claude files remain the **constitution**.  
> Vault + qmd remains the **cold shared library**.

## What this installs

| Path | Role |
|------|------|
| `~/.grok/AGENTS.md` | Thin global protocol (memory waterfall, buckets, conflict priority) |
| `~/.grok/memory/MEMORY.md` | Curated global memory skeleton (only if missing) |
| `~/.grok/pager.toml` | Prompt bubble `bg=dark` (optional; skip if present) |
| `~/.grok/config.toml` snippet | `compat.claude.hooks=false` + conservative `[memory]` |

## Install

```bash
git clone https://github.com/yang1997434/grok-memory-stack.git
cd grok-memory-stack
./install.sh
```

Requirements: [Grok Build CLI](https://github.com/xai-org) installed and authenticated; optional `qmd` for vault search.

## Verify

```bash
grok inspect --json | head
bash scripts/e2e-verify.sh   # needs network + grok auth for headless canary tests
```

## Daily usage

- One long session per project; `/rename <project>`; switch with **Ctrl+S** / `/resume`.
- Remember durable facts: `/remember …` (confirm panel).
- Optional session digest: `/flush`.
- Browse: `/memory`. Escape: `/memory off` or `grok --no-memory`.

## Design docs

- [docs/architecture.md](docs/architecture.md)
- [docs/e2e-results.md](docs/e2e-results.md)

## Non-goals

- Not a full replacement for [ai-memory-stack](https://github.com/yang1997434/ai-memory-stack) Claude/Codex adapters.
- Does not copy Claude `rules/*` into every Grok context (home rules are scene-read via CLAUDE.md table).
- Does not enable Auto-Dream or session-end auto-save by default (P0).

## License

MIT
