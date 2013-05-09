#!/usr/bin/env bash
# Copyright © Shaps 2013

# Documentation Properties
DOCS_URL="Help"
PROJECT_NAME=""
COMPANY_NAME=""
BUNDLE_ID=""
VERSION=""
GIT_CONFIRMED=false

# file names
SCRIPT_VERSION=1.2
SCRIPT_FILENAME=$(basename "${BASH_SOURCE[0]}")

# colors
DULL=0
BRIGHT=1

FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_VIOLET=35
FG_CYAN=36
FG_WHITE=37

FG_NULL=00

BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_VIOLET=45
BG_CYAN=46
BG_WHITE=47

BG_NULL=00

##
# ANSI Escape Commands
##
ESC="\033"
NORMAL="\[$ESC[m\]"
RESET="$ESC[${DULL};${FG_WHITE};${BG_NULL}m"

##
# Shortcuts for Colored Text ( Bright and FG Only )
##

# DULL TEXT
BLACK="\[$ESC[${DULL};${FG_BLACK}m\]"
RED="$ESC[${DULL};${FG_RED}m"
GREEN="\[$ESC[${DULL};${FG_GREEN}m\]"
YELLOW="\[$ESC[${DULL};${FG_YELLOW}m\]"
BLUE="$ESC[${DULL};${FG_BLUE}m"
VIOLET="\[$ESC[${DULL};${FG_VIOLET}m\]"
CYAN="\[$ESC[${DULL};${FG_CYAN}m\]"
WHITE="\[$ESC[${DULL};${FG_WHITE}m\]"

# BRIGHT TEXT
BRIGHT_BLACK="\[$ESC[${BRIGHT};${FG_BLACK}m\]"
BRIGHT_RED="\[$ESC[${BRIGHT};${FG_RED}m\]"
BRIGHT_GREEN="\[$ESC[${BRIGHT};${FG_GREEN}m\]"
BRIGHT_YELLOW="\[$ESC[${BRIGHT};${FG_YELLOW}m\]"
BRIGHT_BLUE="$ESC[${BRIGHT};${FG_BLUE}m"
BRIGHT_VIOLET="\[$ESC[${BRIGHT};${FG_VIOLET}m\]"
BRIGHT_CYAN="\[$ESC[${BRIGHT};${FG_CYAN}m\]"
BRIGHT_WHITE="\[$ESC[${BRIGHT};${FG_WHITE}m\]"

# REV TEXT as an example
REV_CYAN="\[$ESC[${DULL};${BG_WHITE};${BG_CYAN}m\]"
REV_RED="\[$ESC[${DULL};${FG_YELLOW}; ${BG_RED}m\]"

BOLD="tput bold"
NORMAL="tput normal"
BELL="tput bel"

# URLs
LOG_URL=~/.tmp/appledoc.log
APPLEDOC_URL=/usr/local/bin/appledoc
TMP_URL=~/.tmp/appledoc.zip
TMP_PATH=~/.tmp/appledoc-master
BIN_URL=/usr/local/bin
CONFIG_URL=".adconfig"
DOCS_URL="Help"
DOCSET_URL="$HOME/Library/Developer/Shared/Documentation/DocSets"
BUILD_URL="/tmp/appledoc.dst/usr/local/bin/appledoc"
TEMPLATES_URL="$HOME/.appledoc"
SITE_URL="http://gentlebytes.com"
DOWNLOAD_URL="https://nodeload.github.com/tomaz/appledoc/zip/master"

# Arguments
DEBUG=false

