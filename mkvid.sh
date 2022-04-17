#!/bin/bash

# todo 
# pass flags to app 

# Version 4.0 of the Wikitongues Oral History Template Instantiator

# ~/wikitongues-config is where the necessary locations for this operation get stored.
# The file is created by the setup.sh script.
source ~/wikitongues-config
# The method address is the absolute path to the directory where this file lives in
method=$method
# The metadata address is the absolute path to where the airtable API script live
metadataPath=$metadata
# The destination address is the absolute path to where you want the oral history templates to be created.
destination=$destination
airtableConfig=$airtableConfig

# Reads flags
flagger () {
  open=false
  dev=false
  makeMetadataFile=true
  videos=()
  identifiers=()
  for arg in "$@"; do
    if [[ $arg == "-d" || $arg == "--dev" ]]; then
      dev=true
    elif [[ $arg == "-o" || $arg == "--open" ]]; then
      open=true
    elif [[ $arg == "--no-metadata" ]]; then
    	makeMetadataFile=false
    else
      videos+=("$arg")
    fi
  done
  if [[ ! $airtableConfig || $airtableConfig == false ]]; then
  	makeMetadataFile=false
  	printf "\e[33mAirtable API not configured. No metadata file will be automatically produced.\e[0m\n"
  fi
}

# Method Runner
video () {
  destination="$1"

  if [ -z "${videos[*]}" ]; then
    printf "\e[33mPlease specify at least once video ID\e[0m\n"
    exit 1
  fi

  for arg in ${videos[*]}; do
    directorator "$destination" "$arg"
  done
  if [[ $open == true ]]; then
    for id in ${identifiers[*]}; do
      open "$destination"/"$id"
    done
  fi
}

# Instantiate Oral History directory
directorator () {
  destination="$1"
  ohId="$2"

  identifier=$(renamer "$destination" "$ohId")
  identifiers+=("$identifier")

  if [ "$identifier" != "$ohId" ]; then
    printf "\e[33mDirectory for %s is named %s for archival compatibility.\n\e[0m" "$ohId" "$identifier"
  fi

  if [ -d "$destination"/"$ohId" ]; then
    printf "\e[31mA directory named\e[0m %s \e[31malready exists in this location.\n\e[0m" "$ohId"
  else
    for i in thumbnail Premier\ Project; do
      mkdir -p "$destination"/"$ohId"/raws/"$i"
    done
    for j in clips converted audio captions; do
      mkdir -p "$destination"/"$ohId"/raws/footage/"$j"
    done
    if [[ $makeMetadataFile == true ]]; then
	    node "$metadataPath"/single.js "$ohId" "$metadata" "$destination" "$identifier"
		fi    
    if [ -d "$destination"/"$ohId" ]; then
      printf "\e[32mOral History Directory Successfully Created For %s.\n\e[0m" "$ohId"
    else
      printf "\e[31mSomething went wrong\e[0m\n"
    fi
  fi
}

# Rename directory to S3-compliant identifier for LOC archival
renamer () {
  destination="$1"
  ohId="$2"

  # Convert to ascii characters
  identifier=$(echo $ohId | iconv -f UTF-8 -t ascii//TRANSLIT//ignore)

  # Remove characters left by Mac iconv implementation
  identifier=${identifier//[\'\^\~\"\`]/''}

  # Change + to -
  identifier=${identifier//\+/'-'}

  echo "$identifier"
}

# Runner
# Check if settings are configured
if [[ -f ~/wikitongues-config ]]; then
  if [[ -z $method || -z $destination ]]; then
    printf "\e[31mSomething is wrong with your settings file.\e[0m\nFrom within the mkvid directory, please run the setup script again: \n> ./setup\n"
  else
    flagger "$@"
    if [[ $dev == true ]]; then
      video "."
    else
      # Check if repository has changed
      # if cd "$metadata" && git diff-index --quiet HEAD --; then
	    video "$destination"
     #  else
      	
     #  	read -r -p "An update to the code is available. Would you like to create an oral history folder template with the old version? [y/N] " response
     #    case "$response" in
	    #   [yY][eE][sS]|[yY])
					# video "$destination" "$@"
	    #     ;;
	    #   *)
	    #     printf "Exiting without changes. To fix this issue, please run the Setup script again: \n$ bash setup.sh\n"
	    #     ;;
	    # esac
     #  fi
    fi
  fi
else
  printf "\e[31m\nSettings not configured.\e[0m\nFrom within the mkvid directory, please run the setup script: \n> ./setup\n"
fi