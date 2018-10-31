#!/bin/bash

# Script to start the Chrome Canary V8 profiler

# Helper functions

function log () {
  echo -e "\033[36m"
  echo "#########################################################"
  echo "#### $1 "
  echo "#########################################################"
  echo -e "\033[m"
}

run() {
    LOCATION=$1
    LOG_DIRECTORY=$2
    LOG_OUTPUT=$3
    LOG_ERROR=$4
    REMOTE_PORT=$5

    log "Starting the Chrome Canary V8 profiler"

    mkdir -p $LOG_DIRECTORY
    touch $LOG_OUTPUT
    touch $LOG_ERROR

    echo -e "Starting Chrome Canary with custom profiling flags\n"

    /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary $LOCATION --incognito --remote-debugging-port=$REMOTE_PORT --js-flags="--trace-opt --trace-deopt --trace-file-names" > $LOG_OUTPUT 2> $LOG_ERROR
}

# Main script

LOCATION="${1:-localhost\:8080}"
LOG_DIRECTORY="${2:-logs}"
LOG_OUTPUT="${3:-logs/chrome_canary_output.log}"
LOG_ERROR="${4:-logs/chrome_canary_error.log}"
REMOTE_PORT="${5:-9222}"

run $LOCATION $LOG_DIRECTORY $LOG_OUTPUT $LOG_ERROR $REMOTE_PORT

log "Done!"