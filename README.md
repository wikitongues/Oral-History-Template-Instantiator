# Wikitongues
# Oral History Template Instantiator

This tool sets up the folder structure for new Wikitongues Oral Histories and Lexicons.

## Prerequisites

Read this section if you are new to using the command line.

This is a command line tool which you run using a **shell** (such as Terminal on a Mac). In the command line you can run specialized programs like this one, and you can also manage the files and folders on your computer. You do this by typing commands in a language that your computer understands.

If you have a Mac, you can find Terminal in the Utilities folder inside the Applications folder.

There are many tutorials on the internet for command line basics. A very good one is [The Bash Guide](https://guide.bash.academy/), which covers basic commands in the Bash language, as well as how to write scripts like the ones that make up this tool. 

There are many different command line languages; bash is one of the most common, and zsh is what is used by default in Terminal on recent Macs. bash and zsh have a high degree of mutual intelligibility and are both members of the Unix "language family", so basic commands will work in either. The differences are subtle, and if you run this tool from a zsh shell (i.e. Terminal), it will switch to bash so it runs correctly. (The Windows command prompt is essentially a different language family, so Unix commands will not work.)

The most important commands to know are:

* `pwd` (present working directory): Tells you what directory (another word for folder) your shell is currently in
  * It prints an **absolute path**, which is the **path** from the root of your hard drive
* `ls` (list): Lists the contents of the folder you're in
* `cd "folder name"` (change directory): Move to a new folder
  * If you enter an absolute path to a folder as an argument to `cd`, you can move to that folder from any other folder
  * `cd ..` goes back up one level
* `mkdir "folder name"` (make directory): Makes a new folder inside the `pwd`
* `mv "old name" "new name"`: Renames a file or folder
* `mv "old/path" "new/path"`: Moves a file or folder to the new path

## Setup

1. The following will need to be installed on your computer for the tool to work.

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git): Command line tool that provides access to the code repository on Github. The Oral History Template Instantiator uses it to check for updates.
  * On a Mac, the easiest way to install it is to first install Homebrew, and then use Homebrew to install git
    * Homebrew is a command line tool that lets you install other command line tools
    * Run this command to download and install Homebrew:
      * `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
    * Run this command to download and install Git, using Homebrew:
      * `brew install git`
      * Notice this command is a lot simpler than the first one; Homebrew greatly simplifies the installation process for us.
* [Node.js and npm (node package manager)](https://www.npmjs.com/get-npm)
  * This one has an installer that can be run without the command line
  * Node.js enables your computer to run portions of the code that are written in JavaScript
  * When we write the code we reference code written by others, so we don't have to reinvent the wheel every time we write a new program. For example, this program uses code written by the Airtable team to log on to our Airtable account and look up data. We use npm to download and install all this external code (known as dependencies).

2. Use git to download the Oral History Template Instantiator code from Github

* Run this command:
  * `git clone https://github.com/wikitongues/Oral-History-Template-Instantiator.git`
  * This process is called "cloning" because it saves an exact copy of the code onto your computer
  * It saves it into a new folder inside the present working directory of your command line
  * Once it has finished cloning, go into the folder: `cd Oral-History-Template-Instantiator`
    * Tip: You can start typing the folder name and then hit tab to auto-complete

3. Run the setup script

* Run this command:
  * `./setup.sh`
    * You are providing a **relative path** to `setup.sh`, which is the code file for the setup script
    * The `./` means the path is starting from the present working directory
  * You will be prompted for two absolute paths.
    * You can open a second command line window, use `cd` to navigate to the folders it's asking for, use `pwd` to print the absolute path, and then copy and paste it
  * The setup script writes a file called `wikitongues-config` to your home folder, which the Oral History Template Instantiator will read to find which folder to create the new oral history folders inside of
    * Tip: This file has the relative path `~/wikitongues-config`. The `~/` means that the path is starting from your home folder.

4. Get your Airtable API key

* API = Advanced Programming Interface: functionality provided by Airtable that allows programs we write to log in and access data
* The API key is a sequence of characters that is equivalent to your password; it lets the program log in to your account via the API
* Follow [these instructions](https://support.airtable.com/hc/en-us/articles/219046777-How-do-I-get-my-API-key-) to get your API key
  * Copy and paste the API key to a file or note on your computer
* You'll also need the Base ID, which is a string of characters representing the name of the Airtable Base
  * Log on to the [Airtable API web page](https://airtable.com/api) and click on the link for the Wikitongues archival base
  * Once the page is fully loaded there will be a line in the Introduction section saying "The ID of this base is", followed by green text starting with `app`
  * Copy and paste the Base ID to a file or note on your computer
* Go to the Oral History Template Instantiator folder in a command line
* Enter this command
  * `printf "APIKEY=<Your API Key>\nBASE=<Your Base ID>" > .env`
  * Replace `<Your API Key>` and `<Your Base ID>` with the actual API key and Base ID
  * This writes your API key and Base ID to a new file named .env
    * The Oral History Template Instantiator will read the file to get the Airtable info
    * Tip: Files with names starting with a `.` are hidden by default in Finder, and when you run `ls` in the command line. You can see them by running `ls -a` (list all). It is conventional for programmers to name files this way when users will not normally need to see or know about these files.
    * You can open the file in a text editor by running `open .env`. In the text editor you can edit and save it just like any other file.

5. Install dependencies

* Run this command to install the dependencies using npm:
  * `npm install`

Now you are ready to run the Oral History Template Instantiator.

## Usage
### Oral History Template
Run this command, replacing Identifier with an actual oral history identifier from Airtable.
```
mkvid "Identifier"
```
It will create a folder with this structure in the destination directory that you specified when running the setup script.
```
Identifier/
├── raws/
│   ├── footage/
│   │   ├── audio/
│   │   ├── captions/
│   │   ├── clips/
│   │   └── converted/
│   ├── Premier Project/
│   └── thumbnail/
└── Identifier__metadata.txt    Metadata retrieved from Airtable
```

### Lexicon Template
Run this command, replacing Identifier with an actual lexicon identifier from Airtable.
```
mklex "Identifier"
```
It will create a folder with this structure in the destination directory that you specified when running the setup script.
```
Identifier/
└── Identifier__metadata.txt    Metadata retrieved from Airtable
```

### Dev Mode

For development, run in dev mode to save oral history directories to the repository folder, and bypass the git version check:

```
./mkvid.sh "Identifier" -d
```
