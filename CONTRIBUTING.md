# Contributing

## Overview
- Dotfiles live in `stow/<platform>` and are applied via GNU Stow. Bootstrap scripts install prerequisites and then stow `common` plus the platform package.
- Entry points: `install.sh` (auto-selects platform), `scripts/bootstrap-linux.sh`, `scripts/bootstrap-mac.sh`.
- Helper scripts sit in `scripts/`; use `scripts/_template.sh` when adding new ones.

## Quickstart
- Clone and run `./install.sh` to set up your machine.
- Before opening a PR, run `make lint check` to catch lint/syntax issues.
- Use dry-run Stow to spot conflicts: `make stow-linux` or `make stow-mac`.

## Adding packages or installers
- Linux (apt): edit `scripts/bootstrap-linux.sh`. Append packages to the arrays in `install_packages_apt`, or add a dedicated function if the tool needs extra steps (repo keys, services, groups).
- macOS: keep bootstrap minimal; prefer Homebrew installs in a small helper if you add them.
- Keep installers idempotent: check for presence, use `-y` flags, and avoid prompts.
- Log clearly with `log "message"` so automation output is easy to skim.

## Editing dotfiles
- Keep changes small and mirror existing ordering to reduce noisy diffs.
- If you add new stow packages, keep platform-specific files under `stow/linux` or `stow/mac` and shared files in `stow/common`.
- For shell init changes, avoid introducing interactive prompts; prefer environment variables or documented flags.

## Style
- Scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use 2-space indentation, quote variables, and prefer readable pipelines over dense one-liners.
- Add brief comments only when behavior is non-obvious (e.g., required env vars, special paths).

## Testing & validation
- Minimum: `bash -n` on modified scripts and `shellcheck` when available (`make lint check` covers both).
- Stow dry-run (`make stow-linux` / `make stow-mac`) to ensure no conflicts.
- Spot-check dotfile loadability in a throwaway shell/tmux session after changes.
- If you touch pyenv init, confirm shells still start cleanly without `pyenv virtualenv` installed.
