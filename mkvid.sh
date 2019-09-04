#!/bin/bash
# Version 3.0 of the Wikitongues Oral History Template Instantiator

# ~/wikitongues-config is where the necessary locations for this operation get stored.
# The file is created by the setup.sh script.
source ~/wikitongues-config
# The method address is the absolute path to the directory where this file lives in
method=$method
# The destination address is the absolute path to where you want the oral history templates to be created.
destination=$destination

# Reads flags
flagger () {
  open=false
  dev=false
  videos=()
  for arg in "$@"; do
    if [[ $arg == "-d" || $arg == "--dev" ]]; then
      dev=true
    elif [[ $arg == "-o" || $arg == "--open" ]]; then
      open=true
    else
      videos+=("$arg")
    fi
  done
}

# Method Runner
video () {
  if [ -z "${videos[*]}" ]; then
    echo "Please specify at least once video ID"
    exit 1
  else
    for arg in ${videos[*]}; do
      directorator "$arg"
    done
    if [[ $open == true ]]; then
      for arg in ${videos[*]}; do
        open "$destination"/"$arg"
      done
    fi
  fi
}

# Instantiate Oral History directory
directorator () {
  if [ -d "$destination"/"$1" ]; then
    printf "A directory named %s already exists in this location.\n" "$1"
  else
    for i in thumbnail Premier\ Project; do
      mkdir -p "$destination"/"$1"/raws/"$i"
    done
    for j in clips converted audio captions; do
      mkdir -p "$destination"/"$1"/raws/footage/"$j"
    done
    node "$method"/single.js "$1" "$method" "$destination"
    if [ -d "$destination"/"$1" ]; then
      printf "Oral History Directory Successfully Created For %s.\n" "$1"
    else
      echo "Something went wrong"
    fi
  fi
}

# Runner
# Check if settings are configured
if [[ -f ~/wikitongues-config ]]; then
  if [[ -z $method || -z $destination ]]; then
    echo "Please configure your settings at the top of your mkvid file."
  else
    flagger "$@"
    if [[ $dev == true ]]; then
      video "$@"
    else
      # Check if repository has changed
      if cd $method && git diff-index --quiet HEAD --; then
        video "$@"
      else
        echo "This repository is out of date. Please pull new changes from Github."
      fi
    fi
  fi
else
  printf "\nSettings not configured.\nFrom within the mkvid directory, please run the setup script: \n> ./setup\n"
fi