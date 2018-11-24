#!/bin/bash

# Script to start the Chrome Canary with V8 profiler flags

# Configuration
LOCATION="${1:-http://localhost:8080}"
LOG_DIRECTORY="${2:-logs}"
LOG_OUTPUT="${3:-logs/chrome_canary_output.log}"
LOG_ERROR="${4:-logs/chrome_canary_error.log}"
BASE_TEMP_PROFILE_DIR="${5:-/tmp}"
REMOTE_DEBUGGING_PORT="${6:-9222}"

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
    log "Starting the Chrome Canary with V8 profiler flags"

    mkdir -p $LOG_DIRECTORY
    touch $LOG_OUTPUT
    touch $LOG_ERROR

    echo -e "Starting Chrome Canary with custom profiling flags\n"

    echo -e "Created temporary profile folder in $TEMP_PROFILE_DIR"

    # Opening chrome://tracing is not allowed from the command line
    echo -e "Please open \"chrome://tracing\" in a new browser tab to start structural profiling\n"

    # Chrome flags

    # --incognito | Launches Chrome in incognito mode
    # --disable-gpu-vsync + --disable-frame-rate-limit | Disables the VSync and de-limits the 60 frames per second rate limiting imposed by Chrome
    # --no-default-browser-check | Disables a pop up window checking if Chrome is the default browser
    # --enable-precise-memory-info | Enables precise memory info (otherwise the results from performance.memory are bucketed and less useful)
    # --remote-debugging-port | Enables remote debugging using the DevTools API
    # --user-data-dir + --no-first-run | Chrome creates a user profile by default in a temporary directory and disable a pop up window checking if the user has a new profile

    # V8 flags

    # --trace-file-names | When tracing show the filename of the file where the optimized or de-optimized code is located
    # --trace-opt | Trace code optimisations of hot functions
    # --trace-deopt | Trace code de-optimisations of hot functions
    # --print-opt-source | Print the optimized source code and trace the difference
    # --code-comments | Comment the code where possible (useful for understanding the optimized and deoptimized source code)

    /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary $LOCATION --incognito --disable-gpu-vsync --disable-frame-rate-limit --no-default-browser-check --enable-precise-memory-info --remote-debugging-port=$REMOTE_DEBUGGING_PORT --user-data-dir=$TEMP_PROFILE_DIR --no-first-run --js-flags="--trace-file-names --trace-opt --trace-deopt --print-opt-source --code-comments" 1> $LOG_OUTPUT 2> $LOG_ERROR

    echo -e "Cleaning up temporary profile folder in $TEMP_PROFILE_DIR"

    rm -rf $TEMP_PROFILE_DIR
}

# Main script

run

log "Done!"