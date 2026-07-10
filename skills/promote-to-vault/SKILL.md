---
name: promote-to-vault
description: >
  Promote a curated Grok memory fact into the shared Obsidian vault
  (_LLM_Memory/global) with proper schema, index line, and leave a pointer
  in Grok MEMORY.md. Use when user wants shared library write — any of:
  晋升/晋升到知识库/加到知识库/加入知识库/加入了知识库/记到知识库/写进知识库/
  同步到 vault/给 Claude 用/promote to vault / add to knowledge base.
  Also for cross-AI pitfall, verified prod incident, architecture decisions.
  Do NOT use for Grok-only UI prefs or unverified notes.
---

# promote-to-vault

Promote **one** curated fact from Grok hot memory → vault cold library so Claude
(consult) and other agents can retrieve it.

## Preconditions

- Source is **curated** global/workspace `MEMORY.md` text (or user-supplied fact),
  **never** raw session logs / auto-flush dumps.
- Vault root: `~/data/knowledge-base/` (override with env `VAULT_PATH`).
- Schema: `ai-memory-stack/docs/conventions.md` if present.

## Steps

1. **Dedupe search**
   ```bash
   qmd --index kb-yp search "<title or keywords>" -c kb -n 5
   ```
   If an active entry exists → **update that file** + refresh index line; do not fork duplicates.

2. **Choose type**  
   `feedback | pitfall | pattern | claude | infra | user`  
   - Recurring error → `pitfall` (requires trigger/checklist/remedy)  
   - Reusable decision with ≥2 reuse evidence → `pattern` (else `candidate`)  
   - Tooling experience → `claude` (historical name; all AI platforms OK)  
   - Host/network → `infra`  
   - Personal preference → `user` / `feedback`

3. **Scaffold file** (preferred helper):
   ```bash
   python3 ~/.grok/skills/promote-to-vault/scripts/scaffold_entry.py \
     --type pitfall \
     --title "short_id_or_title" \
     --description "one-line hook for retrieval" \
     --body-file /tmp/body.md
   ```
   Or write manually under  
   `$VAULT/_LLM_Memory/global/<type>/<id>.md`  
   with required frontmatter (`id,name,description,type,status,created,last_modified_at,last_modified_by`).

4. **Index line** in `$VAULT/_LLM_Memory/global/MEMORY.md`  
   `- [name](type/file.md) — hook` ≤150 chars.  
   Place under the correct `## type` section.

5. **Pointerize Grok memory**  
   In `~/.grok/memory/MEMORY.md` (and workspace MEMORY if needed), replace the full fact with:
   ```markdown
   - [name] — vault: _LLM_Memory/global/<type>/<id>.md
   ```
   Remove from `## Promote candidates` if listed.

6. **Validate** (if script available):
   ```bash
   python3 /data/Claude/ai-memory-stack/core/scripts/validate-memory-schema.py \
     --dir ~/data/knowledge-base/_LLM_Memory/global || true
   ```

7. **Report to user**: path written, index line, Grok pointer updated.  
   Suggest `qmd` reindex if hooks do not run:  
   `qmd --index kb-yp update` (or project-specific update command).

## Hard rules

- No credentials/tokens in vault or Grok memory.
- One fact per file; update-in-place over duplicate.
- User confirm before write unless they already ordered 晋升/记到知识库.
- `last_modified_by: grok` (or username) on new files.
