#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for base in "${CODEX_HOME:-$HOME/.codex}/skills" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"; do
  mkdir -p "$base"
  for name in github-gh write-docs; do
    source="$root/skills/$name"
    target="$base/$name"
    [ -f "$source/SKILL.md" ] || { echo "Missing: $source/SKILL.md" >&2; exit 1; }
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
      echo "Already linked: $target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
      echo "Already exists; left unchanged: $target" >&2
    else
      ln -s "$source" "$target"
      echo "Installed: $target"
    fi
  done
done
