# -*- Makefile -*-
#
#
.DEFAULT_GOAL := help
YAMLLINT_DIR := $(HOME)/.config/yamllint
YAMLLINT_CONFIG := $(YAMLLINT_DIR)/config
RMFILES := *~ .*~ ./\#*\# ./.\#*\#

define HELP_TEXT
Available targets:

  install : symlink config from $(YAMLLINT_CONFIG)
endef

help:
	$(info $(HELP_TEXT))
	@:

install: $(YAMLLINT_DIR) $(YAMLLINT_CONFIG)

$(YAMLLINT_DIR):
	mkdir -p $@

$(YAMLLINT_CONFIG):
	-test -e $@ || ln -s $(CURDIR)/yamllint.yml $@

clean:
	$(RM) $(RMFILES)

.PHONY: help install clean