printHelp() {
cat <<EOF

Usage: $SCRIPT_FILENAME [-x] [-m] [-d] [-l] [-p] [-r] [-q] [-u]

Configures and generates appledoc documentation.
However this script is in no way affiliated with Gentle Bytes. 

OPTIONS:
  
EOF

printf "	${RED}-x${RESET}	By default we install to Xcode, passing x disables this.\n"
printf "	${RED}-m${RESET}	Merge categories to classes.\n"
printf "	${RED}-d${RESET}	Forces appledoc to be installed using DEBUG settings.\n"
printf "	${RED}-l${RESET}	Print full installation log from file. '~/.tmp/appledoc.log'\n"
printf "	${RED}-p${RESET}	Print config. '$CONFIG_URL'\n"
printf "	${RED}-r${RESET}	Reset config. '$CONFIG_URL'\n"
printf "	${RED}-q${RESET}	Quiet output. Prompts will still be shown.\n"
printf "	${RED}-u${RESET}	Update appledoc installation. '$APPLEDOC_URL'
		Downloads and installs from '$DOWNLOAD_URL'\n"
printf "	${RED}-v${RESET}	Print script version.\n\n"

printf	"		Get more information about appledocs:\n"
printf	"	-	${BLUE}http://appledoc.gentlebytes.com/${RESET}\n"
printf 	"	- 	${BLUE}http://tomaz.github.com/appledoc/${RESET}\n\n"

printf "		Get help or support with this script:\n"
printf "	-	${BLUE}http://shaps.me${RESET}\n"
printf "	-	${BLUE}shaps80@me.com${RESET}\n\n"
}

printInvalidVersion() {
cat <<EOF
${0}: invalid version -- $1

The version number must contain only numbers.
Whole numbers (e.g. 1, 3, 12) are not accepted.
Acceptable formats are 1.0, 1.0.1, 1.0.0.1, etc...

EOF
}

prompt() {
	read -s -n 1 yn
	if [[ $yn = "" ]]; then
		echo "y"
		return 0
	else
		case $yn in
			[Yy]*)	printf "\n";
					return 0 ;; 
		        *) 	if [[ ! $1 ]]; then
						printf "\nGoodbye!\n\n"; 
						exit 0
					fi
					;;
		esac
	fi
}

findProjects() {
	if [[ ! $QUIET ]]; then
		printf "DONE | Current directory (${PWD//$HOME/~})\n"
	fi
	
	count=($(find . -regex '.*\(xcodeproj\)' | wc -w))
	
	if [[ $count = 1 ]]; then
		results=($(find . -regex '.*\(xcodeproj\)'))
		if [[ ! $QUIET ]]; then
			printf "DONE | Found Xcode project ($results)\n"
		fi
		return 0
	else
		printBlue "WARN | $count Xcode projects found! Continue anyway (Y/n)? "
		prompt
	fi	
}

validateVersion() {
	value=$1

	printf "Please enter a value for ${BRIGHT_BLUE}$1${RESET}: "	
	read value
	while [[ ! $value =~ ^[0-9]+([.][0-9]+)+([.][0-9]+)?$ ]]; do
		printInvalidVersion $value
		printf "Please enter a value for ${BRIGHT_BLUE}$1${RESET}: "	
		read value		
	done
	
	eval VERSION=$value
}

validateVariable() {
	value=$2
	
	printf "Please enter a value for ${BRIGHT_BLUE}$1${RESET}: "
	while [ -z "$value" ]; do 
		read value
	done

	eval $1='\"$value\"'
}

getFolderName() {
	printf "\nPlease enter a name for the output folder: "
	read value
	
	while [ -z "$value" ]; do 
		read value
	done
	DOCS_URL=\"$value\"
	
	printf "\n"
}

confirmGIT() {
	git rev-parse > /dev/null 2>&1
	
	if [[ $? -ne 0 ]]; then
		return 0
	fi
	
	status='git ls-files $CONFIG_URL --error-unmatch >> $LOG_URL 2>&1'
	eval $status

	if [[ $? -ne 0 ]]; then
		printBlue "WARN | Config is NOT under version control. Add '$CONFIG_URL' to the repository (Y/n)? "
		read -sn 1 yn
	
		case $yn in
			[Nn]*)	printf "\n" ;;
		        *) 	git add $CONFIG_URL
					printf "\nDONE | Config is now under version control\n"
					;;
		esac
	else
		printf "DONE | Config is under version control ($CONFIG_URL)\n"
	fi

	# echo GIT_CONFIRMED=true >> $CONFIG_URL
}

