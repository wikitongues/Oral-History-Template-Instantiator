#!/bin/bash

preview () {
	sed 1d ~/wikitongues-config ;
}

echo "Welcome to the Wikitongues Oral History Maker setup script."
if [[ -f ~/wikitongues-config ]]; then
  printf "A configuration file already exists. \n\n––––––––––––––––––––––––––––\n`date`\n\nCurrent settings:\n"
  preview
  if [[ -f /usr/local/bin/mkvid ]]; then
  	echo ""
  	read -r -p "Method successfully installed - change destination folder? y/n " response
	  case "$response" in
      [yY][eE][sS]|[yY])
        echo ""
        
        read -r -p "Please enter the absolute path to where you want the Oral History directories to be created: $(printf '\n> ')" destination
        echo $destination
				sed "s~destination=~destination=$destination~" ~/wikitongues-config

        ;;
      *)
        printf "Exiting without changes."
        ;;
    esac
  else
  	read -r -p "Method not installed - install now? [y/N] " response
	  case "$response" in
      [yY][eE][sS]|[yY])
        echo ""
        cp mkvid.sh /usr/local/bin/mkvid
        read -r -p "Method successfully installed - change destination folder? [y/N] " response
			  case "$response" in
		      [yY][eE][sS]|[yY])
		        echo ""
		        read -r -p "Please enter the absolute path to where you want the Oral History directories to be created: $(printf '\n> ')" destination
						printf 'destination="%s"\n' "$destination" >> ~/wikitongues-config
		        ;;
		      *)
		        printf "Exiting without changes."
		        ;;
		    esac
        ;;
      *)
        printf "Exiting without changes."
        ;;
    esac

  fi
else
  echo "Installing script..."
  cp mkvid.sh /usr/local/bin/mkvid
  echo "Configuring script. Creating a wikitongues-config file..."
  printf "# This wikitongues-config file is necessary for Wikitongues utilities like making oral history directories and working on the archives.\n" > ~/wikitongues-config
  echo ""
	echo 'method="/usr/local/bin/mkvid"' >> ~/wikitongues-config ;
	read -r -p "Please enter the absolute path to where you want the Oral History directories to be created: $(printf '\n> ')" destination
	printf 'destination="%s"\n' "$destination" >> ~/wikitongues-config ;

	printf 'metadata="'`pwd`'"\n' >> ~/wikitongues-config ;
	printf "\nSetup complete.\nSettings file can be located at ~/wikitongues-config\n\nPreview below:\n\n" ;

	preview	;
fi

