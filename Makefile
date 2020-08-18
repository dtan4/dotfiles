SUBMODULES = $(shell git submodule | awk '{ print $$2 }')
UNAME := $(shell uname)

GIT_CLONE := git clone --recursive

ANYENV_DIR := $(HOME)/.anyenv
ANYENV := $(ANYENV_DIR)/bin/anyenv
ANYENV_PLUGINS := znz/anyenv-update

RBENV_PLUGINS := amatsuda/gem-src sstephenson/rbenv-default-gems sstephenson/rbenv-gem-rehash rbenv/rbenv-each

GOTOOLS := golang.org/x/tools/cmd/godoc

DOTFILES = $(shell git ls-tree --name-only HEAD)

SYMLINK_LINUX_ONLY := .conkyrc .Xresources
SYMLINK_MAC_ONLY := .tmux-Darwin.conf
SYMLINKIGNORE := .symlinkignore
SYMLINK_IGNORE_FILES := $(shell cat $(SYMLINKIGNORE))

VIM_PLUGINS = $(shell find dein/repos -type d -depth 3 | grep -v Shougo/dein.vim)

.DEFAULT_GOAL := install

.PHONY: anyenv
anyenv:
ifeq ("$(wildcard $(ANYENV_DIR))", "")
	$(GIT_CLONE) "https://github.com/riywo/anyenv.git" $(ANYENV_DIR)
	$(ANYENV) init -

	mkdir -p $(ANYENV_DIR)/plugins

	@for plugin in $(ANYENV_PLUGINS); do \
	(\
		cd $(ANYENV_DIR)/plugins; \
		if [ ! -d "$$(basename $$plugin)" ]; then \
			$(GIT_CLONE) https://github.com/$$plugin.git; \
		fi; \
	)\
	done
endif

.PHONY: nodenv
nodenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/nodenv)", "")
	$(ANYENV) install nodenv -v
endif

.PHONY: rbenv
rbenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/rbenv)", "")
ifeq ($(UNAME),"Linux")
	sudo apt-get update
	sudo apt-get install -y libreadline-dev libssl-dev zlib1g-dev
endif
	$(ANYENV) install rbenv -v

	@for plugin in $(RBENV_PLUGINS); do \
	(\
		cd $(ANYENV_DIR)/envs/rbenv/plugins; \
		if [ ! -d "$$(basename $$plugin)" ]; then \
			$(GIT_CLONE) https://github.com/$$plugin.git; \
		fi; \
	)\
	done

	ln -sf $(PWD)/default-gems $(ANYENV_DIR)/envs/rbenv/default-gems
endif

.PHONY: envchain
envchain: homebrew
ifeq ($(UNAME),Darwin)
ifeq ("$(wildcard /usr/local/bin/envchain)","")
	brew install "https://raw.githubusercontent.com/sorah/envchain/master/brew/envchain.rb"
endif
endif

.PHONY: gotools
gotools:
	@for gotool in $(GOTOOLS); do \
		go get -u -v $$gotool; \
	done

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
install: submodule-init submodule-update symlink homebrew homebrew-bundle envchain gotools anyenv nodenv rbenv v

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
