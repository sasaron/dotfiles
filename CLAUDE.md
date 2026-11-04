# CLAUDE.md - Dotfiles Repository Guide

## Commands
- New Mac: `./bootstrap.sh` (runs `chezmoi init --apply --source <repo>`)
- Apply the declared environment: `chezmoi apply` (idempotent; preview with `chezmoi diff`)

## Code Style Guidelines
- Shell scripts: Follow POSIX standards where possible
- Use 2-space indentation for all files
- Keep lines under 100 characters
- Use snake_case for shell functions and variables
- Document any non-obvious script behavior with comments
- Put files for the home directory under `chezmoi/`. Write setup steps as `run_` scripts in
  `chezmoi/.chezmoiscripts/` that check the current state, install only what is missing,
  and exit non-zero on any failure. Declare package lists in `chezmoi/.chezmoidata/`
- Verify config compatibility with both macOS and Linux when possible

## Repository Structure
- `chezmoi/`: chezmoi source (`.chezmoiroot` points here). Files for `$HOME` and setup scripts
- `bin/`: Export scripts and helpers called by the setup scripts
- `config/`: AI settings, including the Claude Code MCP servers
- `mac/`: Brewfile

## Error Handling
- Add error checking for critical operations
- Use set -e for important scripts to fail fast
- Always provide meaningful error messages