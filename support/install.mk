########################################################################
#
# Makefile template for Installations
#
# Time-stamp: <Thursday 2023-11-23 17:16:47 +1100 >
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# Define PROD and MINE if not already defined.

PROD ?= $(DEST)
MINE ?= $(DEST:$(APP)=$(USER))

# Only allow prod if in main branch.

BRANCH := $(shell git branch --show-current)

ifeq ($(BRANCH),main)
  PROD ?= $(DEST)
else
  PROD ?= $(MINE)
endif

define INSTALL_HELP
installs:

  prod     Install $(APP) into $(PROD)
  install  Install $(APP) into $(MINE)

endef
export INSTALL_HELP

help::
	@echo "$$INSTALL_HELP"

########################################################################
# LOCAL TARGETS

install: $(USER).install

ifeq ($(BRANCH),main)
prod: $(APP).install
else
prod: $(USER).install
endif

%.install:
	cp web/index.html web/index.html.bak
	perl -pi -e 's|^  <base href=.*$$|  <base href="/$*/">|' web/index.html
	flutter build web
	mv web/index.html.bak web/index.html
	if [ ! -e $(DEST:$(APP)=$*) ]; then \
		sudo mkdir $(DEST:$(APP)=$*); \
	fi
	sudo rsync -azvh build/web/ $(DEST:$(APP)=$*)
	sudo chmod -R a+rX $(DEST:$(APP)=$*)
