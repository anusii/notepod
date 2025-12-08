#!/bin/bash
#
# Time-stamp: Friday 2025-12-05 22:20:39 Jess Moore
#
# Add support to Podfile for installing pods
#
# Usage: add_pod_support.sh [args...]

function usage() {
    echo "Usage: add_pod_support.sh [build_folder] [podfile]"
    echo ""
    echo "Description: Add support to Podfile for installing pods."
    echo ""
    echo "Arguments:"
    echo "  build_folder: build folder, ie. ios/macos (No default)."
    echo "  podfile:      Path of podfile, eg. Podfile (No default)."
    echo ""
    exit 1 # Exit with a non-zero status to indicate an error
}

if [[ $# -ne 2 || $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

if [[ $# -eq 2 ]]; then
    BUILD_FOLDER=$1
    PODFILE=$2
fi

# Check for GNU sed
SED_BIN=$(which sed)
if [[ "$SED_BIN" != *"/gnu-sed"* ]]; then
    echo "Warning: GNU sed not found or not prioritized in PATH. Install GNU sed and/or update PATH." >&2
    exit 1
fi

# Check Podfile exist
if [ ! -f "$PODFILE" ]; then
    echo "${PODFILE} not found. Please add ${PODFILE}."
    usage
else
    echo "Found ${PODFILE}."
fi


# Insert code for installing macos pods into Podfile

if [[ ${BUILD_FOLDER} == "macos" ]]; then

    # Add def flutter_root
    if ! grep -q "def flutter_root" "${PODFILE}"; then

        echo "Adding def flutter_root block"

# def flutter_root block with flutter_macos_podfile_setup
# Double slash creates a new line
# Indented appropriately
DEF_CONTENT="def flutter_root\\
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'ephemeral', 'Flutter-Generated.xcconfig'), __FILE__)\\
  unless File.exist?(generated_xcode_build_settings_path)\\
    raise \"#{generated_xcode_build_settings_path} must exist. If you are running pod install manually, make sure 'flutter pub get' is executed first\"\\
  end\\
\\
  File.foreach(generated_xcode_build_settings_path) do |line|\\
    matches = line.match(/FLUTTER_ROOT\=(.*)/)\\
    return matches[1].strip if matches\\
  end\\
  raise \"FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Flutter-Generated.xcconfig, then run \'flutter pub get\'\"\\
end\\
\\
require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)\\
\\
flutter_macos_podfile_setup\\
"

    PRECEEDING_LINE="platform :osx, DEPLOYMENT_TARGET"

    # Note: new lines and env variables must be excluded from sed string
    # shellcheck disable=SC1003
    sed -i '/'"${PRECEEDING_LINE}"'/a\'"\n${DEF_CONTENT}" "${PODFILE}"
    echo "Added def flutter_root block to ${PODFILE}"

    else

        echo "def flutter_root block already added to ${PODFILE}"

    fi

# use_modular_headers!
# Indented 1 tab
MOD_HEADER_CONTENT="
  use_modular_headers!\\
\\
  flutter_install_all_macos_pods File.dirname(File.realpath(__FILE__))"
    if ! grep -q "use_modular_headers" "${PODFILE}"; then

        echo "Adding use modular header to install pods block"
        PRECEEDING_LINE="use_frameworks!"
        # shellcheck disable=SC1003
        sed -i '/'"${PRECEEDING_LINE}"'/a\'"${MOD_HEADER_CONTENT}" "${PODFILE}"
        echo "Added block to ${PODFILE}"

    else
        echo "use_modular_headers to install pods block already added to ${PODFILE}"

    fi

    # flutter_additional_macos_build_settings
    # Indented 2 tabs
MORE_BLD_SETTINGS_CONTENT="
    flutter_additional_macos_build_settings(target)"
    if ! grep -q "flutter_additional_macos_build_settings(target)" "${PODFILE}"; then


        POST_INSTALL_CONTENT="post_install do |installer|"
        if ! grep -q "${POST_INSTALL_CONTENT}" "${PODFILE}"; then

# Full post install block with flutter_additional_macos_build_settings
# with indents
POST_INSTALL_BLOCK="
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_macos_build_settings(target)
  end
end"
            echo "Adding post_install block with flutter_additional_macos_build settings"
              # shellcheck disable=SC1003
            # sed -i "/${PRECEEDING_LINE}/a\\${POST_INSTALL_BLOCK}" "${PODFILE}"
            echo "${POST_INSTALL_BLOCK}" >> "${PODFILE}"
            echo "Added block to ${PODFILE}"

        else

            echo "Adding flutter_additional_macos_build settings block"
            PRECEEDING_LINE="\tinstaller.pods_project.targets.each do |target|"
              # shellcheck disable=SC1003
            sed -i '/'"${PRECEEDING_LINE}"'/a\'"${MORE_BLD_SETTINGS_CONTENT}" "${PODFILE}"
            echo "Added block to ${PODFILE}"

        fi

    else
        echo "flutter_additional_macos_build_settings(target) block already added to ${PODFILE}"

    fi


elif [[ ${BUILD_FOLDER} == "ios" ]]; then

# Insert code for installing ios pods into Podfile

        # Add def flutter_root
    if ! grep -q "def flutter_root" "${PODFILE}"; then

        echo "Adding def flutter_root block"

# def flutter_root block with flutter_ios_podfile_setup
# Double slash creates a new line
# Indented appropriately
DEF_CONTENT="def flutter_root\\
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)\\
  unless File.exist?(generated_xcode_build_settings_path)\\
    raise \"#{generated_xcode_build_settings_path} must exist. If you are running pod install manually, make sure 'flutter pub get' is executed first\"\\
  end\\
