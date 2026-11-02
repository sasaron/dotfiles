#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
[ -f "$source" ] || { echo "iTerm preferences not found: $source" >&2; exit 1; }
umask 077
mkdir -p "$root/local/iterm"
target="$root/local/iterm/com.googlecode.iterm2.$(date +%Y%m%d-%H%M%S).plist"
[ ! -e "$target" ] || { echo "Backup already exists: $target" >&2; exit 1; }
cp -p "$source" "$target"
chmod 600 "$target"
echo "Exported private iTerm preferences: $target"
