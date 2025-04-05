#!/bin/bash
set -e

DOTFILEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$DOTFILEDIR/config/.vscode"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Export VSCode extensions
echo "Exporting VSCode extensions list..."
code --list-extensions > "$DOTFILEDIR/bin/vscode-extensions.txt"

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

# Update install script to use the exported extensions
if [ -f "$DOTFILEDIR/bin/vscode-extensions.txt" ]; then
  echo "Updating install-vscode-extensions.sh..."
  {
    echo "#!/bin/bash"
    echo ""
    echo "# Install VSCode extensions"
    echo ""
    echo "echo \"Installing VSCode extensions...\""
    echo ""
    while IFS= read -r extension; do
      echo "code --install-extension $extension"
    done < "$DOTFILEDIR/bin/vscode-extensions.txt"
    echo ""
    echo "echo \"VSCode extensions installation complete!\""
  } > "$DOTFILEDIR/bin/install-vscode-extensions.sh"
  chmod +x "$DOTFILEDIR/bin/install-vscode-extensions.sh"
fi

echo "VSCode settings export complete!"