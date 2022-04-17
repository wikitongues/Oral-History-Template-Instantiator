#!/bin/bash

error () {
  printf "\e[31m$1\e[0m\n" "${@:2}"
}

success () {
  printf "\e[32m$1\e[0m\n" "${@:2}"
}

warning () {
  printf "\e[33m$1\e[0m\n" "${@:2}"
}

println () {
  printf "$1\n" "${@:2}"
}

# ~/wikitongues-config is where the necessary locations for this operation get stored.
# The file is created by the setup.sh script.
if [[ ! -f ~/wikitongues-config ]]; then
  error "Settings not configured."
  println "From within the Oral-History-Template-Instantiator directory, please run the setup script: "
  println "> ./setup.sh"
  exit 1
fi

source ~/wikitongues-config

# The metadata address is the absolute path to where the airtable API script live
metadataPath=$metadata
# The destination address is the absolute path to where you want the lexicon templates to be created.
destination=$lexiconDestination

if [[ -z $destination ]]; then
  error "Settings not configured for mklex."
  println "From within the Oral-History-Template-Instantiator directory, please run the setup script: "
  println "> ./setup.sh"
  exit 1
fi

# Reads flags
flagger () {
  open=false
  dev=false
  makeMetadataFile=true
  lexicons=()
  identifiers=()
  for arg in "$@"; do
    if [[ $arg == '-d' || $arg == '--dev' ]]; then
      dev=true
    elif [[ $arg == '-o' || $arg == '--open' ]]; then
      open=true
    else
      lexicons+=("$arg")
    fi
  done
  if [[ ! $airtableConfig || $airtableConfig == false ]]; then
    makeMetadataFile=false
    warning "Airtable API not configured. No metadata file will be automatically produced."
  fi
}

runner () {
  destination="$1"

  if [ -z "${lexicons[*]}" ]; then
    warning "Please specify at least one lexicon ID"
    exit 1
  fi

  for lexiconId in ${lexicons[*]}; do
    directorator "$destination" "$lexiconId"
  done
  if [[ $open == true ]]; then
    for id in ${identifiers[*]}; do
      open "$destination"/"$id"
    done
  fi
}

directorator () {
  destination="$1"
  lexiconId="$2"

  identifier=$(renamer "$destination" "$lexiconId")
  identifiers+=("$identifier")

  if [ "$identifier" != "$lexiconId" ]; then
    warning "Directory for %s is named %s for archival compatibility." "$lexiconId" "$identifier"
  fi

  if [ -d "$destination"/"$identifier" ]; then
    println "A directory named %s already exists in this location. Skipping." "$identifier"
    return
  fi

  mkdir "$destination"/"$identifier"

  if [[ $makeMetadataFile == true ]]; then
    node "$metadataPath"/getLexiconMetadata.js "$lexiconId" "$metadata" "$destination" "$identifier"
    if [ $? != 0 ]; then
      rm -r "$destination"/"$identifier"
      exit 1
    fi
  fi

  if [ -d "$destination"/"$identifier" ]; then
    success "Lexicon directory successfully created for %s." "$lexiconId"
  else
    error "Something went wrong."
    exit 1
  fi
}

# Rename directory to S3-compliant identifier for LOC archival
renamer () {
  destination="$1"
  lexiconId="$2"

  # Convert to ascii characters
  identifier=$(echo "$lexiconId" | iconv -f UTF-8 -t ascii//TRANSLIT//ignore)

  # Remove characters left by Mac iconv implementation
  identifier=${identifier//[\'\^\~\"\`]/''}

  # Change + to -
  identifier=${identifier//\+/'-'}

  echo "$identifier"
}

flagger "$@"

if [[ $dev == true ]]; then
  runner "."
else
  runner "$destination"
fi
