# -*- Makefile -*-
#
#
.DEFAULT_GOAL := help
CONFIG_DIR := $(HOME)/.config
CONFIG_FILE := $(CONFIG_DIR)/ansible-lint.yml
DIR_LIST := $(CONFIG_DIR)
RMFILES := *~ .*~ ./\#*\# ./.\#*\#

define HELP_TEXT
Available targets:

  install : install ansible-lint config file $(CONFIG_FILE)
endef

help:
	$(info $(HELP_TEXT))
	@:

install: $(CONFIG_FILE)

directories: $(DIR_LIST)

$(CONFIG_FILE): directories
	-test -e $@ || ln -s $(CURDIR)/ansible-lint.yml $@

$(DIR_LIST):
	mkdir -p $@

clean:
	$(RM) $(RMFILES)

.PHONY: help install directories clean
