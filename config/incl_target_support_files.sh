#!/bin/bash
#
# Time-stamp: Friday 2025-12-05 08:38:34 Jess Moore
#
# Add include scheme pod target support files in main scheme config files
# (required for pod install/update).
#
# Usage: incl_target_support_files.sh

function usage() {
    echo "Usage: incl_target_support_files.sh [build_folder] [project_file]"
    echo ""
    echo "Description: Add include scheme pod target support files in"
    echo "main scheme config files (required for pod install/update)."
    echo "Usually run from within update_project.sh."
    echo ""
    echo "Arguments:"
    echo "  build_folder: build folder, ie. ios/macos (No default)."
    echo "  project_file:   Path of project yml file."
    echo ""
    exit 1 # Exit with a non-zero status to indicate an error
}

if [[ $# -ne 2 || $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

if [[ $# -eq 2 ]]; then
    BUILD_FOLDER=$1
    PROJECT_FILE=$2
fi

if [ ! -f "$PROJECT_FILE" ]; then
    echo "${PROJECT_FILE} not found. Please add ${PROJECT_FILE}."
    usage
else
    echo "Found ${PROJECT_FILE}."
fi

nflavors=$(yq '.configFiles | length' "${PROJECT_FILE}")

echo "Found ${nflavors} schemes."

config_files_str=$(yq '.configFiles.[]' "${PROJECT_FILE}")
readarray -t config_files <<< "$config_files_str"

# Reset xconfig files and initialise with Flutter-Generated.xcconfig only
# This avoids including target support files for flavors not in the current
# project.yml configuration.
# Define include file for Flutter-Generated.xcconfig

# Set filename of generated flutter config parameters
if [[ ${BUILD_FOLDER} == "macos" ]]; then

    flutter_generated_file="ephemeral/Flutter-Generated.xcconfig"

elif [[ ${BUILD_FOLDER} == "ios" ]]; then

    flutter_generated_file="Generated.xcconfig"

fi

for file in "${config_files[@]}"; do
    # Overwrite config file with include efor flutter generated config
    echo "#include \"${flutter_generated_file}\"" > "${file}"
    echo "Added include $flutter_generated_file in ${file}."
done

# Add include target support files for each scheme related to this config file
TARGET_SUPPORT_DIR="Pods/Target Support Files/Pods-Runner"

for ((i = 0 ; i < nflavors ; i++)); do
    flavor=$(yq ".configFiles | keys.[$i]" "${PROJECT_FILE}")
    config_file=$(yq ".configFiles.${flavor}" "${PROJECT_FILE}")

    # Convert flavor to lowercase
    flavor=$(echo "${flavor}" | tr '[:upper:]' '[:lower:]')

    # Print if wanted
    echo "Scheme: ${flavor} (related config file ${config_file})"

    # Define target support file using lowercase of flavor
    target_support_file="${TARGET_SUPPORT_DIR}/Pods-Runner.${flavor}.xcconfig"

    if [ ! -f "${config_file}" ]; then
        echo "${config_file} not found."
        exit 1
    fi

    if cat "${config_file}" | grep "${target_support_file}" >/dev/null; then
        echo "Scheme target support file already included in config_file ${config_file}"
    else
        echo "#include? \"${target_support_file}\"" >> "${config_file}"
        echo "Added include $target_support_file in $config_file."
    fi
    echo ""

done

echo "Done - include target support files."
