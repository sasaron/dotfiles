#!/bin/bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v chezmoi >/dev/null || { echo "Install chezmoi first (brew install chezmoi)" >&2; exit 1; }
chezmoi --source "$root" apply
