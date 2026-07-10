#!/usr/bin/env bash
# Install Grok memory-stack thin adapter into ~/.grok/
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
GROK_HOME="${GROK_HOME:-$HOME/.grok}"
BACKUP_SUFFIX="bak-$(date +%Y%m%d%H%M%S)"

mkdir -p "$GROK_HOME/memory"

install_file() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    if ! cmp -s "$src" "$dest" 2>/dev/null; then
      cp -a "$dest" "${dest}.${BACKUP_SUFFIX}"
      echo "backed up $dest -> ${dest}.${BACKUP_SUFFIX}"
    fi
  fi
  cp -a "$src" "$dest"
  echo "installed $dest"
}

install_file "$ROOT/config/AGENTS.md" "$GROK_HOME/AGENTS.md"
if [[ ! -f "$GROK_HOME/memory/MEMORY.md" ]]; then
  install_file "$ROOT/config/MEMORY.md" "$GROK_HOME/memory/MEMORY.md"
else
  echo "skip MEMORY.md (already exists — not overwriting curated memory)"
fi
if [[ ! -f "$GROK_HOME/pager.toml" ]]; then
  install_file "$ROOT/config/pager.toml" "$GROK_HOME/pager.toml"
else
  echo "skip pager.toml (already exists)"
fi

CFG="$GROK_HOME/config.toml"
SNIPPET="$ROOT/config/config.snippet.toml"
if [[ ! -f "$CFG" ]]; then
  mkdir -p "$GROK_HOME"
  cp -a "$SNIPPET" "$CFG"
  echo "created $CFG from snippet"
else
  if grep -q '\[memory\]' "$CFG" 2>/dev/null; then
    echo "NOTE: $CFG already has [memory] — merge $SNIPPET manually if needed"
  else
    cp -a "$CFG" "${CFG}.${BACKUP_SUFFIX}"
    {
      echo ""
      echo "# --- grok-memory-stack ---"
      cat "$SNIPPET"
    } >>"$CFG"
    echo "appended snippet to $CFG (backup ${CFG}.${BACKUP_SUFFIX})"
  fi
fi

echo ""
echo "Done. Verify with:"
echo "  grok inspect --json | python3 -c \"import sys,json; d=json.load(sys.stdin); print([x['path'] for x in d.get('projectInstructions',[])])\""
echo "  bash $ROOT/scripts/e2e-verify.sh"
