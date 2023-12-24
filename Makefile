########################################################################
#
# Generic Makefile
#
# Time-stamp: <Wednesday 2023-12-20 13:22:19 +1100 Graham Williams>
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

# Identify a destination used by install.mk

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
INC_MLHUB=skip

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

  solidcommunity	Install to https://$(APP).solidcommunity.au
  wc                    Count the number of lines of code.

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
	rsync -avzh doc/api/ root@solidcommunity.au:/var/www/html/docs/$(APP)/

.PHONY: versions
versions:
	perl -pi -e 's|applicationVersion = ".*";|applicationVersion = "$(VER)";|' \
	lib/constants/app.dart

.PHONY: wc
wc:
	@cat lib/*.dart lib/*/*.dart lib/*/*/*.dart \
	| egrep -v '^/' \
	| egrep -v '^ *$$' \
	| wc -l

#
# Manage the production install on the remote server.
#

.PHONY: solidcommunity
solidcommunity:
	rsync -avzh ./ solidcommunity.au:projects/$(APP)/ \
	--exclude .dart_tool --exclude build --exclude ios --exclude macos \
	--exclude linux --exclude windows --exclude android
	ssh solidcommunity.au '(cd projects/$(APP); flutter upgrade; make prod)'
