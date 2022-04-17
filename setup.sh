#!/bin/bash

preview () {
  sed 1d ~/wikitongues-config ;
}

abort () {
  echo "Exiting without changes to configuration. "
}

writeDestination () {
  deleteVar='/^destination/d'
  sed -i '' $deleteVar ~/wikitongues-config
  read -r -p "Please enter the absolute path to where you want the Oral History directories to be created: $(printf '\n ')Example: /Users/$USER/Desktop/Wikitongues $(printf '\n> ') " destination
  printf 'destination="%s"\n' "$destination" >> ~/wikitongues-config ;
}

updateDestination () {
  read -r -p "Would you like to set your destination folder for Oral Histories? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      echo ""
      writeDestination
      ;;
    *)
      ;;
  esac
}

writeDestinationForLexicons () {
  deleteVar='/^lexiconDestination/d'
  sed -i '' $deleteVar ~/wikitongues-config
  read -r -p "Please enter the absolute path to where you want the Lexicon directories to be created: $(printf '\n ')Example: /Users/$USER/Desktop/Wikitongues $(printf '\n> ') " destination
  printf 'lexiconDestination="%s"\n' "$destination" >> ~/wikitongues-config ;
}

updateDestinationForLexicons () {
  read -r -p "Would you like to set your destination folder for Lexicons? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      echo ""
      writeDestinationForLexicons
      ;;
    *)
      abort ;
      ;;
  esac
}

echo "Welcome to the Wikitongues Oral History Maker setup script."

if [[ -f ~/wikitongues-config ]]; then
  # Update scripts and optionally prompt to update destination settings
  printf "A configuration file already exists. \n\n––––––––––––––––––––––––––––\n$(date)\n\nCurrent settings:\n" 
  preview
  echo ""
  echo "Installing script..."
  sleep .8 
  cp mkvid.sh /usr/local/bin/mkvid
  chmod +x /usr/local/bin/mkvid
  cp mklex.sh /usr/local/bin/mklex
  chmod +x /usr/local/bin/mklex
  updateDestination
  updateDestinationForLexicons
else
  # Fresh install
  echo "Installing script..."
  sleep .8 
  cp mkvid.sh /usr/local/bin/mkvid
  chmod +x /usr/local/bin/mkvid
  cp mklex.sh /usr/local/bin/mklex
  chmod +x /usr/local/bin/mklex
  echo "Configuring script. Creating a wikitongues-config file..."
  sleep 1 ;
  printf "# This wikitongues-config file is necessary for Wikitongues utilities like making oral history directories and working on the archives.\n" > ~/wikitongues-config
  echo 'method="/usr/local/bin/mkvid"' >> ~/wikitongues-config ;
  writeDestination
  writeDestinationForLexicons
  
  printf 'metadata="'"$(pwd)"'"\n' >> ~/wikitongues-config ;
  printf "\nSetup complete.\nSettings file can be located at ~/wikitongues-config\n\nPreview below:\n" ;

  if [[ ! -f ./.env ]]; then
    printf "\nAccess to the Airtable database is necessary for the automatic creation of metadata files.\n"
    
    read -r -p "Would you like to configure your Airtable access now? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
        touch .env
        read -r -p "Please enter your Airtable API key: (Please reach out to your supervisor if you need help)$(printf '\n ')" key
        printf 'APIKEY=%s\n' "$key" >> .env ;
        read -r -p "Please enter the Wikitongues Base ID: $(printf '\n ')" base
        printf 'BASE=%s\n' "$base" >> .env ;
        echo "airtableConfig=true" >> ~/wikitongues-config ;
        sleep .7
        echo "Airtable API access successfully configured!"
        ;;
      *)
        abort ;
        ;;
    esac
  else
    echo "airtableConfig=true" >> ~/wikitongues-config ;
  fi
  preview	;
fi