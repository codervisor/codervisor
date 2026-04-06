#!/usr/bin/env bash
# Cloud environment setup for ising (Rust code graph analysis engine)
#
# Deps beyond base image:
#   - protobuf-compiler (for SCIP protobuf codegen)
#   - libsqlite3-dev (for rusqlite)
#   - gh (GitHub CLI)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

check_cloud

log "Setting up ising environment..."

# System deps for protobuf + SQLite
if ! command -v protoc &>/dev/null; then
  apt_install protobuf-compiler libsqlite3-dev
else
  log "protoc already installed"
fi

install_gh
check_gh_token

cargo_check

log "ising environment ready."
