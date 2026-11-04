# CLAUDE.md - Dotfiles Repository Guide

## Commands
- Installation: `./bootstrap.sh` (runs `chezmoi init --apply --source <repo>`)
- Apply changes: `chezmoi diff`, then `chezmoi apply`
- Package Installation: `./bin/manage-apps.sh install`
- VSCode Extensions: `./bin/install-vscode-extensions.sh`
- NPM Packages: `./bin/install-npm-packages.sh`

## Code Style Guidelines
- Shell scripts: Follow POSIX standards where possible
- Use 2-space indentation for all files
- Keep lines under 100 characters
- Use snake_case for shell functions and variables
- Document any non-obvious script behavior with comments
- Put files for the home directory under `chezmoi/` and setup steps in
  `chezmoi/.chezmoiscripts/` as `run_onchange_` scripts
- Verify config compatibility with both macOS and Linux when possible

## Repository Structure
- `chezmoi/`: chezmoi source (`.chezmoiroot` points here). Files for `$HOME` and setup scripts
- `bin/`: Scripts called by the setup scripts, and maintenance scripts run from the repository
- `config/`: AI settings and `environment.json`
- `mac/`: Brewfile and npm package list

## Error Handling
- Add error checking for critical operations
- Use set -e for important scripts to fail fast
- Always provide meaningful error messages