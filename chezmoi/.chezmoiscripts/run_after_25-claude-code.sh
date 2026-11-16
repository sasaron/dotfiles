#!/bin/bash
# Claude Code を公式のネイティブインストーラーで入れる。入れた後は Claude Code が自分で更新するので、
# ~/.local/bin/claude があれば何もしない
# （https://code.claude.com/docs/en/setup 、2026-11-16 確認）
set -euo pipefail
if [ -x "$HOME/.local/bin/claude" ]; then
  exit 0
fi
if ! curl -fsSL https://claude.ai/install.sh | bash; then
  echo "Claude Code native install failed; retry with the next chezmoi apply." >&2
  exit 1
fi
