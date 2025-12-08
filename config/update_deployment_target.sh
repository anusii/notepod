#!/bin/bash
#
# Time-stamp: Friday 2025-12-05 08:57:54 Jess Moore
#
# Ensure Podfile deployment target matches project.yml deployment target.
#
# Usage: update_deployment_target.sh [args...]

function usage() {
    echo "Usage: update_deployment_target.sh build_folder podfile project.yml"
    echo ""
    echo "Description: Ensure Podfile deployment target matches project.yml deployment target.."
    echo ""
    echo "Arguments:"
    echo "  build_folder: build folder, ie. ios/macos (No default)."
    echo "  podfile:      Path of podfile, eg. Podfile (No default)."
    echo "  project yml:  Path of project.yml, eg, project.yml (No default)."
    echo ""
    exit 1 # Exit with a non-zero status to indicate an error
}

if [[ $# -ne 3 || $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

if [[ $# -eq 3 ]]; then
    BUILD_FOLDER=$1
    PODFILE=$2
    PROJECT_FILE=$3
fi

# Check Podfile and project.yml exist
if [ ! -f "$PODFILE" ]; then
    echo "${PODFILE} not found. Please add ${PODFILE}."
    usage
else
    echo "Found ${PODFILE}."
fi

if [ ! -f "$PROJECT_FILE" ]; then
    echo "${PROJECT_FILE} not found. Please add ${PROJECT_FILE}."
    usage
else
    echo "Found ${PROJECT_FILE}."
fi


if [[ ${BUILD_FOLDER} == "macos" ]]; then

    DEPLOYMENT_TARGET=$(yq '.options.deploymentTarget.macOS' "${PROJECT_FILE}")
    PLATFORM=osx

elif [[ ${BUILD_FOLDER} == "ios" ]]; then

    DEPLOYMENT_TARGET=$(yq '.options.deploymentTarget.iOS' "${PROJECT_FILE}")
    PLATFORM=ios

fi

UPDATED_TARGET_LINE="DEPLOYMENT_TARGET = ${DEPLOYMENT_TARGET}"

# Prepend file with deployment target line if required
# Or update deployment target line if not matching project.yml deployment target
if ! grep -q "DEPLOYMENT_TARGET = " "${PODFILE}"; then
    echo "${UPDATED_TARGET_LINE}" | cat - "${PODFILE}" > tempfile && mv tempfile "${PODFILE}"
    echo "Added deployment target line to ${PODFILE}"
elif ! grep -q "${UPDATED_TARGET_LINE}" "${PODFILE}"; then
    CURR_TARGET_LINE=$(cat "${PODFILE}" | grep "DEPLOYMENT_TARGET = ")
    perl -pi -e "s|${CURR_TARGET_LINE}|${UPDATED_TARGET_LINE}|" "${PODFILE}"
    echo "Podfile: updated to ${PLATFORM} ${DEPLOYMENT_TARGET} (source: ${PROJECT_FILE})."
else
    echo "Podfile: no deployment target update needed."
    echo ""
fi

# Update platform line if needed
UPDATED_PLATFORM_LINE="platform :${PLATFORM}, DEPLOYMENT_TARGET"

if ! grep -q "${UPDATED_PLATFORM_LINE}" "${PODFILE}"; then
    CURR_PLATFORM_LINE=$(cat "${PODFILE}" | grep "platform :")
    perl -pi -e "s|${CURR_PLATFORM_LINE}|${UPDATED_PLATFORM_LINE}|" "${PODFILE}"
    echo "Podfile: updated set deployment platform to:"
    cat "${PODFILE}" | grep "platform :"
else
    echo "Podfile: no deployment platform update needed."
    echo ""
fi


echo "Done - update deployment target in Podfile."
