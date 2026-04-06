#!/usr/bin/env bash
# Cloud environment setup for the codervisor meta-repo
#
# When opened at the meta-repo root, installs shared tooling
# and optionally bootstraps all sub-repos.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_cloud

log "Setting up codervisor meta-repo environment..."

# System deps needed across sub-repos
apt_install protobuf-compiler libpq-dev libsqlite3-dev

install_gh
check_gh_token

# Install meta-repo node deps (sync scripts)
if [ -f "package.json" ]; then
  log "Installing meta-repo node dependencies..."
  npm install --prefer-offline --silent 2>&1 | tail -3
fi

log "codervisor meta-repo environment ready."
