# -*- Makefile -*-
#
#
.DEFAULT_GOAL := help
# Set these here in case they are not inherited from parent Makefile
# in engineering/devops/ansible
ANSIBLE_HOME ?= $(HOME)/.ansible
ANSIBLE_VERSIONS ?= 13.4.0
VENV_BASE ?= $(HOME)/.local/venv
# These should remain local
COLLECTIONS_DIR_LIST := $(foreach ver,$(ANSIBLE_VERSIONS),$(ANSIBLE_HOME)/collections-$(ver))
REQUIREMENTS_FILES := $(wildcard requirements-collections-*.yml)
RMFILES := *~ .*~ ./\#*\# ./.\#*\#

define HELP_TEXT
Available targets:

  install   : install Ansible Collections to $(COLLECTIONS_DIR_LIST)
  uninstall : uninstall Ansible Collections from $(COLLECTIONS_DIR_LIST)
endef

help:
	$(info $(HELP_TEXT))
	@:

install: directories $(COLLECTIONS_DIR_LIST)

directories: $(DIR_LIST)

uninstall:
	$(RM) -r $(COLLECTIONS_DIR_LIST)

reinstall: uninstall
	$(MAKE) install

$(COLLECTIONS_DIR_LIST): $(REQUIREMENTS_FILES)
	export version=$$(echo "$@" | sed 's|^.*/collections-||g') && \
	. $(VENV_BASE)/ansible-$${version}/bin/activate && \
	ansible-galaxy collection install -r requirements-collections-$${version}.yml -p $@ && \
	deactivate
	touch $@

$(DIR_LIST):
	mkdir -p $@

clean:
	$(RM) $(RMFILES)

.PHONY: help install directories clean uninstall reinstall
