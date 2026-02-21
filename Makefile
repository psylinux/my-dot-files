SHELL := /bin/bash

SCRIPTS := install.sh scripts/bootstrap-linux.sh scripts/bootstrap-mac.sh

.PHONY: lint check stow-linux stow-mac bootstrap-linux bootstrap-mac

lint:
	@command -v shellcheck >/dev/null 2>&1 && shellcheck $(SCRIPTS) || echo "shellcheck not installed; skipping lint"

check:
	@set -e; for file in $(SCRIPTS); do bash -n $$file; done

stow-linux:
	@packages="linux"; \
	if [ -d stow/common ]; then packages="common $$packages"; fi; \
	stow -d stow -t $$HOME -n -v $$packages

stow-mac:
	@packages="mac"; \
	if [ -d stow/common ]; then packages="common $$packages"; fi; \
	stow -d stow -t $$HOME -n -v $$packages

bootstrap-linux:
	@./scripts/bootstrap-linux.sh

bootstrap-mac:
	@./scripts/bootstrap-mac.sh
