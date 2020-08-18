SUBMODULES = $(shell git submodule | awk '{ print $$2 }')
UNAME := $(shell uname)

DOTFILES = $(shell git ls-tree --name-only HEAD)

SYMLINK_LINUX_ONLY := .conkyrc .Xresources
SYMLINK_MAC_ONLY := .tmux-Darwin.conf
SYMLINKIGNORE := .symlinkignore
SYMLINK_IGNORE_FILES := $(shell cat $(SYMLINKIGNORE))

VIM_PLUGINS = $(shell find dein/repos -type d -depth 3 | grep -v Shougo/dein.vim)

.DEFAULT_GOAL := install

.PHONY: envchain
envchain: homebrew
ifeq ($(UNAME),Darwin)
ifeq ("$(wildcard /usr/local/bin/envchain)","")
	brew install "https://raw.githubusercontent.com/sorah/envchain/master/brew/envchain.rb"
endif
endif

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
install: submodule-init submodule-update symlink homebrew homebrew-bundle envchain

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
clean: clean-symlink clean-vimplugins

.PHONY: clean-symlink
clean-symlink:
	@for file in $(DOTFILES); do \
		if [ -e $(HOME)/$$file ]; then \
			rm -r $(HOME)/$$file; \
		fi; \
	done

.PHONY: clean-vimplugins
clean-vimplugins:
	@for plugin in $(VIM_PLUGINS); do \
		rm -rf $$plugin; \
	done
