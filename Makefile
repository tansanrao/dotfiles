# Makefile for symlinking dotfiles with GNU Stow (concrete targets)
# Usage:
#   make install        # install all
#   make restow         # restow all
#   make uninstall      # uninstall all
#   make restow-zsh     # only zsh (also: install-zsh, uninstall-zsh)
#   make list

SHELL := /bin/sh

STOW        ?= stow
REPO_ROOT   := $(CURDIR)
STOW_DIR    := $(REPO_ROOT)/stow
TARGET      ?= $(HOME)
STOW_OPTS   := --verbose=2 --dir="$(STOW_DIR)" --target="$(TARGET)"

# Discover packages under ./stow
PACKAGES := $(notdir $(wildcard $(STOW_DIR)/*))

# Guard: fail early if no packages
ifeq ($(strip $(PACKAGES)),)
$(error No packages found under $(STOW_DIR))
endif

.PHONY: all install uninstall restow list check

all: install

install: check $(addprefix install-,$(PACKAGES))
uninstall: check $(addprefix uninstall-,$(PACKAGES))
restow: check $(addprefix restow-,$(PACKAGES))

list:
	@echo "Packages: $(PACKAGES)"

check:
	@command -v $(STOW) >/dev/null 2>&1 || { echo "Error: GNU Stow not found in PATH"; exit 1; }
	@[ -d "$(STOW_DIR)" ] || { echo "Error: stow directory not found at $(STOW_DIR)"; exit 1; }
	@mkdir -p "$(TARGET)"

# --- Concrete targets (generated) -----------------------------------------
# This block expands into real targets like restow-zsh, install-git, etc.
define GEN_RULES
.PHONY: install-$(1) uninstall-$(1) restow-$(1)

install-$(1): check
	@echo "==> Stowing $(1) into $(TARGET)"
	$(STOW) $(STOW_OPTS) "$(1)"

uninstall-$(1): check
	@echo "==> Unstowing $(1) from $(TARGET)"
	-$(STOW) $(STOW_OPTS) -D "$(1)"

restow-$(1): check
	@echo "==> Restowing $(1) into $(TARGET)"
	$(STOW) $(STOW_OPTS) -R "$(1)"
endef

$(foreach p,$(PACKAGES),$(eval $(call GEN_RULES,$(p))))

# System setup targets
bootstrap-mac:
	@echo "==> Bootstrapping Mac"
	zsh scripts/bootstrap-mac.sh 
	brew bundle --file=Brewfile
