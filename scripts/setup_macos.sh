#!/bin/bash

# Script to install and setup the required toolchain

# Helper functions

function log () {
  echo -e "\033[36m"
  echo "#########################################################"
  echo "#### $1 "
  echo "#########################################################"
  echo -e "\033[m"
}

setup() {
  UNAME=$(uname)

  if [ "$UNAME" != "Darwin" ]; then
      echo "Currently only MacOS is supported by this automatic setup script"
      exit 1
  fi

  # Install `homebrew` dependencies
  log "Installing Homebrew packages"

  if ! type "brew" > /dev/null; then
      echo "Please install Homebrew (https://brew.sh/)"
      exit
  else
      for pkg in google-chrome-canary; do
          if brew cask list -1 | grep -q "^${pkg}\$"; then
              echo "Package '$pkg' is already installed"
          else
              echo "Package '$pkg' is not installed"

              # Convert
              log "Installing Google Chrome Canary"
              brew tap homebrew/cask-versions && brew cask install google-chrome-canary
          fi
      done
  fi
}

# Main script

setup

log "Done!"