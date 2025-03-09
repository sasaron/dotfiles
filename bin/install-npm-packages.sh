#!/bin/bash
# Install global npm packages from list

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_FILE="$DOTFILES_DIR/mac/npm-packages.txt"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
  echo "Error: npm is not installed. Please install Node.js first."
  exit 1
fi

# Install packages from the list
echo "Installing global npm packages..."
while IFS= read -r package || [[ -n "$package" ]]; do
  # Skip empty lines and comments
  [[ -z "$package" || "$package" =~ ^# ]] && continue
  
  echo "Installing $package..."
  npm install -g "$package"
done < "$PACKAGES_FILE"

echo "All global npm packages installed successfully!"