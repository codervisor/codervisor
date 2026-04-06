#!/usr/bin/env bash
# common.sh — Shared helpers for cloud environment setup scripts
#
# Source this from per-repo setup scripts:
#   source "$(dirname "$0")/common.sh"

set -euo pipefail

log() { echo "[cloud-setup] $*"; }
warn() { echo "[cloud-setup] WARNING: $*"; }

# Skip if not running in Claude Code cloud environment
check_cloud() {
  if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
    log "Not a cloud environment, skipping cloud setup"
    exit 0
  fi
}

# Install GitHub CLI if not present
install_gh() {
  if command -v gh &>/dev/null; then
    log "gh already installed: $(gh --version | head -1)"
    return 0
  fi
  log "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt-get update -qq && apt-get install -y -qq gh > /dev/null 2>&1
  log "gh installed: $(gh --version | head -1)"
}

# Check GH_TOKEN status
check_gh_token() {
  if [ -n "${GH_TOKEN:-}" ]; then
    log "GH_TOKEN is set — authenticated GitHub access"
  else
    warn "GH_TOKEN not set — limited to public/unauthenticated access (60 req/hr)"
    warn "  Set GH_TOKEN in Claude Code environment settings for full access"
  fi
}

# Install system packages quietly
apt_install() {
  log "Installing system packages: $*"
  apt-get update -qq && apt-get install -y -qq "$@" > /dev/null 2>&1
}

# Install pnpm dependencies
pnpm_install() {
  if [ -f "pnpm-lock.yaml" ]; then
    log "Installing pnpm dependencies..."
    pnpm install --prefer-offline --silent 2>&1 | tail -3
  fi
}

# Run cargo check
cargo_check() {
  if [ -f "Cargo.toml" ]; then
    log "Running cargo check..."
    cargo check --quiet 2>&1 | tail -5
  fi
}
