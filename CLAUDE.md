# CLAUDE.md - Dotfiles Repository Guide

## Commands
- Installation: `./install.sh`
- Package Installation: `brew bundle --file="$DOTFILEDIR/mac/Brewfile"`
- VSCode Extensions: `./bin/install-vscode-extensions.sh`
- NPM Packages: `./bin/install-npm-packages.sh`

## Code Style Guidelines
- Shell scripts: Follow POSIX standards where possible
- Use 2-space indentation for all files
- Keep lines under 100 characters
- Use snake_case for shell functions and variables
- Document any non-obvious script behavior with comments
- Prefer symlinks over copying config files
- Verify config compatibility with both macOS and Linux when possible

## Repository Structure
- `bin/`: Utility scripts
- `config/`: Configuration files to be symlinked
- `home/`: Application-specific configs
- `mac/`: macOS-specific setup files

## Error Handling
- Add error checking for critical operations
- Use set -e for important scripts to fail fast
- Always provide meaningful error messages