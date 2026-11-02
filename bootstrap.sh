#!/bin/bash
set -euo pipefail

repository="https://github.com/sasaron/dotfiles.git"
destination="${DOTFILES_DIR:-$HOME/src/github.com/sasaron/dotfiles}"

if [ "$(uname -s)" != Darwin ]; then
  echo "This setup currently supports macOS only." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools are required. Follow the installer, then rerun this command." >&2
  xcode-select --install || true
  exit 1
fi
if ! git --version >/dev/null 2>&1; then
  echo "Git is unavailable. Install Xcode Command Line Tools and retry." >&2
  exit 1
fi

if [ -e "$destination" ] || [ -L "$destination" ]; then
  if ! git -C "$destination" rev-parse --show-toplevel >/dev/null 2>&1 ||
     [ "$(git -C "$destination" rev-parse --show-toplevel)" != "$(cd "$destination" && pwd -P)" ]; then
    echo "Destination exists but is not a repository root: $destination" >&2
    exit 1
  fi
  origin="$(git -C "$destination" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
    https://github.com/sasaron/dotfiles|https://github.com/sasaron/dotfiles.git|git@github.com:sasaron/dotfiles.git|git@github.com:sasaron/dotfiles) ;;
    *) echo "Unexpected origin at $destination; refusing to run its installer." >&2; exit 1 ;;
  esac
  echo "Using existing checkout without changing its Git state: $destination"
else
  mkdir -p "$(dirname "$destination")"
  git clone "$repository" "$destination"
fi

if [ ! -f "$destination/install.sh" ] || [ ! -f "$destination/bin/install-ai-skills.sh" ]; then
  echo "Setup files are missing. Update the checkout after reviewing its local changes." >&2
  exit 1
fi

echo "Running setup from $destination"
bash "$destination/install.sh"
bash "$destination/bin/install-ai-skills.sh"
echo "Bootstrap complete. Restart your terminal."
