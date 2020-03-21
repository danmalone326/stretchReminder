#!/bin/bash
# Like this: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/danmalone326/stretchReminder/master/install.sh)"

appName="stretchReminder"


# Remote URLs
remoteAppURL="https://raw.githubusercontent.com/danmalone326/stretchReminder/master/${appName}.app"
remoteContentsURL="${remoteAppURL}/Contents"
remoteMacosURL="${remoteContentsURL}/MacOS"
remoteResourcesURL="${remoteContentsURL}/Resources"

# Local Directories
appDirectory="${HOME}/Applications/${appName}.app"
contentsDirectory="${appDirectory}/Contents"
macosDirectory="${contentsDirectory}/MacOS"
resourcesDirectory="${contentsDirectory}/Resources"

trashDirectory="${HOME}/.Trash"
tempDirectory=""

function makeTempDirectory () {
    if [ -z $tempDirectory ] || [ ! -d $tempDirectory ]
    then
        tempDirectory=$(mktemp -d -t "${appName}")
#         echo "Using temp directory ${tempDirectory}"
    fi
}

function cleanUp () {
    if [ ! -z $tempDirectory ]
    then
        rm -rf "${tempDirectory}"
    fi
}

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
    
    mv $source $target
}

function getInstalledVersion () {
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${contentsDirectory}/Info.plist")
    echo $version
}

function getAvailableVersion () {
    makeTempDirectory
    tempPlist="${tempDirectory}/temp.plist"
    
    curl --silent "${remoteContentsURL}/Info.plist" --output "${tempPlist}" 
    
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${tempPlist}")
    rm "${tempPlist}"
    
    echo $version
}


# /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString string 1.0.0" Info.plist
# /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist

echo "${appName}"

# Check if the app is already installed
if [ -d $appDirectory ] 
then  # Update
    installedVersion=$(getInstalledVersion)
    availableVersion=$(getAvailableVersion)
    
    if [ "$installedVersion" == "$availableVersion" ]
    then
        echo "Already running the lastest version: ${installedVersion}"
        exit 0
    fi
    
    echo "Upgrading from version ${installedVersion} to ${availableVersion}" 
    toTrash "${appDirectory}"
else  # New install
    echo "New install of version ${availableVersion}"
fi

mkdir -pv $macosDirectory
mkdir -pv $resourcesDirectory

curl --silent "${remoteContentsURL}/Info.plist" --output "${contentsDirectory}/Info.plist" 
curl --silent "${remoteMacosURL}/${appName}" --output "${macosDirectory}/${appName}" 
curl --silent "${remoteResourcesURL}/${appName}.icns" --output "${resourcesDirectory}/${appName}.icns" 

chmod +x "${macosDirectory}/${appName}" 

cleanUp
