########################################################################
#
# Makefile template for Installations
#
# Time-stamp: <Friday 2023-11-17 11:19:23 +1100 >
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# Define PROD and MINE if not already defined.

PROD ?= $(DEST)
MINE ?= $(DEST:$(APP)=$(USER))

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
prod: $(APP).install

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
