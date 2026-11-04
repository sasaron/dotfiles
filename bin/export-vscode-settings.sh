#!/bin/bash
set -e

DOTFILEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILEDIR/config/.vscode"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# 拡張機能の一覧は chezmoi/.chezmoidata/packages.yaml で管理する
# Export settings.json if it exists
if [ -f "$VSCODE_USER_DIR/settings.json" ]; then
  echo "Exporting settings.json..."
  cp "$VSCODE_USER_DIR/settings.json" "$CONFIG_DIR/settings.json"
fi

# Export keybindings.json if it exists
if [ -f "$VSCODE_USER_DIR/keybindings.json" ]; then
  echo "Exporting keybindings.json..."
  cp "$VSCODE_USER_DIR/keybindings.json" "$CONFIG_DIR/keybindings.json"
fi

# Export snippets if they exist
if [ -d "$VSCODE_USER_DIR/snippets" ]; then
  echo "Exporting snippets..."
  mkdir -p "$CONFIG_DIR/snippets"
  cp -R "$VSCODE_USER_DIR/snippets/"* "$CONFIG_DIR/snippets/"
fi

echo "VSCode settings export complete!"