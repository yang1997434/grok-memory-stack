# E2E results (production machine)

Date: 2026-07-11 (local)

```
PASS  T1 config.toml memory/compat nested keys
PASS  T2 AGENTS.md managed block present
PASS  T2 MEMORY.md skeleton present
PASS  T3 inspect root / sub2api / keleclaw
PASS  T4 headless memory_search found canary
PASS  T5 --no-memory headless smoke
PASS  T6 qmd kb-yp search works
PASS  T7 keleclaw shared origin documented
PASS  T8 pager.toml prompt bg=dark
SUMMARY PASS=11 FAIL=0 SKIP=0
```

Canary line and e2e session groups were removed after the run.

## P1/P2 add-on (2026-07-11)

- Chinese canary `memory_search`: FOUND_ZH (PASS)
- `scaffold_entry.py --dry-run`: PASS
- Real promote to vault then deleted: schema validator pass (warn optional owner only)
- Cleaned: vault e2e file, index line, /tmp workspace memory
