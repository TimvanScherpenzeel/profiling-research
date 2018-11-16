#!/bin/bash

# Script to start the Chrome Canary V8 profiler

# Configuration
LOCATION="${1:-http://localhost:8080}"
LOG_DIRECTORY="${2:-logs}"
LOG_OUTPUT="${3:-logs/chrome_canary_output.log}"
LOG_ERROR="${4:-logs/chrome_canary_error.log}"
BASE_TEMP_PROFILE_DIR="${5:-/tmp}"

# Temporary profile
TEMP_PROFILE_DIR=$(mktemp -d $BASE_TEMP_PROFILE_DIR/google-chome.XXXXXXX)

# Helper functions

function log () {
  echo -e "\033[36m"
  echo "#########################################################"
  echo "#### $1 "
  echo "#########################################################"
  echo -e "\033[m"
}

run() {
    log "Starting the Chrome Canary V8 profiler"

    mkdir -p $LOG_DIRECTORY
    touch $LOG_OUTPUT
    touch $LOG_ERROR

    echo -e "Starting Chrome Canary with custom profiling flags\n"

    echo -e "Created temporary profile folder in $TEMP_PROFILE_DIR"

    # Opening chrome://tracing is not allowed from the command line
    echo -e "Please open \"chrome://tracing\" to start V8 tracing in a new browser tab\n"

    /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary $LOCATION --incognito --disable-gpu-vsync --disable-frame-rate-limit --ignore-gpu-blacklist --user-data-dir=$TEMP_PROFILE_DIR --no-first-run --js-flags="--trace-file-names --trace-opt --trace-deopt --print-opt-source --code-comments" 1> $LOG_OUTPUT 2> $LOG_ERROR

    echo -e "Cleaning up temporary profile folder in $TEMP_PROFILE_DIR"

    rm -rf $TEMP_PROFILE_DIR
}

# Main script

run

log "Done!"