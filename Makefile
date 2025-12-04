# -*- Makefile -*-
#
#
.DEFAULT_GOAL := help

OSTYPE := $(shell uname -s)
PYTHON := python3
PIP    := pip3

# IMPORTANT: When keeping multiple versions of Ansible the default
# version must be listed last in ANSIBLE_VERSIONS below.
ANSIBLE_VERSIONS := 13.0.0
# See the comment above - the last version listed in ANSIBLE_VERSIONS
# is considered default.
ANSIBLE_DEFAULT_VERSION := $(lastword $(ANSIBLE_VERSIONS))
ANSIBLE_CONFIG          := $(HOME)/.ansible.cfg
VENV_BASE               := $(HOME)/.local/venv
ANSIBLE_HOME            := $(HOME)/.ansible
VENV_LIST               := $(foreach ver,$(ANSIBLE_VERSIONS),$(VENV_BASE)/ansible-$(ver))
DIR_LIST                := $(ANSIBLE_HOME) $(ANSIBLE_HOME)/log $(VENV_BASE)
RMFILES                 := *~ .*~ ./\#*\# ./.\#*\#
export \
	ANSIBLE_CONFIG \
	ANSIBLE_DEFAULT_VERSION \
	ANSIBLE_HOME \
	ANSIBLE_VERSIONS \
	VENV_BASE \


help:
	@echo 'Available targets:'
	@echo
	@echo '  install          : install Ansible versions $(ANSIBLE_VERSIONS)'
	@echo '                     into virtual environments in $(VENV_BASE)'
	@echo '  collections      : install Ansible Collections'
	@echo '  yamllint         : install yamllint configuration'
	@echo '  ansible-lint     : install ansible-lint configuration'
	@echo '  all              : install everything'
	@echo '  uninstall        : uninstall Ansible versions $(ANSIBLE_VERSIONS)'

all: directories install collections symlinks yamllint ansible-lint

install: directories $(VENV_LIST) symlinks

directories: $(DIR_LIST)

symlinks: $(DIR_LIST) $(ANSIBLE_CONFIG)

reinstall: uninstall
	$(MAKE) install

uninstall:
	$(RM) -r $(VENV_LIST)

$(VENV_LIST):
	virtualenv --python $(PYTHON) $@
	cp requirements-$(notdir $@).txt $@/requirements.txt
	. $@/bin/activate && $(PIP) install -r $@/requirements.txt

collections: install symlinks
	$(MAKE) -C collections install

ansible-%.cfg: FORCE
	-test -e $(ANSIBLE_CONFIG) || ln -s $(CURDIR)/$@ $(ANSIBLE_CONFIG)

yamllint:
	$(MAKE) -C yamllint install

ansible-lint:
	$(MAKE) -C ansible-lint install

$(DIR_LIST):
	mkdir -p $@

$(ANSIBLE_CONFIG):
	-test -e $@ || ln -s $(CURDIR)/ansible-$(ANSIBLE_DEFAULT_VERSION).cfg $@

clean:
	$(RM) $(RMFILES)
	$(MAKE) -C ansible-lint clean
	$(MAKE) -C collections clean
	$(MAKE) -C roles clean
	$(MAKE) -C yamllint clean

FORCE:
.PHONY: clean directories symlinks install collections uninstall reinstall help yamllint ansible-lint help
