########################################################################
#
# Generic Makefile
#
# Time-stamp: <Wednesday 2026-10-21 08:00:04 +1100 Graham Williams>
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
VER = $(shell egrep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
DATE=$(shell date +%Y-%m-%d)

# Identify a destination used by install.mk

DEST=/var/www/html/$(APP)

# The host for the repository of packages, the path on the server to
# the download folder, and the URL to the downloads.

# Directory basename (e.g., rattle)

DIRBASE := $(notdir $(CURDIR))

ifeq ($(DIRBASE),rattle)
  REPO=togaware.com
  RLOC=apps/access/
  DWLD=https://access.togaware.com/
else
  REPO=solidcommunity.au
  RLOC=/var/www/html/web/installers/
  DWLD=https://$(REPO)/installers/
endif

# Set user for ssh to server

ifeq ($(USER),u9904893)
  IUSER=jmoore
else
  IUSER=$(USER)
endif

########################################################################
# Supported Makefile modules.

# Often the support Makefiles will be in the local support folder, or
# else installed in the local user's shares.

INC_BASE=$(HOME)/.local/share/make
INC_BASE=support

# 20261016 gjw Obfuscate release builds, so for example, the
# scrambled Podcast Index secret in radiopod is harder to find in
# the binary. Read by support/flutter.mk to optionally obfuscate.

ifeq ($(APP),radiopod)
  OBFUSCATE = --obfuscate --split-debug-info=build/symbols
endif

# Specific Makefiles will be loaded if they are found in
# INC_BASE. Sometimes the INC_BASE is shared by multiple local
# Makefiles and we want to skip specific makes. Simply define the
# appropriate INC to a non-existent location and it will be skipped.

INC_DOCKER=skip
INC_MLHUB=skip
INC_WEBCAM=skip

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

  ginstall   After a github build download bundles and upload to $(REPO)

  local	     Install to $(HOME)/.local/share/$(APP)
    tgz	     Upload the installer to $(REPO)
  apk	     Upload the installer to $(REPO)
  snapstore  Publish the $(VER) snap to the Snap Store stable channel
  upload_android  Build the $(VER) bundle and send it to Play internal testing
  winget     Write the $(VER) winget manifests to installers/winget/
  flatpak    Build installers/$(APP)-$(VER).flatpak and install it for this user

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS

#
# Manage the production install on the remote server.
#

clean::
	rm -f README.html

# Linux: Install locally.

local: tgz
	tar zxvf installers/$(APP).tar.gz -C $(HOME)/.local/share/

# Linux: Upload the installers for general access from the repository.

tgz::
	chmod a+r installers/$(APP)*.tar.gz
	rsync -avzh installers/$(APP)*.tar.gz $(REPO):/var/www/html/installers/
	ssh $(REPO) chmod -R go+rX /var/www/html/installers/
	ssh $(REPO) chmod go=x /var/www/html/installers/

# Android: Upload to Solid Community installers for general access.

# 20261028 gjw The workflow now builds and signs the apk and aab, and
# `make ginstall` fetches them (installers/update.sh). These targets
# remain for uploading a build made on this machine with `make apk` or
# `make appbundle`.

apk::
	rsync -avzh installers/$(APP).apk $(REPO):$(RLOC)
	ssh $(REPO) chmod a+r $(RLOC)$(APP).apk
	mv -f installers/$(APP)-*.apk installers/ARCHIVE/
	rm -f installers/$(APP).apk
	@echo ''

appbundle::
	rsync -avzh installers/$(APP).aab $(REPO):$(RLOC)
	ssh $(REPO) chmod a+r $(RLOC)$(APP).aab
	mv -f installers/$(APP)-*.aab installers/ARCHIVE/
	rm -f installers/$(APP).aab
	@echo ''

# 20251226 gjw This has been moved into the installers github workflow
# but is retained here for convenience to build a deb locally and
# install it, often for a quick testing cycle.

deb:
	@echo "Build $(APP) version $(VER)"
	(cd installers; make $@)
	rsync -avzh installers/$(APP)_$(VER)_amd64.deb $(REPO):$(RLOC)$(APP)_amd64.deb
	ssh $(REPO) chmod a+r $(RLOC)$(APP)_amd64.deb
	wget $(DWLD)$(APP)_amd64.deb -O $(APP)_amd64.deb
	wajig install $(APP)_amd64.deb
	rm -f $(APP)_amd64.deb
	mv -f installers/$(APP)_*.deb installers/ARCHIVE/

# 20261020 gjw A Flatpak, built locally for now. For radiopod the Flutter
# bundle is built on the host with the scrambled Podcast Index pair, as
# deb.sh does, and flatpak/com.togaware.radiopod.yml wraps it with a libmpv
# built from source. Needs `flatpak install --user flathub
# org.flatpak.Builder org.gnome.Sdk//49`.

FLATPAK_ID = com.togaware.$(APP)
FLATPAK_BUILDER = flatpak run org.flatpak.Builder

# 20261021 gjw Built OUTSIDE the project. The build directory holds a whole
# filesystem tree, with links the user cannot list, and `make prep` runs
# dependency_validator over everything under the package root: it failed
# with Permission denied on build/flatpak/var/run.

FLATPAK_DIR = $(HOME)/.cache/$(APP)-flatpak

.PHONY: flatpak
#
# 20261029 gjw DART_DEFINES (support/flutter.mk) passes dart_defines.json
# only when it exists, so an app with no keys, such as innerpod, builds too.

flatpak:
	flutter build linux --release $(DART_DEFINES) $(OBFUSCATE)
	$(FLATPAK_BUILDER) --user --install --force-clean --disable-rofiles-fuse \
	  --state-dir=$(FLATPAK_DIR)/state --repo=$(FLATPAK_DIR)/repo \
	  $(FLATPAK_DIR)/build flatpak/$(FLATPAK_ID).yml
	flatpak build-bundle $(FLATPAK_DIR)/repo \
	  installers/$(APP)-$(VER).flatpak $(FLATPAK_ID)
	@echo "Run with: flatpak run $(FLATPAK_ID)"

dinstall:
	wget $(DWLD)$(APP)_amd64.deb -O $(APP)_amd64.deb
	wajig install $(APP)_amd64.deb
	rm -f $(APP)_amd64.deb

sinstall:
	wget $(DWLD)$(APP)_amd64.snap -O $(APP)_amd64.snap
	sudo snap install --dangerous $(APP)_amd64.snap
	rm -f $(APP)_amd64.snap

# 20261008 gjw Publish the current version's snap to the Snap Store on
# the stable channel. The snap is the one built by the github workflow
# and archived by `make ginstall`, so run that first. Requires a prior
# `snapcraft login`.

#
# 20261008 gjw Skip the upload when the stable channel already carries
# this version, reporting the revision it is published as.

SNAP_FILE = installers/ARCHIVE/$(APP)_$(VER)_amd64.snap
SNAP_STABLE = snapcraft status $(APP) | awk '$$3 == "stable" { print $$4, $$5 }'

.PHONY: snapstore
snapstore:
	@set -- $$($(SNAP_STABLE)); \
	if [ "$$1" = "$(VER)" ]; then \
	  echo "Snap Store $(APP) stable already at version $$1, revision $$2."; \
	  exit 0; \
	fi; \
	if [ ! -f $(SNAP_FILE) ]; then \
	  echo "Error: $(SNAP_FILE) not found. Run 'make ginstall' first."; \
	  exit 1; \
	fi; \
	snapcraft upload --release=stable $(SNAP_FILE) || exit 1; \
	set -- $$($(SNAP_STABLE)); \
	echo "Snap Store $(APP) stable: version $$1, revision $$2"
	@echo ''

# 20261018 gjw The Play counterpart of upload_ios: send the bundle to
# the internal testing track, Play's TestFlight. The bundle is the one
# the workflow signed and `make ginstall` archived (20261028); failing
# that, `make appbundle` builds and signs one here (it also copies it to
# $(REPO) and moves it to ARCHIVE). support/play_upload.py needs
# the service account key in $$PLAY_SERVICE_ACCOUNT or
# ~/.config/radiopod/play-service-account.json, never in the repository,
# and says so if Play already has this build number.

AAB_FILE = installers/ARCHIVE/$(APP)-$(VER).aab

.PHONY: upload_android
upload_android:
	@if [ ! -f $(AAB_FILE) ]; then $(MAKE) appbundle || exit 1; fi
	python3 support/play_upload.py $(AAB_FILE)
	@echo ''

# 20261030 gjw The winget manifests for the Inno Setup installer that
# `make ginstall` archived and uploaded under its versioned name. The
# output is a folder to submit as a pull request to
# microsoft/winget-pkgs.

.PHONY: winget
winget:
	bash support/winget.sh
	@echo ''

# 20250110 gjw A ginstall of the github built bundles, installed to the
# repository and moved into ARCHIVE. From 20261028 these include the
# signed apk and aab.
#
# 20250218 gjw Remove the deb build for now as it is placing the data
# and lib folders into /ust/bin/ which when we try to add another
# package also tries to do that, which is how I found the issue.
#
# 20250222 gjw Solved the issue by putting the package files into
# /usr/lib/rattle and then symlinked the executable to
# /usr/bin/rattle. This is working so add deb into the install and now
# utilise that for the default install on my machine.

.PHONY: upload
upload:
	(cd installers; make ginstall)
	@echo ''

.PHONY: debin
debin:
	@echo '******************** LOCAL INSTALL DEB'
	wajig install installers/ARCHIVE/$(APP)_$(VER)_amd64.deb
	@echo ''

# 20260103 gjw Note that `debin` depends on the deb file being upladed
# to the ARCHIVE and so the `upload` target is a prerequisite. Put it
# at the end as it requires interaction (sudo password) and if earlier
# it will hold up the oher non-interactive builds.

ifeq ($(DIRBASE),rattle)
GINSTALLS := upload
else
GINSTALLS := upload prod
endif

.PHONY: ginstall
ginstall: $(GINSTALLS)

.PHONY: ginfo
ginfo:
	@bumpId=$$(gh run list --limit 100 --json databaseId,displayTitle,workflowName \
		| jq -r '.[] | select(.workflowName | startswith("Build Installers")) | select(.displayTitle | startswith("Bump version")) | .databaseId' \
		| head -n 1); \
	if [ -n "$$bumpId" ]; then \
		echo "Bump ID: $$bumpId"; \
		gh run view "$$bumpId"; \
		gh run view "$$bumpId" --json status,conclusion; \
	else \
		echo "No bump ID found."; \
	fi

ZFILES := lib test integration_test pubspec.yaml analysis_options.yaml README.md CLAUDE.md bluelink_fetch.py

.PHONY: zip
zip:
	@mkdir -p ignore
	@rm -f ignore/$(APP)_lib.zip
	@to_zip=""
	@for f in $(ZFILES); do \
		if [ -e "$$f" ]; then \
			to_zip="$$to_zip $$f"; \
		fi; \
	done; \
	zip -r ignore/$(APP)_lib.zip $$to_zip
	open ignore/

.PHONY: claude
claude:
	bash support/meld_zip_from_claude.sh

.PHONY: bump
bump:
	@make prep
	@MESSAGE=$$(grep '^+.*\[' CHANGELOG.md | head -n 1 | sed 's/^+ //; s/ \[.*//'); \
	VERSION=$$(grep '^+.*\[' CHANGELOG.md | head -n 1 | sed 's/.*\[//; s/ .*//'); \
	if [ -z "$$MESSAGE" ]; then \
		echo "Error: Could not extract message from CHANGELOG.md"; \
		exit 1; \
	fi; \
	git commit -am "Bump version $$VERSION $$MESSAGE"; \
	git push
