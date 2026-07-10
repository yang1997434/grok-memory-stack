# Project breakpoints (Claude save bridge)

Claude Code `save` skill writes fixed-schema `session_latest.md` per project memory dir.
Grok keeps a parallel tree:

```
~/.grok/memory/breakpoints/<key>/session_latest.md
~/.grok/memory/breakpoints/INDEX.md
```

On **new** Grok session in a project cwd, read the matching file first.
On **resume**, conversation history wins; breakpoint is supplementary.

Do not commit personal breakpoint content with secrets/PII to this repo — only INDEX + template.
