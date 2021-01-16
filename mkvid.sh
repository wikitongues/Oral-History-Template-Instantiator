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
  identifiers=()
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
    echo "\e[33mPlease specify at least once video ID\e[0m"
    exit 1
  else
    for arg in ${videos[*]}; do
      directorator "$arg"
      renamer "$arg"
    done
    if [[ $open == true ]]; then
      for arg in ${identifiers[*]}; do
        open "$destination"/"$arg"
      done
    fi
  fi
}

# Instantiate Oral History directory
directorator () {
  if [ -d "$destination"/"$1" ]; then
    printf "\e[31mA directory named\e[0m %s \e[31malready exists in this location.\n\e[0m" "$1"
  else
    for i in thumbnail Premier\ Project; do
      mkdir -p "$destination"/"$1"/raws/"$i"
    done
    for j in clips converted audio captions; do
      mkdir -p "$destination"/"$1"/raws/footage/"$j"
    done
    node "$method"/single.js "$1" "$method" "$destination"
    if [ -d "$destination"/"$1" ]; then
      printf "\e[32mOral History Directory Successfully Created For %s.\n\e[0m" "$1"
    else
      echo "\e[31mSomething went wrong\e[0m"
    fi
  fi
}

# Rename directory to S3-compliant identifier
renamer () {
  # Convert to ascii characters
  identifier=$(echo $1 | iconv -f UTF-8 -t ascii//TRANSLIT//ignore)

  # Remove characters left by Mac iconv implementation
  identifier=${identifier//[\'\^\~\"\`]/''}

  # Change + to -
  identifier=${identifier//\+/'-'}

  if [ $identifier != $1 ]; then
    mv "$destination"/"$1" "$destination"/"$identifier"
  fi

  identifiers+=("$identifier")
}

# Runner
# Check if settings are configured
if [[ -f ~/wikitongues-config ]]; then
  if [[ -z $method || -z $destination ]]; then
    printf "\e[31mSomething is wrong with your settings file.\e[0m\nFrom within the mkvid directory, please run the setup script again: \n> ./setup\n"
  else
    flagger "$@"
    if [[ $dev == true ]]; then
      video "$@"
    else
      # Check if repository has changed
      if cd "$method" && git diff-index --quiet HEAD --; then
        video "$@"
      else
        printf "\e[31mYour 'mkvid' repository is out of date. Please pull new changes from Github.\e[0m"
      fi
    fi
  fi
else
  printf "\e[31m\nSettings not configured.\e[0m\nFrom within the mkvid directory, please run the setup script: \n> ./setup\n"
fi