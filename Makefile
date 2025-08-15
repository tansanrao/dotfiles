# Dotfiles Makefile - Modern declarative package and dotfile management
.PHONY: all install packages dotfiles plugins clean help macos linux
.DEFAULT_GOAL := help

# Platform detection
UNAME_S := $(shell uname -s)
HOSTNAME := $(shell hostname -s)

# Colors for output
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

define info
	@echo "$(BLUE)INFO:$(NC) $(1)"
endef

define success
	@echo "$(GREEN)SUCCESS:$(NC) $(1)"
endef

define warning
	@echo "$(YELLOW)WARNING:$(NC) $(1)"
endef

help: ## Show this help message
	@echo "$(GREEN)Dotfiles Management$(NC)"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: packages dotfiles plugins ## Install everything (packages, dotfiles, plugins)

install: ## Quick install for current platform
ifeq ($(UNAME_S),Darwin)
	@$(MAKE) macos
else ifeq ($(UNAME_S),Linux)
	@$(MAKE) linux
else
	$(call warning,"Unsupported platform: $(UNAME_S)")
endif

macos: packages-macos dotfiles plugins ## Full macOS setup
	$(call success,"macOS setup complete!")

linux: packages-linux dotfiles plugins ## Full Linux setup
	$(call success,"Linux setup complete!")

packages: ## Install packages for current platform
ifeq ($(UNAME_S),Darwin)
	@$(MAKE) packages-macos
else ifeq ($(UNAME_S),Linux)
	@$(MAKE) packages-linux
else
	$(call warning,"Unsupported platform for package installation")
endif

packages-macos: ## Install macOS packages via Homebrew
	$(call info,"Installing macOS packages...")
	@command -v brew >/dev/null 2>&1 || ./scripts/bootstrap-mac.sh
	@brew bundle --file=packages/Brewfile
ifneq ($(wildcard packages/Brewfile.$(HOSTNAME)),)
	@brew bundle --file=packages/Brewfile.$(HOSTNAME)
endif
	$(call success,"macOS packages installed")

packages-linux: ## Install Linux packages via apt
	$(call info,"Installing Linux packages...")
	@./scripts/bootstrap-linux.sh
	$(call success,"Linux packages installed")

dotfiles: ## Install dotfiles via GNU stow
	$(call info,"Installing dotfiles...")
	@cd stow && for package in */; do \
		if [ -d "$$package" ]; then \
			echo "Stowing $$package..."; \
			stow -t $(HOME) "$$package"; \
		fi \
	done
	$(call success,"Dotfiles installed")

plugins: ## Install shell and tmux plugins
	$(call info,"Installing plugins...")
	@./scripts/install-plugins.sh
	$(call success,"Plugins installed")

mise-tools: ## Install development tools via mise
	$(call info,"Installing mise tools...")
	@if command -v mise >/dev/null 2>&1; then \
		while read -r tool; do \
			if [ -n "$$tool" ] && [ "$${tool#\#}" = "$$tool" ]; then \
				echo "Installing $$tool..."; \
				mise install "$$tool" 2>/dev/null || true; \
				mise use -g "$$tool" 2>/dev/null || true; \
			fi \
		done < packages/mise-tools.txt; \
	else \
		$(call warning,"mise not found, skipping tool installation"); \
	fi
	$(call success,"mise tools installed")

update: ## Update packages and dotfiles
	$(call info,"Updating...")
ifeq ($(UNAME_S),Darwin)
	@brew update && brew upgrade
	@brew bundle --file=packages/Brewfile
else ifeq ($(UNAME_S),Linux)
	@sudo apt update && sudo apt upgrade -y
endif
	@git pull
	$(call success,"Updated successfully")

clean: ## Remove symlinks (dotfiles)
	$(call info,"Removing dotfile symlinks...")
	@cd stow && for package in */; do \
		if [ -d "$$package" ]; then \
			echo "Unstowing $$package..."; \
			stow -D -t $(HOME) "$$package"; \
		fi \
	done
	$(call success,"Dotfiles removed")

status: ## Show installation status
	@echo "$(GREEN)Dotfiles Status$(NC)"
	@echo ""
	@echo "Platform: $(UNAME_S)"
	@echo "Hostname: $(HOSTNAME)"
	@echo ""
	@echo "Tools:"
	@command -v brew >/dev/null 2>&1 && echo "  ✓ Homebrew" || echo "  ✗ Homebrew"
	@command -v stow >/dev/null 2>&1 && echo "  ✓ GNU Stow" || echo "  ✗ GNU Stow"
	@command -v mise >/dev/null 2>&1 && echo "  ✓ mise" || echo "  ✗ mise"
	@echo ""
	@echo "Dotfile packages:"
	@cd stow && for package in */; do \
		if [ -d "$$package" ]; then \
			package_name=$$(basename "$$package"); \
			if [ -L "$(HOME)/.$$package_name" ] || [ -L "$(HOME)/.config/$$package_name" ]; then \
				echo "  ✓ $$package_name"; \
			else \
				echo "  ✗ $$package_name"; \
			fi \
		fi \
	done

host-config: ## Create host-specific package overrides
	$(call info,"Creating host-specific config for $(HOSTNAME)...")
	@mkdir -p config/$(HOSTNAME)
	@if [ ! -f packages/Brewfile.$(HOSTNAME) ] && [ "$(UNAME_S)" = "Darwin" ]; then \
		echo "# Host-specific Brewfile for $(HOSTNAME)" > packages/Brewfile.$(HOSTNAME); \
		echo "# Add additional packages here" >> packages/Brewfile.$(HOSTNAME); \
	fi
	$(call success,"Host config created at config/$(HOSTNAME)")

lint: ## Check for common issues
	$(call info,"Checking for issues...")
	@if [ ! -d stow ]; then echo "$(RED)ERROR:$(NC) stow/ directory not found"; exit 1; fi
	@if [ ! -f packages/Brewfile ] && [ "$(UNAME_S)" = "Darwin" ]; then echo "$(RED)ERROR:$(NC) Brewfile not found"; exit 1; fi
	@if [ ! -f packages/apt-packages.txt ] && [ "$(UNAME_S)" = "Linux" ]; then echo "$(RED)ERROR:$(NC) apt-packages.txt not found"; exit 1; fi
	@cd stow && for package in */; do \
		if [ -d "$$package" ] && [ -z "$$(find "$$package" -type f)" ]; then \
			echo "$(YELLOW)WARNING:$(NC) Empty package: $$package"; \
		fi \
	done
	$(call success,"Lint complete")

backup: ## Create backup of current dotfiles
	$(call info,"Creating backup...")
	@mkdir -p backup/$$(date +%Y%m%d_%H%M%S)
	@cd stow && for package in */; do \
		if [ -d "$$package" ]; then \
			package_name=$$(basename "$$package"); \
			if [ -e "$(HOME)/.$$package_name" ]; then \
				cp -r "$(HOME)/.$$package_name" ../backup/$$(date +%Y%m%d_%H%M%S)/; \
			fi \
		fi \
	done
	$(call success,"Backup created")

.SILENT: help