#!/bin/bash
#
# Build and iPhone Simulator Helper Script
# Jayesh Kawli 2015
#
# WARN: - You must provide the Github clone path from where you are downloading iOS project.
# Could be run into any directory - Be warned that this script will create a project folder in the same directory as script.

# Reference - Thanks to https://github.com/phonegap/ios-sim and https://gist.github.com/shazron/1314458/7771616dbc377fef7bb2a4521bcbac460e96adfe for their valuable 
# contribution. Their code allowed me to write this script for easy automation.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

GIT_CLONE_PATH=$1
DEVICETYPE=$2
CONFIGURATION=$3
LOGFILE=$4
current_dir=$(pwd)

path="$GIT_CLONE_PATH"
name=$(basename "$path" ".git")
PROJECTNAME=""

# Used to check is package ios-sim required to run project on the simulator from command line exists. If not, it will download it by user's consent before continuing.
command_exists () {
    type "$1" &> /dev/null ;
}

function help {
  printf "${GREEN}Usage: $0 <GIT clone path> [Device Type] [configuration] [logname]"
  echo
  printf "${GREEN}<GIT Clone path> Full URL of Git clone path"
  echo
  printf "${GREEN}[Device Type] (optional) Device type you want to run project on. If not provided script will default to use 'iPhone-6, 9.2'. To see full list of available devices, please install ios-sim and then type command ios-sim showdevicetypes"
  echo
  printf "${GREEN}[configuration] (optional) Debug or Release, defaults to Debug"
  echo
  printf "${GREEN}[logname] (optional) the log file to write to. defaults to stderror.log${NC}"
  echo
  echo
  echo
}
# Check if user has pre-installed ios-sim. If not, give option if this program can install it.

if ! command_exists ios-sim ; then
    read -p "It looks like plugin ios-sim is not installed. You can installed it directly from \
    https://github.com/phonegap/ios-sim. Do you want automated build program to automatically install it for you? (y/n)" -n 1 -r
  
  if [[ $REPLY =~ ^[Yy]$ ]] ; then
    npm install ios-sim -g
  else 
    printf "${RED}Please install package ios-sim before continuing with automated build program. Once you are done, try running script again.${NC}"
    echo
    exit 1
  fi
fi

# check if user has provided clone path. If clone path is not provided, it is a fatal error. Exit the code immediately.
if [ -z "$GIT_CLONE_PATH" ] ; then
  help
  exit 1
fi

# check second argument, default to "Debug"
if [ -z "$CONFIGURATION" ] ; then
  CONFIGURATION=Debug
fi

if [ -z "$DEVICETYPE" ] ; then
  DEVICETYPE="iPhone-6, 9.2"
fi

# check third argument, default to "stderror.log"
if [ -z "$LOGFILE" ] ; then
  LOGFILE=stderr.log
fi

# backup existing logfile (start fresh each time)
if [ -f $LOGFILE ]; then
  mv $LOGFILE $LOGFILE.bak  
fi

FULL_PATH="$current_dir/$name"

if [ -d "$FULL_PATH" ]; then
  printf "${GREEN}Project Directory with name $name already exists. Moving into existing directory${NC}"
  echo
  cd $name
else 
  git clone "$1"
  cd "$name"
fi

PROJECT_EXTENSION=""
PROJECTNAME=""
DIRECTORY_TO_CHECK=""
OLD_DIRECTORY=""

for file in $(find $current_dir/$name -name '*.xcworkspace' -or -name '*.xcodeproj'); do      
      if [ -d $file ]
      then         
        OLD_DIRECTORY="$DIR"     
        DIR=$(dirname "$file")           

        if [[ $file != *"pods"* ]] && [[ $file != *"Pods"* ]];then
          filename=$(basename "$file")
          PROJECTNAME="${filename%.*}"        
        else           
          continue;
        fi
              
        if [[ $DIR == *"/Pods"* ]] || [[ $DIR == *"/pods"* ]] || [[ $DIR == *"Pods"* ]] || [[ $DIR == *"pods"* ]]; then                    
          DIR="$OLD_DIRECTORY"          
        else          
          break
        fi 
      fi
done;

FOLDER_WITH_PROJECT_DEMO=$(basename $DIR)
PROJECT_FILE_NAME="$filename"
filename=$(basename "$filename")
PROJECT_EXTENSION="${filename##*.}"

if [ ! "$FULL_PATH" = "$DIR" ] ; then
  original_path_length=${#FULL_PATH}
  updated_path_length=${#DIR}  
  FOLDER_WITH_PROJECT_DEMO=${DIR:original_path_length+1:updated_path_length - original_path_length - 1}
  cd "$FOLDER_WITH_PROJECT_DEMO"
fi

if [ -f Podfile ] || [ -f podfile ]
then
  pod install
  PROJECT_EXTENSION="xcworkspace"
else
  printf "${GREEN}No podfile found${NC}"
  echo
  echo
fi

SCHEME_NAME=$PROJECTNAME

FULL_SCHEME_PATH="$DIR/$PROJECTNAME.xcodeproj/xcshareddata/xcschemes"
NUMBER_OF_PROJECT_SCHEMES=$(find $FULL_SCHEME_PATH -name "*.xcscheme" -maxdepth 1 | wc -l)

if [ "$NUMBER_OF_PROJECT_SCHEMES" -lt 1 ]; then
  printf "${RED}No schemes found in the project. Please manually open the xcodeproj -> go to manage schemes and then make sure the scheme is marked as shared ${NC}"
  exit 1;
else
  
  for file in $(find $FULL_SCHEME_PATH -name '*.xcscheme')
  do
    BUILDABLE_NAME=$(xpath $file '/Scheme/BuildAction/BuildActionEntries/BuildActionEntry/BuildableReference/@BuildableName' | awk -F'[="]' '!/>/{print $(NF-1)}')        
    if [[ $BUILDABLE_NAME =~ \.app$ ]] || [[ $BUILDABLE_NAME =~ \.App$ ]]; then
      SCHEME_NAME="${BUILDABLE_NAME%%.*}"       
      break;
    fi    
  done
fi

if [ "$PROJECT_EXTENSION" = "xcodeproj" ]; then 
  xcodebuild -configuration $CONFIGURATION -sdk iphonesimulator -project $PROJECTNAME.xcodeproj -scheme $SCHEME_NAME -derivedDataPath "$current_dir/$name"
else
  xcodebuild -configuration $CONFIGURATION -sdk iphonesimulator -workspace $PROJECTNAME.xcworkspace -scheme $SCHEME_NAME -derivedDataPath "$current_dir/$name"
fi;

ios-sim --devicetypeid "${DEVICETYPE}" launch "$current_dir/$name/Build/Products/$CONFIGURATION-iphonesimulator/$SCHEME_NAME.app"
osascript -e "tell application \"iPhone Simulator\" to activate. If you think this is a device or an iOS version issue, please try padding another device type through command line."
tail -f $LOGFILE

exit
exec bash
