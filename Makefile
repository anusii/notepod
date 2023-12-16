########################################################################
#
# Generic Makefile
#
# Time-stamp: <Sunday 2023-12-17 10:33:33 +1100 Graham Williams>
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App is often the current directory name.
#
# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

APP=$(shell pwd | xargs basename)
VER=
DATE=$(shell date +%Y-%m-%d)

DEST=/var/www/html/$(APP)

########################################################################
# Supported Makefile modules.

# Often the support Makefiles will be in the local support folder, or
# else installed in the local user's shares.

INC_BASE=support

# Specific Makefiles will be loaded if they are found in
# INC_BASE. Sometimes the INC_BASE is shared by multiple local
# Makefiles and we want to skip specific makes. Simply define the
# appropriate INC to a non-existant location and it will be skipped.

INC_DOCKER=skip

# Load any modules available.

INC_MODULE=$(INC_BASE)/modules.mk

ifneq ("$(wildcard $(INC_MODULE))","")
  include $(INC_MODULE)
endif

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP):

  solidcommunity	Install to https://podnotes.solidcommunity.au

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS

locals:
	@echo "This might be the instructions to install $(APP)"

.PHONY: docs
docs::
	rsync -avzh doc/api/ root@solidcommunity.au:/var/www/html/docs/podnotes/

.PHONY: versions
versions:
	perl -pi -e 's|applicationVersion = ".*";|applicationVersion = "$(VER)";|' \
	lib/constants/app.dart

#
# Manage the production install on the remote server.
#

.PHONY: solidcommunity
solidcommunity:
	rsync -avzh ./ solidcommunity.au:projects/podnotes/ \
	--exclude .dart_tool --exclude build --exclude ios --exclude macos \
	--exclude linux --exclude windows --exclude android
	ssh solidcommunity.au '(cd projects/podnotes; flutter upgrade; make prod)'
