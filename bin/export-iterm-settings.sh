#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
# カスタムフォルダから設定を読んでいるときは、プロファイルなどの実体はそちらにある。
# ~/Library/Preferences 側は一部しか持たない（2026-11-19 の実機で 29KB と 100KB）
if [ "$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true)" = "1" ]; then
  custom="$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true)"
  [ -f "$custom/com.googlecode.iterm2.plist" ] && source="$custom/com.googlecode.iterm2.plist"
fi
[ -f "$source" ] || { echo "iTerm preferences not found: $source" >&2; exit 1; }
umask 077
mkdir -p "$root/local/iterm"
target="$root/local/iterm/com.googlecode.iterm2.$(date +%Y%m%d-%H%M%S).plist"
[ ! -e "$target" ] || { echo "Backup already exists: $target" >&2; exit 1; }
cp -p "$source" "$target"
chmod 600 "$target"
echo "Exported private iTerm preferences: $target"