configure() {
	printf "Configuration for this project will be saved to $CONFIG_URL\n\n"
	
	validateVariable BUNDLE_ID $BUNDLE_ID
	validateVariable COMPANY_NAME $COMPANY_NAME
	validateVariable PROJECT_NAME $PROJECT_NAME
	validateVersion VERSION $VERSION
	getFolderName
	
	echo DOCS_URL="$DOCS_URL" >> $CONFIG_URL
	echo BUNDLE_ID="$BUNDLE_ID" >> $CONFIG_URL
	echo COMPANY_NAME="$COMPANY_NAME" >> $CONFIG_URL
	echo PROJECT_NAME="$PROJECT_NAME" >> $CONFIG_URL
	echo VERSION="$VERSION" >> $CONFIG_URL
	
	confirmGIT
	. $CONFIG_URL
}

reconfigure () {
	if [[ -f $CONFIG_URL ]]; then
		rm $CONFIG_URL
	fi
	
	configure
	printf "DONE | Config created.\n\n"
}

printRed() {
	color="\e[0;31m%-6s\e[m";
	printf $color "$1"
}

printBlue() {
	color="\e[0;34m%-6s\e[m";
	printf $color "$1"
}

runCommand() {
	if [[ $QUIET ]]; then
		echo RUNNING
	else
		echo NOT RUNNING
	fi
}

printLog() {
	if [[ ! -f $LOG_URL ]]; then
		printBlue "WARN | Log not found."
		printf "\n"
		exit 1
	fi
	
	printf "Log '$LOG_URL'\n\n";
	cat $LOG_URL;
	echo ""
	exit 0
}

printConfig() {
	if [[ ! -f $CONFIG_URL ]]; then
		printBlue "WARN | Config not found!"
		printf "\n"
		exit 1
	else
		. $CONFIG_URL
	fi

	if [[ ! $QUIET ]]; then
		echo "DONE | Found configuration ($CONFIG_URL)"

		printf "\n${BRIGHT_BLUE}BUNDLE_ID:${RESET}	$BUNDLE_ID\n"
		printf "${BRIGHT_BLUE}COMPANY_NAME:${RESET}	$COMPANY_NAME\n"
		printf "${BRIGHT_BLUE}PROJECT_NAME:${RESET}	$PROJECT_NAME\n"
		printf "${BRIGHT_BLUE}VERSION:${RESET}	$VERSION\n\n"
	fi
}

checkConfig() {
if [[ ! -f $CONFIG_URL ]]; then
	printf '\007'
	printRed "FAIL | Config not found!"
	printf "\n"
	return 1
else 
	printConfig
fi

if [[ ! $QUIET ]]; then		
	printf "Is this information correct (Y/n)? "
	read -s -n 1 yn
	
	printf "\n"

	if [[ $yn = "" ]]; then
		printf "\n"
		return 0
	else
		case $yn in
			[Yy]*)	;; 
			[Nn]*) 	printf "\nRun 'appledoc-gen -r' to update configuration.\n";
					printf "Goodbye!\n\n";
					exit;
					;;
		        *) 	printf "Invalid Option\n\n"; exit 1;;
		esac
	fi
fi

printf "\n"
}

