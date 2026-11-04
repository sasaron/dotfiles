#!/bin/bash
# macOS と git の設定。値が違うときだけ書き込む
set -euo pipefail

capture_dir="$HOME/Desktop/capturefile"
mkdir -p "$capture_dir"
if [ "$(defaults read com.apple.screencapture location 2>/dev/null || true)" != "$capture_dir" ]; then
  defaults write com.apple.screencapture location "$capture_dir"
  killall SystemUIServer || true
fi

# ~/.gitconfig は chezmoi で管理していないので、ghq の設定だけを書き込む
if [ "$(git config --global --get ghq.root || true)" != "$HOME/src" ]; then
  git config --global ghq.root "$HOME/src"
fi
