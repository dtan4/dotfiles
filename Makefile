SUBMODULES = $(shell git submodule | awk '{ print $$2 }')
UNAME := $(shell uname)

DOTFILES = $(shell git ls-tree --name-only HEAD)

SYMLINK_LINUX_ONLY := .conkyrc .Xresources
SYMLINK_MAC_ONLY := .tmux-Darwin.conf
SYMLINKIGNORE := .symlinkignore
SYMLINK_IGNORE_FILES := $(shell cat $(SYMLINKIGNORE))

.DEFAULT_GOAL := install

.PHONY: homebrew
homebrew:
ifeq ($(UNAME),Darwin)
ifeq ("$(wildcard /usr/local/bin/brew)","")
		ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
endif
endif

.PHONY: homebrew-bundle
homebrew-bundle:
ifeq ($(UNAME),Darwin)
	@while read -r line; do \
		if [ ! -z "$$line" ]; then\
			brew $$line || true; \
		fi; \
	done < $(PWD)/brewfiles/Brewfile
endif

.PHONY: install
install: submodule-init symlink homebrew homebrew-bundle install-nodenv install-rbenv

.PHONY: install-nodenv
install-nodenv:
	curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash

.PHONY: install-rbenv
install-rbenv:
ifeq ($(UNAME),Darwin)
# https://github.com/rbenv/rbenv-installer/issues/15
	brew install rbenv
endif
	curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash

.PHONY: install-vscode-settings
install-vscode-settings:
ifeq ($(UNAME),Darwin)
	ln -sf $(PWD)/vscode-settings.json "$(HOME)/Library/Application Support/Code/User/settings.json"
endif

.PHONY: install-vscode-extensions
install-vscode-extensions:
	@script/install-vscode-extensions

.PHONY: submodule-init
submodule-init:
	git submodule update --init

.PHONY: submodule-update
submodule-update:
	@for submodule in $(SUBMODULES); do \
	(\
		cd $$submodule; \
		git pull origin master;\
	)\
	done

.PHONY: symlink
symlink:
	@for file in $(DOTFILES); do \
		if [ -n "`grep $$file $(SYMLINKIGNORE)`" ]; then \
			continue; \
		fi; \
		if [ $(UNAME) = "Linux" -a $(SYMLINK_MAC_ONLY) = *"$$file"* ]; then \
			continue; \
		fi; \
		if [ ! -e $(HOME)/$$file ]; then \
			ln -sf $(PWD)/$$file $(HOME)/$$file; \
		fi; \
	done

.PHONY: clean
clean: clean-symlink

.PHONY: clean-symlink
clean-symlink:
	@for file in $(DOTFILES); do \
		if [ -e $(HOME)/$$file ]; then \
			rm -r $(HOME)/$$file; \
		fi; \
	done
