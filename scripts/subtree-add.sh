#!/usr/bin/env bash
# Add all child repos as git subtrees.
# Run once to bootstrap, then use subtree-pull.sh / subtree-push.sh for updates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Read projects from .meta manifest
PROJECTS=$(node -e "
  const m = require('./.meta');
  for (const [name, url] of Object.entries(m.projects)) {
    console.log(name + ' ' + url);
  }
")

while IFS=' ' read -r name url; do
  if [ -d "$name" ]; then
    echo "⏭  $name/ already exists — skipping (use subtree-pull.sh to update)"
    continue
  fi
  echo "➕  Adding $name as subtree from $url ..."
  git subtree add --prefix="$name" "$url" main --squash
done <<< "$PROJECTS"

echo ""
echo "Done. All child repos added as subtrees."
