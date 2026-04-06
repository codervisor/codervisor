#!/usr/bin/env bash
# Bootstrap shared config from codervisor/codervisor into the current repo.
#
# Usage (from a child repo root):
#   curl -fsSL https://raw.githubusercontent.com/codervisor/codervisor/main/scripts/bootstrap.sh | bash
#
# Or run locally:
#   bash /path/to/codervisor/scripts/bootstrap.sh
#
# What it does:
#   1. Downloads CLAUDE.md and CONTRIBUTING.md from the meta-repo
#   2. Downloads the appropriate CI caller workflow
#   3. Downloads shared hooks (commit-msg, .claude/settings.json)
#
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/codervisor/codervisor/main"

echo "═══════════════════════════════════════════"
echo "  codervisor shared config bootstrap"
echo "═══════════════════════════════════════════"
echo ""

# Detect project type
if [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="rust"
  echo "Detected: Rust project"
elif [ -f "package.json" ]; then
  PROJECT_TYPE="typescript"
  echo "Detected: TypeScript project"
elif [ -f "lakefile.lean" ] || [ -f "lean-toolchain" ]; then
  PROJECT_TYPE="lean"
  echo "Detected: Lean project"
else
  PROJECT_TYPE="unknown"
  echo "Warning: could not detect project type"
fi

echo ""

# Download shared files
echo "Fetching shared files..."
curl -fsSL "$BASE_URL/CLAUDE.md" -o CLAUDE.md
echo "  ✓ CLAUDE.md"

curl -fsSL "$BASE_URL/CONTRIBUTING.md" -o CONTRIBUTING.md
echo "  ✓ CONTRIBUTING.md"

# Download CI caller workflow
mkdir -p .github/workflows
if [ "$PROJECT_TYPE" = "rust" ]; then
  curl -fsSL "$BASE_URL/templates/callers/ci.yml.rust" -o .github/workflows/ci.yml
  echo "  ✓ .github/workflows/ci.yml (Rust → codervisor/codervisor)"
elif [ "$PROJECT_TYPE" = "typescript" ]; then
  curl -fsSL "$BASE_URL/templates/callers/ci.yml.typescript" -o .github/workflows/ci.yml
  echo "  ✓ .github/workflows/ci.yml (TypeScript → codervisor/codervisor)"
else
  echo "  ⏭ Skipped CI workflow (unknown project type)"
fi

# Download hooks
mkdir -p hooks
curl -fsSL "$BASE_URL/hooks/commit-msg" -o hooks/commit-msg
chmod +x hooks/commit-msg
echo "  ✓ hooks/commit-msg"

mkdir -p .claude
curl -fsSL "$BASE_URL/hooks/.claude/settings.json" -o .claude/settings.json
echo "  ✓ .claude/settings.json"

echo ""
echo "Done! Review the changes with 'git diff' before committing."
echo ""
echo "To keep shared config up to date, re-run this script or add"
echo "a CI step that calls the reusable workflows from codervisor/codervisor."
