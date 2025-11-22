#!/usr/bin/env bash
# Template for new helper scripts. Copy then fill in your logic.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

main() {
  log "replace me"
}

main "$@"
