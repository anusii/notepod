#!/bin/bash
#
# Time-stamp: Saturday 2026-04-25 Jess Moore
#
# Add support to Podfile for installing pods.
#
# Inserts three blocks required for Flutter pod installation:
#   1. def flutter_root — locates the Flutter SDK root via *-Generated.xcconfig,
#      requires podhelper, and calls the platform-specific podfile setup function.
#   2. Pod install block — adds use_modular_headers! (macOS only),
#      inhibit_all_warnings!, and flutter_install_all_*_pods inside Runner target.
#   3. post_install hook — applies Flutter build settings to every pod target,
#      downgrades Xcode 16+ clang warning-as-errors in third-party pods, and
#      excludes non-code files (eg. *.md) from Compile Sources for flutter_zxing.
#
# Usage: add_pod_support.sh [build_folder] [podfile]

function usage() {
    echo "Usage: add_pod_support.sh [build_folder] [podfile]"
    echo ""
    echo "Description: Add three blocks to Podfile for Flutter pod installation."
    echo ""
    echo "Arguments:"
    echo "  build_folder: ios or macos (required)."
    echo "  podfile:      Path to Podfile (required)."
    echo ""
    exit 1
}

if [[ $# -ne 2 || $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

BUILD_FOLDER=$1
PODFILE=$2

# Requires GNU sed for in-place edit and 'r' (read-file after match) command.
SED_BIN=$(which sed)
if [[ "$SED_BIN" != *"/gnu-sed"* ]]; then
    echo "Warning: GNU sed not found or not prioritized in PATH. Install GNU sed and/or update PATH." >&2
    exit 1
fi

if [ ! -f "$PODFILE" ]; then
    echo "${PODFILE} not found."
    usage
fi
echo "Found ${PODFILE}."

# ── Platform-specific values ─────────────────────────────────────────────────
# These are substituted into the three blocks inserted below.

if [[ ${BUILD_FOLDER} == "macos" ]]; then
    PLATFORM_LINE="platform :osx, DEPLOYMENT_TARGET"
    XCCONFIG_PATH="File.join('..', 'Flutter', 'ephemeral', 'Flutter-Generated.xcconfig')"
    FLUTTER_PODFILE_SETUP="flutter_macos_podfile_setup"
    FLUTTER_INSTALL_PODS="flutter_install_all_macos_pods File.dirname(File.realpath(__FILE__))"
    FLUTTER_BUILD_SETTINGS_FN="flutter_additional_macos_build_settings"
elif [[ ${BUILD_FOLDER} == "ios" ]]; then
    PLATFORM_LINE="platform :ios, DEPLOYMENT_TARGET"
    XCCONFIG_PATH="File.join('..', 'Flutter', 'Generated.xcconfig')"
    FLUTTER_PODFILE_SETUP="flutter_ios_podfile_setup"
    FLUTTER_INSTALL_PODS="flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))"
    FLUTTER_BUILD_SETTINGS_FN="flutter_additional_ios_build_settings"
else
    echo "Unsupported build folder: ${BUILD_FOLDER}. Use 'ios' or 'macos'." >&2
    usage
fi

# Temp file for multi-line sed insertions (auto-deleted on exit).
TMPFILE=$(mktemp)
trap 'rm -f "${TMPFILE}"' EXIT


# ── Block 1: def flutter_root ────────────────────────────────────────────────
# Locates the Flutter SDK root via *-Generated.xcconfig, requires podhelper,
# and calls the platform-specific podfile setup function.
# Inserted after the 'platform :*' line at the top of the Podfile.
if ! grep -q "def flutter_root" "${PODFILE}"; then
    echo "Adding def flutter_root block"
    cat > "${TMPFILE}" << ENDOFBLOCK

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(${XCCONFIG_PATH}, __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you are running pod install manually, make sure 'flutter pub get' is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Flutter-Generated.xcconfig, then run 'flutter pub get'"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

${FLUTTER_PODFILE_SETUP}
ENDOFBLOCK
    sed -i "/${PLATFORM_LINE}/r ${TMPFILE}" "${PODFILE}"
    echo "Added def flutter_root block to ${PODFILE}"
else
    echo "def flutter_root block already added to ${PODFILE}"
fi


# ── Block 2: pod installation ────────────────────────────────────────────────
# Adds use_modular_headers! (macOS only), inhibit_all_warnings! to silence pod
# deprecation warnings, and flutter_install_all_*_pods inside the Runner target.
# Inserted after 'use_frameworks!'.
if ! grep -q "${FLUTTER_INSTALL_PODS}" "${PODFILE}"; then
    echo "Adding pod installation block"
    {
        echo ""
        if [[ ${BUILD_FOLDER} == "macos" ]]; then
            echo "  use_modular_headers!"
            echo ""
        fi
        echo "  # Suppress deprecation warnings from third-party pods we don't control."
        echo "  inhibit_all_warnings!"
        echo ""
        echo "  ${FLUTTER_INSTALL_PODS}"
    } > "${TMPFILE}"
    sed -i "/use_frameworks!/r ${TMPFILE}" "${PODFILE}"
    echo "Added pod installation block to ${PODFILE}"
else
    echo "Pod installation block already added to ${PODFILE}"
fi


# ── Block 3: post_install hook ───────────────────────────────────────────────
# Applies Flutter build settings to every pod target.
# Downgrades Xcode 16+ clang warning-as-errors (GCC_TREAT_WARNINGS_AS_ERRORS,
# SWIFT_TREAT_WARNINGS_AS_ERRORS) in third-party pods we don't control.
# Excludes *.md from flutter_zxing Compile Sources to prevent arm64/x86_64
# build errors from README.md being treated as a source file.
# Pins IPHONEOS_DEPLOYMENT_TARGET / MACOSX_DEPLOYMENT_TARGET to the Ruby
# constant defined at the top of the Podfile to prevent CocoaPods overriding
# the project.yml value with a pod's own (often outdated) podspec minimum.
#
# Note: the guard below cannot use "${FLUTTER_BUILD_SETTINGS_FN}(target)" -
# Flutter's own vanilla Podfile template already calls that function inside
# its own post_install block, so the check would always be a false positive
# and this block would never be inserted. GCC_TREAT_WARNINGS_AS_ERRORS is
# unique to the block we add here.
if ! grep -q "GCC_TREAT_WARNINGS_AS_ERRORS" "${PODFILE}"; then
    echo "Adding post_install block"
    {
        echo "post_install do |installer|"
        echo "  installer.pods_project.targets.each do |target|"
        echo "    # Required Flutter build settings for all pod targets."
        echo "    ${FLUTTER_BUILD_SETTINGS_FN}(target)"
        echo "    target.build_configurations.each do |config|"
        if [[ ${BUILD_FOLDER} == "macos" ]]; then
            echo "      # Prevent CocoaPods overriding the deployment target set in project.yml."
            echo "      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET"
        elif [[ ${BUILD_FOLDER} == "ios" ]]; then
            echo "      # Prevent CocoaPods overriding the deployment target set in project.yml."
            echo "      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET"
        fi
        echo "      # Newer clang (Xcode 16+) promotes some warnings to errors in third-party"
        echo "      # pod source code that we do not control. Downgrade them back to warnings."
        echo "      config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'"
        echo "      config.build_settings['SWIFT_TREAT_WARNINGS_AS_ERRORS'] = 'NO'"
        echo "      if target.name == 'flutter_zxing'"
        echo "        # Exclude non-code files (eg. README.md) from Compile Sources to"
        echo "        # prevent Xcode treating them as source files for arm64/x86_64 builds."
        echo "        config.build_settings['EXCLUDED_SOURCE_FILE_NAMES'] = '*.md'"
        echo "      end"
        echo "    end"
        echo "  end"
        echo "end"
    } > "${TMPFILE}"

    # Flutter's vanilla Podfile already has its own post_install block that
    # just calls flutter_additional_*_build_settings(target). CocoaPods only
    # runs the LAST post_install block defined in a Podfile (each call
    # overwrites the previous callback, they don't chain), so simply
    # appending our block below would silently orphan the vanilla one -
    # harmless, but leaves dead/confusing code in the Podfile. Replace it
    # in place when found; otherwise fall back to appending.
    VANILLA_BLOCK=$(printf 'post_install do |installer|\n  installer.pods_project.targets.each do |target|\n    %s(target)\n  end\nend\n' "${FLUTTER_BUILD_SETTINGS_FN}")

    if grep -qF "${VANILLA_BLOCK}" "${PODFILE}"; then
        NEW_BLOCK=$(cat "${TMPFILE}")
        VANILLA_BLOCK="${VANILLA_BLOCK}" NEW_BLOCK="${NEW_BLOCK}" perl -0777 -i -pe \
            's/\Q$ENV{VANILLA_BLOCK}\E/$ENV{NEW_BLOCK}/' \
            "${PODFILE}"
        echo "Replaced vanilla post_install block in ${PODFILE}"
    else
        { echo ""; cat "${TMPFILE}"; } >> "${PODFILE}"
        echo "Appended post_install block to ${PODFILE} (vanilla block not found in expected form)"
    fi
else
    echo "post_install block already added to ${PODFILE}"
fi
