#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_LC="$(uname -s | tr '[:upper:]' '[:lower:]')"

log() { printf '[dotfiles] %s\n' "$*"; }
die() { log "$*"; exit 1; }

case "$OS_LC" in
  darwin*)
    exec "${SCRIPT_DIR}/scripts/bootstrap-mac.sh" "$@"
    ;;
  linux*)
    exec "${SCRIPT_DIR}/scripts/bootstrap-linux.sh" "$@"
    ;;
  *)
    die "Unsupported OS: $OS_LC"
    ;;
esac
