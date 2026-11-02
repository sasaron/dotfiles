#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v brew >/dev/null || { echo "Homebrew is required" >&2; exit 1; }
export HOMEBREW_NO_AUTO_UPDATE=1
case "${1:-help}" in
  check) brew bundle check --verbose --file="$root/mac/Brewfile" ;;
  install) brew bundle install --no-upgrade --file="$root/mac/Brewfile" ;;
  update)
    brew update
    brew bundle install --file="$root/mac/Brewfile"
    ;;
  export)
    umask 077
    mkdir -p "$root/local/apps"
    brew bundle dump --force --file="$root/local/apps/Brewfile.installed"
    echo "Exported inventory to local/apps/Brewfile.installed; review before adopting."
    ;;
  *) echo "Usage: $0 {check|install|update|export}"; exit 2 ;;
esac
