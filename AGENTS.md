# Repository Guidelines

This repo centralizes personal dotfiles and helper scripts for Linux and macOS. Keep changes small, reproducible, and documented so contributors can safely mirror updates across platforms.

## Project Structure & Module Organization
- `stow/common` is for shared assets across platforms (currently `.gitignore`).
- `stow/linux` is the Stow package for Linux (`.bashrc`, `.vimrc`, `.tmux.conf`, `.gitconfig`, `.git-prompt.sh`, `.irssi`, `.vim/colors`, `.local/bin` helpers).
- `stow/mac` is the macOS package (`.zshrc`, `.p10k.zsh`, `.tmux.conf`, `.gitconfig`, `.gnupg/gpg-agent.conf`, `.gnupg/sshcontrol`).
- `scripts/linux` keeps one-off setup helpers (e.g., `vim-setup.zsh`).
- `.ssh/` is tracked here but keep private material out of version control.

## Build, Test, and Development Commands
- No build step; validate shell scripts with `bash -n stow/linux/.local/bin/deb-update.sh` (or the target file) before pushing.
- Run static checks when available: `shellcheck stow/linux/.local/bin/remove-old-kernel.sh`.
- For dotfiles, spot-check loadability: `tmux source-file stow/linux/.tmux.conf`, `vim -u stow/linux/.vimrc +qall`, `source stow/linux/.bashrc`, and `source stow/mac/.zshrc` inside a throwaway shell.
- Prefer non-interactive flows (`apt-get … -y`) and echo progress logs similar to existing scripts to aid remote debugging.

## Coding Style & Naming Conventions
- Bash scripts should start with `#!/bin/bash`, use lowercase-hyphenated filenames, and favor readable pipelines over long one-liners.
- Quote variables, use `set -euo pipefail` for new scripts unless it breaks existing flows, and keep indentation consistent (2 spaces is preferred when adding blocks).
- Echo section headers (as in `deb-update.sh`) to make logs scannable; keep user prompts avoided unless guarded by a flag.
- Keep config defaults minimal; mirror existing key ordering in dotfiles to reduce diff noise.

## Testing Guidelines
- Exercise update scripts in a disposable VM/container that matches the target distro before merging; avoid running destructive commands on hosts you cannot rebuild.
- When touching `remove-old-kernel.sh`, dry-run logic by printing candidate packages first; confirm the exclusion regex still protects the running kernel.
- Add brief usage examples in comments when behavior is non-obvious (e.g., required env vars, expected directory layout).
- If a change affects multiple platforms, test both `linux/` and `mac/` flows or note what remains unverified.

## Commit & Pull Request Guidelines
- Follow existing commit tone: short, capitalized summaries in present tense (e.g., “Modifying `.vimrc` and `.tmux.conf`”); keep to ~72 characters.
- Include what changed, why, and any side effects in the PR description; link issues when relevant.
- Capture validation steps (commands run, platforms tested) and attach logs or screenshots when visual behavior changes (e.g., tmux status tweaks, Vim color changes).
- Avoid bundling refactors with behavioral changes unless tightly coupled; call out any remaining TODOs or follow-up items.
