#!/usr/bin/env python3
"""Export selected user configuration; never copy authentication or session files."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parent.parent
FILES = ((".claude", "settings.json"), (".claude", "CLAUDE.md"),
         (".codex", "config.toml"), (".codex", "AGENTS.md"))


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--home", type=Path, default=Path.home())
  parser.add_argument("--output", type=Path, default=ROOT / "local" / "ai")
  args = parser.parse_args()
  # A unique directory preserves previous exports. Private files remain local.
  os.umask(0o077)
  stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
  dest = args.output / stamp
  dest.mkdir(parents=True, mode=0o700)
  codex = Path(os.environ.get("CODEX_HOME", str(args.home / ".codex")))
  for directory, name in FILES:
    source = (codex if directory == ".codex" else args.home / directory) / name
    if source.is_file():
      target = dest / directory / name
      target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
      shutil.copyfile(source, target)
      target.chmod(0o600)
      print("Exported", directory + "/" + name)
  # Extract MCP definitions only; .claude.json also contains unrelated account data.
  user_config = args.home / ".claude.json"
  if user_config.is_file():
    user = json.loads(user_config.read_text())
    mcp = {"mcpServers": user.get("mcpServers", {}), "projects": {}}
    for project, settings in user.get("projects", {}).items():
      if isinstance(settings, dict) and settings.get("mcpServers"):
        mcp["projects"][project] = {"mcpServers": settings["mcpServers"]}
    target = dest / "claude-mcp.private.json"
    target.write_text(json.dumps(mcp, indent=2) + "\n")
    target.chmod(0o600)
    print("Exported Claude MCP definitions (private)")
  # Shared export intentionally excludes hooks, permissions, MCP, env and plugins.
  shared = ROOT / "config" / "ai" / "claude"
  source = args.home / ".claude" / "settings.json"
  if source.is_file():
    data = json.loads(source.read_text())
    keys = ("model", "effortLevel", "verbose")
    safe = {key: data[key] for key in keys
            if key in data and isinstance(data[key], (str, bool, int, float))}
    shared.mkdir(parents=True, exist_ok=True)
    (shared / "settings.json").write_text(json.dumps(safe, indent=2) + "\n")
  print("Private backup:", dest)
  print("Review shared config/ai before committing; custom model names may be private.")


if __name__ == "__main__":
  try:
    main()
  except (OSError, ValueError) as error:
    print("Export failed:", error, file=sys.stderr)
    sys.exit(1)
