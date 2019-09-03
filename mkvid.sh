#!/bin/bash
# Version 3.0 of the Wikitongues Oral History Template Instantiator

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
        open "$arg"
      done
    fi
  fi
}

# Instantiate Oral History directory
directorator () {
  if [ -d "$1" ]; then
    printf "A directory named %s already exists in this location.\n" "$1"
  else
    for i in thumbnail Premier\ Project; do
      mkdir -p "$1"/raws/"$i"
    done
    for j in clips converted audio captions; do
      mkdir -p "$1"/raws/footage/"$j"
    done
    node single.js "$1"
    printf "Oral History Directory Successfully Created For %s. \n" "$1"
  fi
}

# Check if repository has changed
flagger "$@"
if [[ $dev == true ]]; then
  video "$@"
else
  if git diff-index --quiet HEAD --; then
    video "$@"
  else
    printf "This reporistory is out of date. Please pull new changes from Github.\n"
  fi
fi
