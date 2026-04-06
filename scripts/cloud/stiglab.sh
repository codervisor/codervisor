#!/usr/bin/env bash
# Cloud environment setup for stiglab (Rust + React orchestration platform)
#
# Deps beyond base image:
#   - libpq-dev (PostgreSQL client libs for sqlx)
#   - libsqlite3-dev (SQLite for sqlx)
#   - gh (GitHub CLI)
#   - pnpm deps for frontend

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_cloud

log "Setting up stiglab environment..."

# System deps for sqlx (postgres + sqlite)
apt_install libpq-dev libsqlite3-dev

install_gh
check_gh_token

# Frontend deps
if [ -d "packages/stiglab-ui" ]; then
  pnpm_install
fi

cargo_check

log "stiglab environment ready."
