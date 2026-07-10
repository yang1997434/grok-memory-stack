# Merging into an existing `~/.grok/config.toml`

If you already have `[ui]`, marketplace, etc., append or merge only:

- `[compat.claude]`
- `[memory]` and nested tables
- `[compaction.memory_flush]`

Do not commit `auth.json` or API keys.
