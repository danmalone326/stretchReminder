#!/bin/bash

# Application Directories
appDirectory="${HOME}/Applications/stretchReminder.app"
contentsDirectory="${appDirectory}/Contents"
macosDirectory="${contentsDirectory}/MacOS"
resourcesDirectory="${contentsDirectory}/Resources"

trashDirectory="${HOME}/.Trash"

function toTrash () {
    source=$1
    sourceBase=$(basename $source)
    sourceName=${sourceBase%.*}
    sourceExtension=${sourceBase##*.}
    sourceDir=$(dirname $source)
    
    target="${trashDirectory}/${sourceBase}"
    
    num=1
    while [ -e "$target" ] 
    do
        (( num++ ))
        target="$trashDirectory/$sourceName$num.$sourceExtension"
    done
    
    echo $sourceBase
    echo $sourceName
    echo $sourceExtension
    echo $sourceDir
    echo $target
    touch $target
}


# Check if the app is already installed
if [ -d $appDirectory ] 
then  # Update
    echo "Directory ${appDirectory} exists." 
    toTrash $appDirectory
else  # New install
    echo "Error: Directory ${appDirectory} does not exists."
fi

