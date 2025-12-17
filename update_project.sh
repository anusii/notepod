#!/bin/bash
#
# Time-stamp: <Thursday 2025-11-27 11:38:16 Jess Moore>
#
# Update Xcode build project files and cocoa pods after ios/macos pods change or project build configuration changes

function usage() {
    echo "Usage: update_project.sh [ios/macos]"
    echo ""
    echo "Description: Update Xcode build project files and cocoa pods after ios/macos pods"
    echo "change or project build configuration changes. Uses 'configFiles' variable of"
    echo "project.yml in ios/macos folder to add necessary target support file includes to"
    echo "the build mode .xcconfig file, required for 'pod update'. Run script project top"
    echo "level folder. Requires xcodegen, bash v>=4.0, GNU getopts, GNU sed. Resources generated: "
    echo "  - **/Runner/Info.plist"
    echo "  - **/Runner/xcodeproj/"
    echo "  - **/Runner/xcworkspace/"
    echo "  - **/Pods/"
    echo ""
    echo "Resources updated (if required):"
    echo "  - **/Podfile"
    echo "  - **/Flutter/*-[flavor].xcconfig"
    echo ""
    echo "Examples:"
    echo "Recommended: for first time, to use '--backup' to create a backup of current project file [ios/macos]/Runner.xcodeproj/project.pbxproj:"
    echo "update_project.sh --backup [ios/macos]"
    echo ""
    echo "Arguments:"
    echo "  ios/macos:          Build folder (Default: macos)."
    echo "  -b, --backup:       Backup generated xcode project file Runner.xcodeproj/project.pbxproj and Podfile"
    echo "  -n, --no-clean:     Skip 'flutter clean'."
    echo ""
    exit 1
}

if [[ $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

YQ_BIN=$(which yq)
if [[ "$YQ_BIN" == 'yq not found' ]]; then
    echo "Requires 'yq'. Run 'brew install yq' or equivalent on your platform."
    usage
fi

XCODEGEN_BIN=$(which xcodegen)
if [[ "$XCODEGEN_BIN" == 'xcodegen not found' ]]; then
    echo "Requires 'xcodegen'. Run 'brew install xcodegen' or equivalent on your platform."
    usage
fi

# Check exists lib folder to test in top level
# of project

if [[ -d "lib" ]]; then
    echo "Confirmed running in project top level folder."
else
    echo "Run script from project top level folder."
    usage
fi

# Parse options using getopts
NOCLEAN=false
BACKUP=false

# Check for GNU getopt
GETOPT_BIN=$(which getopt)
if [[ "$GETOPT_BIN" != *"/gnu-getopt"* ]]; then
    # Fallback for systems without GNU getopt or if it's not in PATH correctly
    # This might require manual parsing for long options if BSD getopt is used
    echo "Warning: GNU getopt not found or not prioritized in PATH. Install GNU getopt and/or update PATH. Alternatively, short flags may work." >&2
    exit 1
fi
ARGS=$(getopt -o nb --long no-clean,backup -- "$@")

# Check if getopt encountered an error
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "Error parsing arguments. Use --help for usage." >&2
    exit 1
fi

eval set -- "$ARGS"

while true; do
    case "$1" in
        -n | --no-clean)
            NOCLEAN=true
            echo "Setting NOCLEAN=true"
            shift
            ;;
        -b | --backup)
            BACKUP=true
            echo "Setting BACKUP=true"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!" >&2
            exit 1
            ;;
    esac
done

# Remaining arguments are positional
POSITIONAL_ARGS=("$@")


echo "======================================="
echo "Running flutter clean & flutter pub get:"
echo "pod install/update must be run when native plugins changed"
# Note: flutter pub get will update *Generated.xcconfig
# used by pod install/update and add files to
# build/.
# See files:
# macos/Flutter/ephemeral/Flutter-Generated.xcconfig
# ios/Flutter/Generated.xcconfig

if [[ "*${NOCLEAN}*" == "*false*" ]]; then
    flutter clean
else
    echo "Skipping 'flutter clean'."
fi

# flutter clean
flutter pub get


echo "======================================="
echo "Open build folder and find project yml"

