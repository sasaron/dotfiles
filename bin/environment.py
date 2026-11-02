#!/usr/bin/env python3
"""Display or apply the components declared in config/environment.json."""
import argparse
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("action", choices=("plan", "apply"))
  parser.add_argument("components", nargs="*", help="Component names; default is all")
  args = parser.parse_args()
  data = json.loads((ROOT / "config/environment.json").read_text())
  components = data["components"]
  known = {item["name"] for item in components}
  unknown = set(args.components) - known
  if unknown:
    parser.error("unknown components: " + ", ".join(sorted(unknown)))
  for item in components:
    if args.components and item["name"] not in args.components:
      continue
    print(item["name"] + ": " + item["source"], flush=True)
    if args.action == "apply":
      command = [str(ROOT / item["apply"][0]), *item["apply"][1:]]
      subprocess.run(command, cwd=ROOT, check=True)
  if args.action == "plan":
    print("Plan lists declared components; it is not an installed-state diff.")


if __name__ == "__main__":
  try:
    main()
  except (OSError, subprocess.CalledProcessError, ValueError, KeyError) as exc:
    print("Environment operation failed:", exc, file=sys.stderr)
    sys.exit(1)