installAppledoc() {	
	printf "\n"
	
	set -e

	printf "WAIT | Downloading appledoc ($DOWNLOAD_URL)...\n"

	printf "${BRIGHT_BLUE}"
	curl --progress-bar $DOWNLOAD_URL > $TMP_URL
	printf "${RESET}"
	
	if [[ $? -ne 0 || ! -f $TMP_URL ]]; then
		printf '\007'
		printf "\n"
		printRed "FAIL | Download failed. Visit $SITE_URL to download and install manually."
		printf "\n\n"
		exit 1
	fi
	
	printf "\nDONE | Downloaded.\n"
	printf "WAIT | Unzipping appledoc (${TMP_URL//$HOME/~})\n"
	
	unzip -o $TMP_URL -d ~/.tmp >> $LOG_URL 2>&1
	
	if [[ $? -ne 0 ]]; then
		printf '\007'
		printRed "FAIL | Failed to unzip. Visit $SITE_URL to download and install manually."
		printf "\n\n"
		exit 1
	fi
	
	printf "DONE | Unzipped.\n"
	
	cwd=$(pwd)
	cd $TMP_PATH
	
	if [[ $DEBUG = true ]]; then
		printf "WAIT | Compiling appledoc (DEBUG)...\n"
		xcodebuild -target appledoc -configuration Debug install >> $LOG_URL 2>&1
	else
		printf "WAIT | Compiling appledoc...\n"
		xcodebuild -target appledoc -configuration Release install >> $LOG_URL 2>&1
	fi
	
	cd $cwd
	
	if [[ $? -ne 0 ]]; then
		printf '\007'
		printRed "FAIL | Failed to compile. Try 'appledoc-gen -d' to force DEBUG mode."
		printf "\n\n"
		exit 1
	fi
	
	# remove download and its zip
	rm -rf $TMP_URL
	rm -rf $TMP_PATH
	
	printf "DONE | Build succeeded.\n"
	printf "WAIT | Installing appledoc ($APPLEDOC_URL)...\n"
	
	# copy the binary to /usr/local/bin
	cp $BUILD_URL $BIN_URL

	if [[ $? -ne 0 || ! -f $APPLEDOC_URL ]]; then
		printf '\007'
		printRed "FAIL | Failed to install. Visit $SITE_URL to download and install manually."
		printf "\n\n"
		exit 1
	fi
	
	printf "DONE | Successfully installed.\n\n"
}

generateDocumentation() {
	_VERSION=${VERSION//./_}
	_PROJECT_NAME=${PROJECT_NAME// /-}
	
	DOCSET_FILENAME="$BUNDLE_ID.$_PROJECT_NAME-$_VERSION.docset"

	BASE_OPTIONS="appledoc
	--project-name \"$PROJECT_NAME $VERSION\"
	--project-version $VERSION
	--project-company \"$COMPANY_NAME\"
	--company-id \"$BUNDLE_ID\"
	--docset-bundle-id \"$BUNDLE_ID\"
	--docset-bundle-name \"$PROJECT_NAME $VERSION\"
	--verbose 3
	--docset-bundle-filename \"$DOCSET_FILENAME\"
	--keep-intermediate-files
	"
	
	NO_INSTALL_XCODE="
	--no-install-docset
	"

	MERGE_OPTIONS="
	--merge-categories
	--keep-merged-sections
	--prefix-merged-sections
	"
	
	TAIL="
	--output \"$DOCS_URL\" .
	"
	
	COMMAND=$BASE_OPTIONS
	
	if [[ $MERGE ]]; then
		COMMAND="$COMMAND $MERGE_OPTIONS"
	fi
	
	if [[ $NOINSTALL ]]; then
		COMMAND="$COMMAND $NO_INSTALL_XCODE"
	fi
	
	COMMAND="$COMMAND $TAIL"
	
	if [[ $QUIET ]]; then
		COMMAND="$COMMAND >> $LOG_URL 2>&1"
	fi 
	
	if [[ -d $DOCS_URL ]]; then
		printBlue "WARN | Existing intermediate directory, backup now (Y/n)? "
		read -sn 1 yn
		
		case $yn in
			[Nn]*)	printf "\n" 
					printf "DONE | Removed existing directory (./$DOCS_URL)\n"
					;; 
		        *) 	printf "\n";
					mv -v $DOCS_URL $DOCS_URL-bak >> $LOG_URL 2>&1
					printf "DONE | Renamed existing directory (./$DOCS_URL -> ./$DOCS_URL-bak)\n"
					;;
		esac
		
		if [[ ! $QUIET ]]; then
			printf "\n"
		fi
	fi
	
	if [[ $QUIET ]]; then
		printf "WAIT | Generating documentation..."
	fi

	echo $COMMAND >> $LOG_URL 2>&1
	eval $COMMAND
	
	if [[ ! $QUIET ]]; then
		printf "\n"
	fi
		
	if [[ $? -ne 0 ]]; then
		printRed "\nFAIL | Failed to generate documentation."
		printf "\n\n"
		exit $?
	fi
		
	newURL="$DOCS_URL/$DOCSET_FILENAME"
	oldURL="$DOCS_URL/docset"
	mv -v $oldURL $newURL >> $LOG_URL 2>&1
	
	git rev-parse > /dev/null 2>&1
	
	if [[ $? -eq 0 ]]; then	
		status='git ls-files $DOCS_URL --error-unmatch >> $LOG_URL 2>&1'
		eval $status
	
		if [[ $? -ne 0 ]]; then
			printBlue "WARN | Intermediate directory (./$DOCS_URL) not under version control, add it now (Y/n)? "
			read -sn 1 yn
		
			case $yn in
				[Nn]*)	printf "n\n" ;;
			        *) 	printf "y\n";
						git add "./$DOCS_URL/."
					
						status='git ls-files $DOCS_URL --error-unmatch >> $LOG_URL 2>&1'
						eval $status
					
						if [[ $? -ne 0 ]]; then
							printRed "FAIL | Failed to add directory to version control (./$DOCS_URL)\n"
						else
							printf "DONE | Directory is now under version control (./$DOCS_URL)\n"	
						fi
						;;
			esac
		else
			if [[ $QUIET ]]; then
				printf "\n"
			fi
			
			printf "DONE | Directory is under version control (./$DOCS_URL)\n"
		fi
	fi
		
	if [[ $QUIET ]]; then
		printf "DONE | Successfully generated documentation.\n\n"
		echo "" >> $LOG_URL
		exit 0
	fi
	
	if [[ ! -d "$DOCS_URL/$DOCSET_FILENAME" ]]; then
		printf '\007'
		printf "\n"
		printRed "FAIL | Intermediate files cannot be found."
		printf "\n"
	else
		printf "DONE | Intermediate files were installed to './$DOCS_URL'\n"
	fi
	
	install="$DOCSET_URL/$DOCSET_FILENAME"
	
	cwd=$(pwd)
	cd "$DOCSET_URL"
	
	if [[ ! -d $DOCSET_FILENAME ]]; then
		if [[ $NOINSTALL ]]; then
			printBlue "WARN | Documentation was NOT installed to Xcode."
		else
			printf '\007'
			printRed "FAIL | Documentation was NOT installed to Xcode."
		fi
		
		printf "\n\n"
		exit 1
	else
		printf "DONE | Documentation was successfully installed '$DOCSET_FILENAME'\n       (${DOCSET_URL//$HOME/~})\n\n"
	fi
	
	cd $cwd
}



