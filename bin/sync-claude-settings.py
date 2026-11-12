#!/usr/bin/env python3
"""Preview or merge the dotfiles permission rules and hooks into Claude Code user settings."""
import argparse
import datetime
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RULE_KINDS = ("ask", "deny")


def hook_key(entry):
  return (entry.get("matcher", ""),
          tuple(h.get("command", "") for h in entry.get("hooks", [])))


def merge(data, desired):
  """Add missing rules and hook entries; never remove what the user already has."""
  changes = []
  permissions = data.setdefault("permissions", {})
  for kind in RULE_KINDS:
    current = permissions.setdefault(kind, [])
    for rule in desired.get("permissions", {}).get(kind, []):
      if rule not in current:
        current.append(rule)
        changes.append(f"Add {kind}: {rule}")
  hooks = data.setdefault("hooks", {})
  for event, entries in desired.get("hooks", {}).items():
    current = hooks.setdefault(event, [])
    known = {hook_key(e) for e in current}
    for entry in entries:
      if hook_key(entry) not in known:
        current.append(entry)
        changes.append(f"Add {event} hook: {entry.get('matcher', '*')}")
  return changes


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--apply", action="store_true")
  default = Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home() / ".claude")) / "settings.json"
  parser.add_argument("--config", type=Path, default=default)
  args = parser.parse_args()
  os.umask(0o077)
  target = args.config.expanduser().resolve()
  original = target.read_bytes() if target.exists() else None
  data = json.loads(original) if original is not None else {}
  desired = json.loads((ROOT / "config/ai/claude/settings.json").read_text())
  changes = merge(data, desired)
  if not changes:
    print("Already up to date")
    return
  print("\n".join(changes))
  if not args.apply:
    print("Preview only. Use --apply to save; existing rules and hooks are preserved.")
    return
  if original is not None:
    backup = ROOT / "local/ai" / datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup.mkdir(parents=True, mode=0o700)
    (backup / "claude-settings.before.json").write_bytes(original)
    print("Private backup:", backup)
  target.parent.mkdir(parents=True, exist_ok=True)
  temporary = target.with_name(target.name + ".dotfiles-tmp")
  fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
  try:
    with os.fdopen(fd, "w") as out:
      json.dump(data, out, indent=2, ensure_ascii=False)
      out.write("\n")
    # Refuse to overwrite settings changed by a concurrently running app.
    current = target.read_bytes() if target.exists() else None
    if current != original:
      raise RuntimeError("Settings changed during update; retry")
    os.replace(temporary, target)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)
  print("Saved Claude Code settings. New sessions load them.")


if __name__ == "__main__":
  main()
