# -*- Makefile -*-
#
#
# This Makefile facilites finishing up the development of Ansible
# roles.  It should be placed in the 'roles' directory, where each
# subdirectory contains an Ansible role.
#
# Running make as follows
#
#   make <role name> [<role name>]...
#
# will do the following:
#
#   - Run yamllint on *.yml files found in the role
#   - Run ansible-lint on the role itself
#   - Create a "scaffolding" playbook in PLAYBOOKS_DIR
#
# The scaffolding playbooks get their 'name:' from the roles meta
# 'description:', so make sure all roles have proper 'meta/meta.yml'.
# Note that if you don't want the playbooks created simply create your
# own prior to running 'make' - this Makefile will not overwrite them.
#
.DEFAULT_GOAL := help
ANSIBLE := ansible
ANSIBLE_LINT := ansible-lint
PLAYBOOKS_DIR := ../playbooks
ROLES_DIR := ../roles
YAMLLINT := yamllint
YAML_SUFFIX := .yml
ROLES = $(shell find . -maxdepth 1 -type d)
ROLE_HOSTS := all
REMOVE := *~ .*~ ./\#*\# ./.\#*\#

define HELP_TEXT
Use role names (directories) as targets to:

  - Run $(YAMLLINT) on *$(YAML_SUFFIX) files found in the role
  - Run $(ANSIBLE_LINT) on the role itself
  - Create role playbook in $(PLAYBOOKS_DIR)

For example:

  make gpu-info

endef

help:
	$(info $(HELP_TEXT))
	@:

$(ROLES): FORCE
	find $@ -type f -name '*$(YAML_SUFFIX)' | xargs yamllint
	ansible-lint $@
	$(MAKE) $(PLAYBOOKS_DIR)/$@$(YAML_SUFFIX)

$(PLAYBOOKS_DIR)/%:
	$(eval ROLE := $(shell basename $@ '$(YAML_SUFFIX)'))
	$(eval DESCRIPTION := $(shell grep 'description:' $(ROLE)/meta/main$(YAML_SUFFIX) | sed 's/ *description: //'))
	echo "---" >> $@
	echo "- name: $(DESCRIPTION)" >> $@
	echo "  hosts: $(ROLE_HOSTS)" >> $@
	echo "  become: true" >> $@
	echo "  roles:" >> $@
	echo "    - $(ROLES_DIR)/$(ROLE)" >> $@
	echo "..." >> $@

clean:
	$(RM) $(REMOVE)

FORCE:
.PHONY: FORCE help clean
