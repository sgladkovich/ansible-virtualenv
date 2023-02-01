# -*- Makefile -*-
#
# Makefile for engineering/devops/ansible/ansible-lint
#
.DEFAULT_GOAL := help
CONFIG_DIR := $(HOME)/.config
CONFIG_FILE := $(CONFIG_DIR)/ansible-lint.yml
DIR_LIST := $(CONFIG_DIR)
RMFILES := *~ .*~ ./\#*\# ./.\#*\#

help:
	@echo 'Available targets:'
	@echo
	@echo '  install : install config file $(CONFIG_FILE)'

install: $(CONFIG_FILE)

directories: $(DIR_LIST)

$(CONFIG_FILE): directories
	-test -e $@ || ln -s $(CURDIR)/ansible-lint.yml $@

$(DIR_LIST):
	mkdir -p $@

clean:
	$(RM) $(RMFILES)

.PHONY: help install directories clean