\\
  File.foreach(generated_xcode_build_settings_path) do |line|\\
    matches = line.match(/FLUTTER_ROOT\=(.*)/)\\
    return matches[1].strip if matches\\
  end\\
  raise \"FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Flutter-Generated.xcconfig, then run \'flutter pub get\'\"\\
end\\
\\
require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)\\
\\
flutter_ios_podfile_setup\\
"

    PRECEEDING_LINE="platform :ios, DEPLOYMENT_TARGET"

    # Note: new lines and env variables must be excluded from sed string
    # shellcheck disable=SC1003
    sed -i '/'"${PRECEEDING_LINE}"'/a\'"\n${DEF_CONTENT}" "${PODFILE}"
    echo "Added def flutter_root block to ${PODFILE}"

    else

        echo "def flutter_root block already added to ${PODFILE}"

    fi


    # use_modular_headers!
# Indented 1 tab
MOD_HEADER_CONTENT="
  # use_modular_headers!\\
\\
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))"
    if ! grep -q "flutter_install_all_ios_pods" "${PODFILE}"; then

        echo "Adding use modular header and flutter_install_all_ios_pods block"
        PRECEEDING_LINE="use_frameworks!"
        # shellcheck disable=SC1003
        sed -i '/'"${PRECEEDING_LINE}"'/a\'"${MOD_HEADER_CONTENT}" "${PODFILE}"
        echo "Added block to ${PODFILE}"

    else
        echo "use modular header and flutter_install_all_ios_pods block already added to ${PODFILE}"

    fi


    # flutter_additional_macos_build_settings
    # Indented 2 tabs
MORE_BLD_SETTINGS_CONTENT="
    flutter_additional_ios_build_settings(target)"
    if ! grep -q "flutter_additional_ios_build_settings(target)" "${PODFILE}"; then


        POST_INSTALL_CONTENT="post_install do |installer|"
        if ! grep -q "${POST_INSTALL_CONTENT}" "${PODFILE}"; then

# Full post install block with flutter_additional_macos_build_settings
# with indents
POST_INSTALL_BLOCK="
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end"
            echo "Adding post_install block with flutter_additional_ios_build_settings settings"
              # shellcheck disable=SC1003
            # sed -i "/${PRECEEDING_LINE}/a\\${POST_INSTALL_BLOCK}" "${PODFILE}"
            echo "${POST_INSTALL_BLOCK}" >> "${PODFILE}"
            echo "Added block to ${PODFILE}"

        else

            echo "Adding flutter_additional_ios_build_settings settings block"
            PRECEEDING_LINE="\tinstaller.pods_project.targets.each do |target|"
              # shellcheck disable=SC1003
            sed -i '/'"${PRECEEDING_LINE}"'/a\'"${MORE_BLD_SETTINGS_CONTENT}" "${PODFILE}"
            echo "Added block to ${PODFILE}"

        fi

    else
        echo "flutter_additional_ios_build_settings(target) block already added to ${PODFILE}"

    fi


fi
