########################################################################
#
# Makefile template for Flutter
#
# Copyright 2021 (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

define FLUTTER_HELP
flutter:

  android   Run with an attached Android device;
  chrome    Run with the chrome device;
  emu	    Run with the android emulator;
  linux     Run with the linux device;
  qlinux    Run with the linux device and debugPrint() turned off;

  prep      Prep for PR by running tests, checks, docs.

  docs	    Run `dart doc` to create documentation.

  format          Run `dart format`.
  dcm             Run dart code metrics 
    nullable	  Check NULLs from dart_code_metrics.
    unused_code   Check unused code from dart_code_metrics.
    unused_files  Check unused files from dart_code_metrics.
    metrics	  Run analyze from dart_code_metrics.
  analyze         Run flutter analyze.
  ignore          Look for usage of ignore directives.
  license	  Look for missing top license in source code.

  test	    Run `flutter test` for testing.
  itest	    Run `flutter test integration_test` for interation testing.
  qtest	    Run above test with PAUSE=0.

  riverpod  Setup `pubspec.yaml` to support riverpod.
  runner    Build the auto generated code as *.g.dart files.

  desktops  Set up for all desktop platforms (linux, windows, macos)

Also supported:

  *.itest
  *.qtest

endef
export FLUTTER_HELP

help::
	@echo "$$FLUTTER_HELP"

.PHONY: chrome
chrome:
	flutter run -d chrome

# 20220503 gjw The following fails if the target files already exist -
# just needs to be run once.
#
# dart run build_runner build --delete-conflicting-outputs
#
# List the files that are automatically generated. Then they will get 
# built as required.

# BUILD_RUNNER = \
# 	lib/models/synchronise_time.g.dart

# $(BUILD_RUNNER):
# 	dart run build_runner build --delete-conflicting-outputs

pubspec.lock:
	flutter pub get

.PHONY: linux
linux: pubspec.lock $(BUILD_RUNNER)
	flutter run --device-id linux

# Turn off debugPrint() output.

.PHONY: qlinux
qlinux: pubspec.lock $(BUILD_RUNNER)
	flutter run --dart-define DEBUG_PRINT="FALSE" --device-id linux

.PHONY: macos
macos: $(BUILD_RUNNER)
	flutter run --device-id macos

.PHONY: android
android: $(BUILD_RUNNER)
	flutter run --device-id $(shell flutter devices | grep android | cut -d " " -f 5)

.PHONY: emu
emu:
	@if [ -n "$(shell flutter devices | grep emulator | cut -d" " -f 6)" ]; then \
	  flutter run --device-id $(shell flutter devices | grep emulator | cut -d" " -f 6); \
	else \
	  flutter emulators --launch Pixel_3a_API_30; \
	  echo "Emulator has been started. Rerun `make emu` to build the app."; \
	fi

.PHONY: linux_config
linux_config:
	flutter config --enable-linux-desktop

.PHONY: prep
prep: format dcm analyze ignore license tests docs

.PHONY: docs
docs::
	dart doc
	chmod -R go+rX doc

.PHONY: format
format:
	dart format lib/

.PHONY: tests
tests:: test qtest

.PHONY: dcm
dcm: nullable unused_code unused_files metrics

.PHONY: nullable
nullable:
	@echo "\n--\nDart Code Metrics: NULLABLE"
	-dart run dart_code_metrics:metrics check-unnecessary-nullable --disable-sunset-warning lib

.PHONY: unused_code
unused_code:
	@echo "\n--\nDart Code Metrics: UNUSED CODE"
	-dart run dart_code_metrics:metrics check-unused-code --disable-sunset-warning lib

.PHONY: unused_files
unused_files:
	@echo "\n--\nDart Code Metrics: UNUSED FILES"
	-dart run dart_code_metrics:metrics check-unused-files --disable-sunset-warning lib

.PHONY: metrics 
metrics:
	@echo "\n--\nDart Code Metrics: METRICS"
	dart run dart_code_metrics:metrics analyze --disable-sunset-warning lib --reporter=console

.PHONY: analyze 
analyze:
	@echo "\n--\nFutter ANALYZE"
	-flutter analyze
#	dart run custom_lint

.PHONY: ignore
ignore:
	@echo "\n--\nFiles that override lint checks with IGNORE:"
	@rgrep ignore: lib

.PHONY: license
license:
	@echo "\n--\nFiles without a LICENSE:"
	@find lib -type f -not -name '*~' ! -exec grep -qE '^(/// .*|/// Copyright|/// Licensed)' {} \; -printf "\t%p\n"

.PHONY: riverpod
riverpod:
	flutter pub add flutter_riverpod
	flutter pub add riverpod_annotation
	flutter pub add dev:riverpod_generator
	flutter pub add dev:build_runner
	flutter pub add dev:custom_lint
	flutter pub add dev:riverpod_lint

.PHONY: runner
runner:
	dart run build_runner build

# Support desktop platforms: Linux, MacOS and Windows. Using the
# project name as in the already existant pubspec.yaml ensures the
# project name is a valid name. Otherwise it is obtained from the
# folder name and may not necessarily be a valid flutter project name.

.PHONY: desktops
desktops:
	flutter create --platforms=windows,macos,linux --project-name $(shell grep 'name: ' pubspec.yaml | awk '{print $$2}') .

########################################################################
# INTEGRATION TESTING
#
# Run the integration tests for the desktop device (linux, windows,
# macos). Without this explictly specified, if I have my android
# device connected to the computer then the testing defaults to trying
# to install on android. 20230713 gjw

.PHONY: test
test:
	@echo "\n--\nUnit TEST:"
	-flutter test test

%.itest:
	flutter test --dart-define=PAUSE=5 --device-id \
	$(shell flutter devices | grep desktop | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|') \
	integration_test/$*_test.dart

.PHONY: itest
itest:
	@echo "\n--\nPausing integration TEST:"
	for t in integration_test/*_test.dart; do flutter test --dart-define=PAUSE=5 --device-id \
	$(shell flutter devices | grep desktop | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|') \
	$$t; done

.PHONY: qtest
qtest:
	@echo "\n--\nQuick integration TEST:"
	-for t in integration_test/*_test.dart; do flutter test --dart-define=PAUSE=0 --device-id \
	$(shell flutter devices | grep desktop | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|') \
	$$t; done

%.qtest:
	flutter test --dart-define=PAUSE=0 --device-id \
	$(shell flutter devices | grep desktop | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|') \
	integration_test/$*_test.dart

realclean::
	flutter clean
	flutter pub get