# Script starts from here
# ----------------------------------------




while getopts 'lquhrdmxpv' option; do
	case "$option" in
		h)	printHelp
			exit 0
			;;
		r)	reconfigure;
			exit 0 ;;
		p)	printConfig
			exit 0
			;;
		v)	printf "Version $SCRIPT_VERSION\n";
			exit 0
			;;
		l)	printLog ;;
		m)	MERGE=true ;;
		x)	NOINSTALL=true ;;
		u)	UPDATE=true ;;
		d)	DEBUG=true ;;
		q)	QUIET=true ;;
		?)	echo "Use '$SCRIPT_FILENAME -h' to see more options."
			exit 1; 
			;;
	esac
done

if [[ $UPDATE ]]; then
	installAppledoc
	exit 0
fi

printf "Running $SCRIPT_FILENAME v$SCRIPT_VERSION\n\n"

# remove existing log
if [[ -f $LOG_URL ]]; then
	rm $LOG_URL
fi

# check for appledoc installation
if [[ ! -f $APPLEDOC_URL ]]; then
	printf "Appledoc is not currently installed. Install now (Y/n)? "
	prompt
	installAppledoc
else
	if [[ ! $QUIET ]]; then
		printf "DONE | Found appledoc installation. ($APPLEDOC_URL)\n"
	fi
fi

# Look for Xcode projects
findProjects

# Load config
if [[ -f $CONFIG_URL ]]; then
	. $CONFIG_URL
	if [[ $GIT_CONFIRMED = false ]]; then
		confirmGIT
	fi
	checkConfig
else
	printBlue "WARN | Config not found ($CONFIG_URL)"
	printf "\n\n"
	configure
fi

# Generate documentation using appledoc
generateDocumentation
