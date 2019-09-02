#!/bin/bash
# Version 3.0 of the Wikitongues Oral History Template Instantiator

metadatarator=/Users/Amicus/Documents/Work/Active/Wikitongues/Git/Airtable-API/single.js

# Method Runner
video () {
  videos=()
  open=false
  if [ -z "$1" ]; then
    echo "Please specify at least once video ID"
    exit 1
  else
    for arg in $@; do
      if ! [[ "$arg" == "-o" ||  "$arg" == "--open" ]]; then
        directorator "$arg"
        videos+=("$arg")
      else
        open=true
      fi
    done
    if [[ $open == true ]]; then
      for i in "${videos[*]}"; do
        open $i
      done
    fi
  fi
}

# Instantiate Oral History directory
directorator () {
  if [ -d "$1" ]; then
    echo "A directory named '$1' already exists in this location."
  else
    for i in thumbnail Premier\ Project; do
      mkdir -p "$1"/raws/"$i"
    done
    for j in clips converted audio captions; do
      mkdir -p "$1"/raws/footage/"$j"
    done
    node $metadatarator "$1"
    echo "Oral History Directory Successfully Created For '$1'"
  fi
}

# Check if repository has changed
if git diff-index --quiet HEAD --; then
  video $@
else
  echo "Something is out of date. Please pull new changes from Github."
fi