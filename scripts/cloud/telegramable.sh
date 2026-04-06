#!/usr/bin/env bash
# Cloud environment setup for telegramable (TypeScript monorepo)
#
# Deps beyond base image:
#   - turbo (installed via pnpm)
#   - gh (GitHub CLI)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_cloud

log "Setting up telegramable environment..."

install_gh
check_gh_token

# Install all workspace deps (includes turbo)
pnpm_install

log "telegramable environment ready."
