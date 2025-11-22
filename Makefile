SHELL := /bin/bash

SCRIPTS := install.sh scripts/bootstrap-linux.sh scripts/bootstrap-mac.sh scripts/linux/vim-setup.sh

.PHONY: lint check stow-linux stow-mac bootstrap-linux bootstrap-mac

lint:
	@command -v shellcheck >/dev/null 2>&1 && shellcheck $(SCRIPTS) || echo "shellcheck not installed; skipping lint"

check:
	@set -e; for file in $(SCRIPTS); do bash -n $$file; done

stow-linux:
	@stow -d stow -t $$HOME -n -v common linux

stow-mac:
	@stow -d stow -t $$HOME -n -v common mac

bootstrap-linux:
	@./scripts/bootstrap-linux.sh

bootstrap-mac:
	@./scripts/bootstrap-mac.sh
