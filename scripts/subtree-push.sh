#!/usr/bin/env bash
# Push changes from subtree prefixes back to their upstream remotes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Optional: push only a specific project
FILTER="${1:-}"
# Optional: target branch (default: main)
BRANCH="${2:-main}"

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
    echo "⏭  $name/ not present — skipping"
    continue
  fi
  echo "⬆  Pushing $name to $url ($BRANCH) ..."
  git subtree push --prefix="$name" "$url" "$BRANCH"
done <<< "$PROJECTS"

echo ""
echo "Done."
