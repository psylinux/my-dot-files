SHELL := /bin/bash

SCRIPTS := install.sh scripts/bootstrap-linux.sh scripts/bootstrap-mac.sh

.PHONY: lint check stow-linux stow-mac bootstrap-linux bootstrap-mac

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SCRIPTS); \
	else \
		echo "shellcheck not installed; skipping lint"; \
	fi

check:
	@set -e; for file in $(SCRIPTS); do bash -n $$file; done

stow-linux:
	@packages="linux"; \
	if [ -d stow/common ]; then packages="common $$packages"; fi; \
	stow -d stow -t $$HOME -n -v --no-folding $$packages

stow-mac:
	@packages="mac"; \
	if [ -d stow/common ]; then packages="common $$packages"; fi; \
	stow -d stow -t $$HOME -n -v --no-folding $$packages

bootstrap-linux:
	@./scripts/bootstrap-linux.sh

bootstrap-mac:
	@./scripts/bootstrap-mac.sh
