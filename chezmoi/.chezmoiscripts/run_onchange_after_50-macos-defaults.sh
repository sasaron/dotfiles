#!/bin/bash
# macOS と git の設定。このファイルの内容が変わったときだけ実行される
set -euo pipefail

mkdir -p "$HOME/Desktop/capturefile"
defaults write com.apple.screencapture location "$HOME/Desktop/capturefile"
killall SystemUIServer || true

# ~/.gitconfig は chezmoi で管理していないので、ghq の設定だけを書き込む
git config --global ghq.root "$HOME/src"
