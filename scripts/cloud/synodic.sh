#!/usr/bin/env bash
# Cloud environment setup for synodic (Rust + Vite governance framework)
#
# Deps beyond base image:
#   - libpq-dev (PostgreSQL client libs for sqlx)
#   - libsqlite3-dev (SQLite for sqlx)
#   - gh (GitHub CLI)
#   - pnpm deps for frontend + docs

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_cloud

log "Setting up synodic environment..."

# System deps for sqlx (postgres + sqlite)
apt_install libpq-dev libsqlite3-dev

install_gh
check_gh_token

# Node deps (frontend, docs, CLI wrapper)
pnpm_install

# Build synodic binary for L2 governance hooks
if [ -d "rust" ] && [ ! -f "rust/target/debug/synodic" ]; then
  log "Building synodic binary (debug) for L2 intercept hooks..."
  (cd rust && cargo build --quiet 2>&1 | tail -5)
else
  log "Synodic binary already built or no rust/ directory"
fi

log "synodic environment ready."
