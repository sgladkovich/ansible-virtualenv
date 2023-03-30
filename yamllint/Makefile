# -*- Makefile -*-
#
#
.DEFAULT_GOAL := help
YAMLLINT_DIR := $(HOME)/.config/yamllint
YAMLLINT_CONFIG := $(YAMLLINT_DIR)/config
RMFILES := *~ .*~ ./\#*\# ./.\#*\#

help:
	@echo 'Available targets:'
	@echo
	@echo '  install : symlink config from $(YAMLLINT_CONFIG)'

install: $(YAMLLINT_DIR) $(YAMLLINT_CONFIG)

$(YAMLLINT_DIR):
	mkdir -p $@

$(YAMLLINT_CONFIG):
	-test -e $@ || ln -s $(CURDIR)/yamllint.yml $@

clean:
	$(RM) $(RMFILES)

.PHONY: help install clean