if [[ ${#POSITIONAL_ARGS[@]} -eq 1 ]]; then
    BUILD_FOLDER=${POSITIONAL_ARGS[0]}
else
    BUILD_FOLDER="macos"
fi

cd "${BUILD_FOLDER}" || return

PWD=$(pwd)
echo "Current folder: $PWD"
CURR_FOLDER=$(basename "$PWD")

if [[ $CURR_FOLDER != "ios" && $CURR_FOLDER != "macos" ]]; then
    echo "Ensure ${BUILD_FOLDER} exists."
    echo "If not, run \"flutter create --platforms=${BUILD_FOLDER} .\""
    usage
fi


echo "======================================="
echo "Install project yml if not already exists"

PROJECT_FILE=project.yml

if [ ! -f "$PROJECT_FILE" ]; then
    echo "${PROJECT_FILE} not found. Installing ${PROJECT_FILE}."
    bash ../config/install_project_yml.sh "${BUILD_FOLDER}"
else
    echo "${PROJECT_FILE} already installed."
fi

echo "======================================="
echo "Backup project file if requested"

PBX_PROJECT_FILE="Runner.xcodeproj/project.pbxproj"
if [[ "*${BACKUP}*" == "*true*" && -f ${PBX_PROJECT_FILE} ]]; then
    echo "Creating backup of project ${PBX_PROJECT_FILE} file"
    NOW=$(date +"%Y%m%d%H%M")
    PBX_PROJECT_FILE_BAK="Runner.xcodeproj/project-${NOW}.pbxproj"
    cp -p "${PBX_PROJECT_FILE}" "${PBX_PROJECT_FILE_BAK}"
    ls -lt Runner.xcodeproj/project*.pbxproj

elif [[ "*${BACKUP}*" == "*true*" && ! -f ${PBX_PROJECT_FILE} ]]; then

    echo "No ${PBX_PROJECT_FILE} found. Generating file using xcodegen."

else
    echo "Overwriting ${PBX_PROJECT_FILE} file using xcodegen."
fi


echo "======================================="
echo "Generate Xcode project files"
echo "Note: xcodegen expects config files \"Flutter/Flutter-*.xcconfig\" to exist"
echo "These are generated the first time update_project.sh for each flavor in the project.yml."
echo "Re-run update_project.sh if necessary for xcodegen to find these config files."

xcodegen generate


echo "======================================="
echo "${BUILD_FOLDER} (cocoapods) include scheme pod target support files in main scheme config files"

bash ../config/incl_target_support_files.sh "${BUILD_FOLDER}" "${PROJECT_FILE}"


echo "======================================="
echo "${BUILD_FOLDER} (cocoapods) backup Podfile if requesed and initialise Podfile if doesn't exist or moved to backup"

PODFILE=Podfile

if [[ "*${BACKUP}*" == "*true*" ]]; then

    # Backup if file exists
    if [ -f "$PODFILE" ]; then
        echo "Creating backup of project ${PODFILE} file"
    NOW=$(date +"%Y%m%d%H%M")
        PODFILE_BAK="Podfile-${NOW}"
        mv "${PODFILE}" "${PODFILE_BAK}"
    fi
fi

if [ ! -f "$PODFILE" ]; then
    pod init
    echo "Ran pod init to initialise ${PODFILE}."
    ls -lt Podfile*
else
    echo "${PODFILE} already exists."
fi


echo "======================================="
echo "${BUILD_FOLDER} (cocoapods) ensure Podfile deployment target matches project.yml"
echo " deployment target."

# Update deployment target in Podfile if changed in project.yml
# Where project.yml considered source of truth

bash ../config/update_deployment_target.sh "${BUILD_FOLDER}" "${PODFILE}" "${PROJECT_FILE}"


echo "======================================="
echo "${BUILD_FOLDER} (cocoapods) add support to Podfile for installing pods"


# This adds support in Podfile for installing the pods comprising native code
# for any packages that require it in pubspec

bash ../config/add_pod_support.sh "${BUILD_FOLDER}" "${PODFILE}"


echo "======================================="
echo "${BUILD_FOLDER} (cocoapods) install/update pods."

# Remove old Pods dir and Podfile.lock file
rm -rf Pods
rm -rf Podfile.lock

# Update pods
# pod repo update # 20251127 jesscmoore: Unnecessary usually
pod update

cd ../.

echo "======================================="
echo "Done."
