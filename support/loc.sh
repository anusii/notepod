#!/bin/bash

IGNORE=false # Return an error if any files have more than N loc.
MAX=300 # Value of N loc.
CONCATE=false # Whether to simply count all lines across all files.
THRESHOLD=0
CLEAN=false

# Function to display help

show_help() {
    echo "Usage: $0 [options] <files>"
    echo ""
    echo "Options:"
    echo "  -c, --clean            Just filter the file to remove lines not counted."
    echo "  -i, --ignore           Ignore errors related to the line count threshold."
    echo "  -t, --total            Concatenate all supplied files and count total lines after cleansing."
    echo "  -n, --max-lines <n>    Set the maximum number of allowed lines (default: ${MAX})."
    echo "  -h, --help             Show this help message."
    exit 0
}

# Function to cleanse lines.

cleanse_lines() {
    # Remove:
    #   empty lines
    #   comment only lines
    #   import/library/@override
    #   lines that start with }, ) or ]
    #   lines that consist of '? [' or  ': ['
    #   begins a parameter list, like `   names: [`
    #
    awk 'NF && !/^\s*\/\/|^\s*(import|library|@override)|^\s*[})\]]|^\s*(\?|:) \[|\s*\w*: \[/' "$1"
}

wc_cleanse_lines() {
    cleanse_lines "$1" | wc -l
}



# Check for no arguments.

if [ "$#" -eq 0 ]; then
    show_help
fi

# Parse input arguments.

while [[ "$1" != "" ]]; do
    case $1 in
	-c | --clean)
	    CLEAN=true
	    shift
	    ;;
        -i | --ignore)
            IGNORE=true
            shift
            ;;
        -t | --total)
            CONCATE=true
            shift
            ;;
        -n | --max-lines)
            shift
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                THRESHOLD=$1
                shift
            else
                THRESHOLD=${MAX}
            fi
            ;;
        -h | --help)
            show_help
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

if [ "$CLEAN" = true ]; then
    for file in "${FILES[@]}"; do
        cleanse_lines "$file"
    done
    exit 0
fi

if [ "$CONCATE" = true ]; then
    # Concatenate all files and get total line count after cleansing then exit
    TOTAL_LINES=0
    for file in "${FILES[@]}"; do
        LINES=$(wc_cleanse_lines "$file")
        TOTAL_LINES=$((TOTAL_LINES + LINES))
    done
    echo "$TOTAL_LINES"
    exit 0
fi

# Check individual files for line count.

ERROR=false

if [ "$THRESHOLD" -gt 0 ]; then
    for file in "${FILES[@]}"; do
        LINES=$(wc_cleanse_lines "$file")
        if [ "$LINES" -gt "$THRESHOLD" ]; then
            printf "%4d %s\n" "$LINES" "$file"
            ERROR=true
        fi
    done
else
    for file in "${FILES[@]}"; do
        LINES=$(wc_cleanse_lines "$file")
        printf "%4d %s\n" "$LINES" "$file"
    done
fi

# Set exit status based on error occurrence
if [ "$ERROR" = true ]; then
    if [ "$IGNORE" = true ]; then
        exit 0
    else
        exit 1
    fi
fi

exit 0
