#!/usr/bin/env bash
# Pull latest changes from all child repo remotes into their subtree prefixes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Optional: pull only a specific project
FILTER="${1:-}"

PROJECTS=$(node -e "
  const m = require('./.meta');
  for (const [name, url] of Object.entries(m.projects)) {
    console.log(name + ' ' + url);
  }
")

while IFS=' ' read -r name url; do
  if [ -n "$FILTER" ] && [ "$name" != "$FILTER" ]; then
    continue
  fi
  if [ ! -d "$name" ]; then
    echo "⏭  $name/ not present — run subtree-add.sh first"
    continue
  fi
  echo "⬇  Pulling $name from $url ..."
  git subtree pull --prefix="$name" "$url" main --squash -m "chore: pull latest $name"
done <<< "$PROJECTS"

echo ""
echo "Done."
