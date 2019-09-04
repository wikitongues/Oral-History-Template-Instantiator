#!/bin/bash
printf "# This wikitongues-config file is necessary for wikitongues utilities like making oral history directories and working on the archives.\n" > ~/wikitongues-config
printf "Oral History Template Instantiator Settings.\n"
read -p "Please enter the absolute path to the mkvid repository directory: `echo $'\n> '`" method
printf "method=$method\n" >> ~/wikitongues-config
read -p "Please enter the absolute path to the dropbox oral histories directory: `echo $'\n> '`" destination
printf "destination=$destination\n" >> ~/wikitongues-config
printf "\nSetup complete.\nSettings file can be located at ~/wikitongues-config\n\nPreview below:\n\n"
cat ~/wikitongues-config