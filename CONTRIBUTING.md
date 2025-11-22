# Contributing

## Getting started
- Install dependencies and stow configs with `./install.sh`.
- Run lint and syntax checks before sending changes: `make lint check`.
- Prefer no-op validation when possible: `make stow-linux` / `make stow-mac` runs Stow in dry-run mode to surface conflicts.

## Adding packages or installers
- For Linux apt installs, edit `scripts/bootstrap-linux.sh`: append to the package arrays in `install_packages_apt` or add a dedicated installer function if the tool needs extra setup (keys, services, groups).
- Keep new installers idempotent: check for existing installs and avoid prompts; favor `-y` flags.
- Log clear section headers with `log` to make automation output easy to skim.

## Style
- Scripts should start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Use 2-space indentation and quote variables.
- When behavior is non-obvious, add a short usage comment or example near the function.

## Testing
- At minimum, run `bash -n` on modified scripts and `shellcheck` when available.
- Spot-check dotfiles loadability in a throwaway shell/tmux session when altering them.
