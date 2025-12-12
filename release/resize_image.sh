#!/bin/bash
#
# Time-stamp: Tuesday 2025-12-09 16:27:08 Jess Moore
#
# Resize image dimensions
#
# Usage: resize_image.sh [args...]

function usage() {
    echo "Usage: resize_image.sh type width height"
    echo ""
    echo "Description: Resize image dimensions using Imagemagick 'convert'. Note: required dimensions of screenshots for MacOS App Store are 1400 x 900"
    echo ""
    echo "Arguments:"
    echo "  type:    Type of app (macos/iphone/ipad)"
    echo "  width:   Width in pixels."
    echo "  height:  Height in pixels."
    echo ""
    exit 1 # Exit with a non-zero status to indicate an error
}

if [[ $* == *"help"* || $* == *"-h"* ]]; then
    usage
fi

if [[ $# -eq 3 ]]; then
    TYPE=$1
    NEW_WIDTH=$2
    NEW_HEIGHT=$3
else
    echo "Provide 'type', 'width' and height'."
    usage
fi

RAW_DIR="screenshots/${TYPE}/raw"
RESIZED_DIR="screenshots/${TYPE}/resized"

if [[ ! -d ${RAW_DIR} ]]; then
    echo "${RAW_DIR} not found. Make sure ${TYPE} directory exists."
    usage
fi

size_new="${NEW_WIDTH} x ${NEW_HEIGHT}"

mkdir -p "${RESIZED_DIR}"
cd "${RAW_DIR}" || exit 1

for i in *.png; do
    outfile="../resized/$i"
    size_orig=$(identify -format '%w x %h' "$i")
    echo "file: $i with original size ${size_orig}"

    magick "$i" -resize "${NEW_WIDTH}x${NEW_HEIGHT}" -background black -gravity center -extent "${NEW_WIDTH}x${NEW_HEIGHT}" "$outfile"

    echo "Resized from ${size_orig} to ${size_new} and saved into ${RESIZED_DIR}"
    echo ""
done

cd ../../..
echo "Resized images:"
ls -lt "${RESIZED_DIR}"


echo "Done."
