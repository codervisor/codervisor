#!/usr/bin/env bash
# Publish shared config files from this meta-repo to all child repos via GitHub API.
#
# Usage:
#   ./scripts/publish-to-children.sh                 # all repos, opens PRs
#   ./scripts/publish-to-children.sh synodic          # single repo
#   ./scripts/publish-to-children.sh --direct          # push to main (no PR)
#
# Prerequisites:
#   - gh CLI authenticated (gh auth login)
#   - Push access to all target repos
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

OWNER="codervisor"
BRANCH_PREFIX="chore/sync-shared-config"
DIRECT_PUSH=false
FILTER=""

# Parse args
for arg in "$@"; do
  case "$arg" in
    --direct) DIRECT_PUSH=true ;;
    --help|-h)
      echo "Usage: $0 [--direct] [repo-name]"
      echo "  --direct   Push directly to main instead of opening PRs"
      echo "  repo-name  Only publish to this specific repo"
      exit 0
      ;;
    *) FILTER="$arg" ;;
  esac
done

# Read project list from .meta
PROJECTS=$(node -e "
  const m = JSON.parse(require('fs').readFileSync('./.meta', 'utf8'));
  for (const name of Object.keys(m.projects)) {
    console.log(name);
  }
")

# Map repos to their CI workflow type
ci_workflow_for() {
  case "$1" in
    stiglab|ising) echo "rust" ;;
    synodic|telegramable) echo "typescript" ;;
    *) echo "none" ;;
  esac
}

# Shared files that go to ALL repos
SHARED_FILES=(CLAUDE.md CONTRIBUTING.md)

publish_repo() {
  local repo="$1"
  local ci_type
  ci_type=$(ci_workflow_for "$repo")

  echo ""
  echo "═══════════════════════════════════════════"
  echo "  Publishing to $OWNER/$repo"
  echo "═══════════════════════════════════════════"

  # Determine target branch
  local target_branch
  if $DIRECT_PUSH; then
    target_branch="main"
  else
    target_branch="${BRANCH_PREFIX}-$(date +%Y%m%d)"

    # Check if branch already exists
    if gh api "repos/$OWNER/$repo/git/ref/heads/$target_branch" &>/dev/null 2>&1; then
      echo "⏭  Branch $target_branch already exists — skipping (delete it first to re-run)"
      return 0
    fi

    # Create branch from main
    local main_sha
    main_sha=$(gh api "repos/$OWNER/$repo/git/ref/heads/main" --jq '.object.sha')
    gh api "repos/$OWNER/$repo/git/refs" \
      -f "ref=refs/heads/$target_branch" \
      -f "sha=$main_sha" > /dev/null
    echo "✓  Created branch $target_branch"
  fi

  # Push shared files
  local files_pushed=()
  for file in "${SHARED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
      echo "⏭  $file not found locally — skipping"
      continue
    fi
    push_file "$repo" "$target_branch" "$file" "$file"
    files_pushed+=("$file")
  done

  # Push the CI caller workflow (thin wrapper that calls reusable workflow in this repo)
  if [ "$ci_type" = "rust" ] && [ -f "templates/callers/ci.yml.rust" ]; then
    push_file "$repo" "$target_branch" "templates/callers/ci.yml.rust" ".github/workflows/ci.yml"
    files_pushed+=(".github/workflows/ci.yml")
  elif [ "$ci_type" = "typescript" ] && [ -f "templates/callers/ci.yml.typescript" ]; then
    push_file "$repo" "$target_branch" "templates/callers/ci.yml.typescript" ".github/workflows/ci.yml"
    files_pushed+=(".github/workflows/ci.yml")
  fi

  # Push hooks
  if [ -f "hooks/commit-msg" ]; then
    push_file "$repo" "$target_branch" "hooks/commit-msg" "hooks/commit-msg"
    files_pushed+=("hooks/commit-msg")
  fi
  if [ -f "hooks/.claude/settings.json" ]; then
    push_file "$repo" "$target_branch" "hooks/.claude/settings.json" ".claude/settings.json"
    files_pushed+=(".claude/settings.json")
  fi

  # Create PR if not direct push
  if ! $DIRECT_PUSH; then
    local body
    body="## Summary

Automated sync of shared configuration from [codervisor/codervisor](https://github.com/codervisor/codervisor).

### Files synced
$(printf '- \`%s\`\n' "${files_pushed[@]}")

## Test plan

- [ ] Review diff for any repo-specific overrides that should be preserved
- [ ] CI passes"

    gh pr create \
      --repo "$OWNER/$repo" \
      --head "$target_branch" \
      --base main \
      --title "chore: sync shared config from meta-repo" \
      --body "$body"

    echo "✓  PR created in $OWNER/$repo"
  else
    echo "✓  Pushed directly to main in $OWNER/$repo"
  fi
}

push_file() {
  local repo="$1"
  local branch="$2"
  local local_path="$3"
  local remote_path="$4"

  local content
  content=$(base64 -w 0 < "$local_path" 2>/dev/null || base64 < "$local_path")

  # Check if file already exists (need its SHA for update)
  local existing_sha=""
  existing_sha=$(gh api "repos/$OWNER/$repo/contents/$remote_path?ref=$branch" --jq '.sha' 2>/dev/null || echo "")

  local api_args=(
    -X PUT
    "repos/$OWNER/$repo/contents/$remote_path"
    -f "message=chore: sync $remote_path from meta-repo"
    -f "content=$content"
    -f "branch=$branch"
  )

  if [ -n "$existing_sha" ]; then
    api_args+=(-f "sha=$existing_sha")
  fi

  gh api "${api_args[@]}" > /dev/null
  echo "  ✓  $remote_path"
}

# Run
for repo in $PROJECTS; do
  if [ -n "$FILTER" ] && [ "$repo" != "$FILTER" ]; then
    continue
  fi
  publish_repo "$repo"
done

echo ""
echo "═══════════════════════════════════════════"
echo "  Done!"
echo "═══════════════════════════════════════════"
