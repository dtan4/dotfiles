SUBMODULES = $(shell git submodule | awk '{ print $$2 }')
UNAME := $(shell uname)

.PHONY: homebrew-install
homebrew-install:
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
