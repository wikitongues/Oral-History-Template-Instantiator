#!/bin/bash
printf "# This wikitongues-config file is necessary for wikitongues utilities like making oral history directories and working on the archives.\n" > ~/wikitongues-config
printf "Oral History Template Instantiator Settings.\n"
read -r -p "Please enter the absolute path to the mkvid repository directory: $(printf '\n> ')" method
printf 'method="%s"\n' "$method" >> ~/wikitongues-config
echo ""
read -r -p "Please enter the absolute path to where you want the Oral Historiy directories to be created: $(printf '\n> ')" destination
printf 'destination="%s"\n' "$destination" >> ~/wikitongues-config
printf "\nSetup complete.\nSettings file can be located at ~/wikitongues-config\n\nPreview below:\n\n"
cat ~/wikitongues-config