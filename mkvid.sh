#!/bin/bash
# Version 3.0 of the Wikitongues Oral History Template Instantiator

# ~/wikitongues-config is where the necessary locations for this operation get stored.
# The file is created by the setup.sh script.
source ~/wikitongues-config
# The method address is the absolute path to the directory where this file lives in
method=$method
# The destination address is the absolute path to where you want the oral history templates to be created.
destination=$destination

source $metadata/.env
APIKEY=$APIKEY
BASE=$BASE

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
    if [[ $makeMetadataFile == true ]]; then
	    node "$metadataPath"/single.js "$2" "$metadata" "$1"
	    metadataMaker $@
		fi    
    if [ -d "$1"/"$2" ]; then
      printf "\e[32mOral History Directory Successfully Created For %s.\n\e[0m" "$2"
    else
      echo "\e[31mSomething went wrong\e[0m"
    fi
  fi
}

metadataMaker () {
	cd $2
	curl -s https://api.airtable.com/v0/$BASE/Oral%20Histories\?filterByFormula\="identifier='$2'" -H "Authorization: Bearer $APIKEY" | jq -r '.records[]["fields"]' > metadata_full.json 
	cat metadata_full.json | jq -rc '{ "Oral History ID": ."Identifier", 
	"Languages by ISO 639-3 Code": [."Languages: ISO Code (639-3)"[]], 
	"Language Names": [."Language names"[]], 
	"Alternate Names": ."Languages: Speaker preferred names", 
	"Speakers": [."Contributor: Speakers"[]], 
	"Video Description": ."Description", 
	"Original Submitter": [."Creator"[]], 
	"Licenses": [."Rights"[]], 
	"Video Nation": [."Subject: Language Nation of Origin"[]], 
	"Video Territory": [."Coverage: Video Territory"[]], 
	"Published to Youtube on": ."Youtube Publish Date", 
	"Wikimedia Status": ."Wikimedia Eligibility", 
	"Wiki Commons URL": ."Wiki Commons URL" }' > metadata_processing.json

	printf "Metadata for $2\n\n" > output.txt
	cat metadata_processing.json | sed $'s/[{}]//g ; s/[^httpsFile]:/: /g ; s/null,"/null\\\n"/g; s/","/"\\\n"/g ; s/"//g' >> output.txt
	
	# Map secondary params
	for i in "Languages" "Speakers" "Submitter" "Licenses" "Nation"; do
		grep "$i" output.txt | cut -d ':' -f2- | xargs echo $i= | sed 's/ //g' >> keys.tmp
	done

	# Query secondary params
	source keys.tmp
	lan=$(curl -s https://api.airtable.com/v0/$BASE/Languages/$Languages -H "Authorization: Bearer $APIKEY" | jq -r '.["fields"] | .Identifier')
	spe=$(curl -s https://api.airtable.com/v0/$BASE/Contributors/$Speakers -H "Authorization: Bearer $APIKEY" | jq -r '.["fields"] | .ID')
	sub=$(curl -s https://api.airtable.com/v0/$BASE/Contributors/$Submitter -H "Authorization: Bearer $APIKEY" | jq -r '.["fields"] | .ID')
	lic=$(curl -s https://api.airtable.com/v0/$BASE/Rights/$Licenses -H "Authorization: Bearer $APIKEY" | jq -r '.["fields"] | .Name')
	nat=$(curl -s https://api.airtable.com/v0/$BASE/Languages/$Nation -H "Authorization: Bearer $APIKEY" | jq -r '.["fields"] | .Polities')
	sed -i '' -e "s/^Languages by ISO 639-3 Code: $Languages/Languages by ISO 639-3 Code: $lan/g" \
		-e "s/^Speakers: $Speakers/Speakers: $spe/g" \
		-e "s/^Original Submitter: $Submitter/Original Submitter: $sub/g" \
		-e "s/^Licenses: $Licenses/Licenses: $lic/g" \
		-e "s/^Video Nation: $Nation/Video Nation: $nat/g" output.txt	
	
	# Add empty lines for formatting
	# sed -i '' -e $'s/^Video Description:/\\\nVideo Description:/g' \
	# 	-e  $'s/^Original Submitter:/\\\nOriginal Submitter:/g' \
	# 	-e $'s/^Published to Youtube on:/\\\nPublished to Youtube on:/g' output.txt


	# rm keys.tmp metadata_full.json metadata_processing.json
	# mv output.txt "$2__metadata.txt"

	cd ..
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
        printf "\e[31mAn update to the code is available. Please run the command 'git pull'.\e[0m"
      fi
    fi
  fi
else
  printf "\e[31m\nSettings not configured.\e[0m\nFrom within the mkvid directory, please run the setup script: \n> ./setup\n"
fi