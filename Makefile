SUBMODULES = $(shell git submodule | awk '{ print $$2 }')
UNAME := $(shell uname)

GIT_CLONE := git clone --recursive

ANYENV_DIR := $(HOME)/.anyenv
ANYENV_PLUGINS := znz/anyenv-update

RBENV_PLUGINS := amatsuda/gem-src sstephenson/rbenv-default-gems sstephenson/rbenv-gem-rehash

GOTOOLS := github.com/nsf/gocode github.com/rogpeppe/godef golang.org/x/tools/cmd/godoc

DOTFILES = $(shell git ls-tree --name-only HEAD)

SYMLINK_LINUX_ONLY := .conkyrc .Xresources
SYMLINK_MAC_ONLY := .tmux-Darwin.conf
SYMLINKIGNORE := .symlinkignore
SYMLINK_IGNORE_FILES := $(shell cat $(SYMLINKIGNORE))

.PHONY: anyenv
anyenv:
ifeq ("$(wildcard $(ANYENV_DIR))", "")
	$(GIT_CLONE) "https://github.com/riywo/anyenv.git" $(ANYENV_DIR)
	$(ANYENV_DIR)/bin/anyenv init -

	@for plugin in $(RBENV_PLUGINS); do \
	(\
		cd $(ANYENV_DIR)/plugins; \
		if [[ ! -d $$(basename $$plugin) ]]; then \
			$(GIT_CLONE) https://github.com/$$plugin.git; \
		fi; \
	)\
	done
endif

crenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/crenv)", "")
	anyenv install crenv -v
endif

ndenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/ndenv)", "")
	anyenv install ndenv -v
endif

plenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/plenv)", "")
	anyenv install plenv -v
endif

rbenv:
ifeq ("$(wildcard $(ANYENV_DIR)/envs/rbenv)", "")
	anyenv install rbenv -v

	@for plugin in $(RBENV_PLUGINS); do \
	(\
		cd $(ANYENV_DIR)/envs/rbenv/plugins; \
		if [[ ! -d $$(basename $$plugin) ]]; then \
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
	@while read -r line; do \
		if [[ ! -z $$line ]]; then\
			brew $$line || true; \
		fi; \
	done < $(PWD)/brewfiles/Brewfile

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

.PHONY: clean-symlink
clean-symlink:
	@for file in $(DOTFILES); do \
		if [ -e $(HOME)/$$file ]; then \
			rm -r $(HOME)/$$file; \
		fi; \
	done
