#!/bin/bash

# Script to start the Chrome Canary V8 profiler

# Configuration

LOCATION="${1:-http://localhost:8080}"
LOG_DIRECTORY="${2:-logs}"
LOG_OUTPUT="${3:-logs/chrome_canary_output.log}"
LOG_ERROR="${4:-logs/chrome_canary_error.log}"

# Helper functions

function log () {
  echo -e "\033[36m"
  echo "#########################################################"
  echo "#### $1 "
  echo "#########################################################"
  echo -e "\033[m"
}

cleanup() {
    rm -rf logs/*.log
}

run() {
    log "Starting the Chrome Canary V8 profiler"

    cleanup

    mkdir -p $LOG_DIRECTORY
    touch $LOG_OUTPUT
    touch $LOG_ERROR

    echo -e "Starting Chrome Canary with custom profiling flags\n"

    # Opening chrome://tracing is not allowed from the command line
    echo -e "Please open \"chrome://tracing\" to start V8 tracing in a new browser tab\n"

    /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary $LOCATION --incognito --no-sandbox --allow-file-access-from-files --js-flags="--trace-opt --trace-deopt --trace-file-names" > $LOG_OUTPUT 2> $LOG_ERROR
}

# Main script

run

log "Done!"