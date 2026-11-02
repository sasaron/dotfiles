#!/usr/bin/env python3
"""Preview or merge the dotfiles MCP definitions into Claude Code user config."""
import argparse
import datetime
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--apply", action="store_true")
  parser.add_argument("--remove-github", action="store_true",
                      help="Remove the user GitHub MCP; use the github-gh skill instead")
  parser.add_argument("--config", type=Path, default=Path.home() / ".claude.json")
  args = parser.parse_args()
  os.umask(0o077)
  target = args.config.expanduser().resolve()
  original = target.read_bytes() if target.exists() else None
  data = json.loads(original) if original is not None else {}
  before = data.get("mcpServers", {})
  desired = json.loads((ROOT / "config/ai/claude/mcp.json").read_text())["mcpServers"]
  merged = dict(before)
  for name, spec in desired.items():
    # Preserve machine-specific auth, headers and env on existing servers.
    old = before.get(name, {})
    updated = {**old, **spec}
    if "env" in old or "env" in spec:
      updated["env"] = {**old.get("env", {}), **spec.get("env", {})}
    if spec.get("type") == "http":
      for key in ("command", "args"):
        updated.pop(key, None)
    if updated != old:
      print("Update" if name in before else "Add", name)
    merged[name] = updated
  for name in ("awslabs.cdk-mcp-server", "cdk-mcp-server"):
    if name in merged:
      merged.pop(name)
      print("Remove deprecated", name)
  if args.remove_github and "github" in merged:
    merged.pop("github")
    print("Remove github MCP (use gh CLI)")
  if merged == before:
    print("Already up to date")
    return
  if not args.apply:
    print("Preview only. Use --apply to save; project-scoped settings are preserved.")
    return
  data["mcpServers"] = merged
  if original is not None:
    backup = ROOT / "local/ai" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup.mkdir(parents=True, mode=0o700)
    (backup / "claude-user-config.before.json").write_bytes(original)
    print("Private backup:", backup)
  target.parent.mkdir(parents=True, exist_ok=True)
  temporary = target.with_name(target.name + ".dotfiles-tmp")
  fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
  try:
    with os.fdopen(fd, "w") as out:
      json.dump(data, out, indent=2)
      out.write("\n")
    # Refuse to overwrite a configuration changed by a concurrently running app.
    current = target.read_bytes() if target.exists() else None
    if current != original:
      raise RuntimeError("Config changed during update; retry after closing Claude Code")
    os.replace(temporary, target)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)
  print("Saved MCP settings. Restart Claude Code and check /mcp.")


if __name__ == "__main__":
  main()
