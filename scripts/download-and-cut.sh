#!/bin/bash
# Script used to download audio from Youtube video and extract specified part of it
# Depends on all possible codecs that Youtube video files depend on including
# Prerequisites:
# sudo apt-get install libav-tools libavcodec-extra youtube-dl ffmpeg

# Sample usage:
# ./download-and-cut.sh "https://www.youtube.com/watch?v=QuwvJw1mrWY" "BedzieDzialacNIE" "00:00:01" "00:00:04"
# or
# ./download-and-cut.sh "https://www.youtube.com/watch?v=QuwvJw1mrWY" "BedzieDzialacNIE"

#Exit the script on firs error
set -e

#Directory where downloaded mp3 files are stored - kamerdyner's library
defaultLibraryDir='/media/pen/kamerdyner'
#Temp dir where downloading and encoding happens
tmpDir='/tmp/kamerdyner'
#Log file:
logFile="$tmpDir/YTlog.txt"

if [ ! -d "$defaultLibraryDir" ]; then
  mkdir -p $defaultLibraryDir
fi

if [ ! -d "$tmpDir" ]; then
  mkdir -p $tmpDir
fi

if [ -f "$logFile" ]; then
  rm $logFile
fi



# Additional functions for downloading and saving files from Youtube
function checkIfPackageInstalled {
  # usage: checkIfPackageInstalled PackageName
  if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Package $1 missing. I will try to install it."
    sudo apt-get install $1 --assume-yes
  else
    echo "Package $1 already installed."
  fi
}

function downloadYoutube {
  nameToLog "downloadYoutube"

  # usage: downloadYoutube "url" "tag"
  outputTemplate="%(id)s.%(ext)s"
  #checkIfPackageInstalled "youtube-dl" ## &>> $logFile
  parameters="--format bestaudio/best --extract-audio --audio-format mp3"

  outputFileName=`youtube-dl --get-filename $parameters -o "$outputTemplate" "$1"`
  outputName=`echo "$outputFileName" | cut -d'.' -f1`
  firstOutputFileName="$outputName.mp3"
  realOutputFileName="$2.mp3"

  pushd $tmpDir >> $logFile 2>&1
    youtube-dl $parameters -o "$outputTemplate" "$1" >> $logFile 2>&1
    if [ $? -gt 0 ]; then
        cat $logFile >&2
        exit 1
    fi
    mv "$firstOutputFileName" "$realOutputFileName"  >> $logFile 2>&1
  popd >> $logFile 2>&1

  echo "$realOutputFileName"
}

function cutMP3 {
  nameToLog "cutMP3"
	if [ -f "$tmpDir/ffmpeg.mp3" ]; then
		rm "$tmpDir/ffmpeg.mp3"
 	fi
 	mv "$tmpDir/$1" "$tmpDir/ffmpeg.mp3"
 	ffmpeg -y -i "$tmpDir/ffmpeg.mp3" -ss $2 -to $3 -c copy "$defaultLibraryDir/$1" >> $logFile 2>&1
 	if [ -f "$tmpDir/ffmpeg.mp3" ]; then
 		rm "$tmpDir/ffmpeg.mp3"
 	fi
}

function sepToLog {
  printf "\n==================\n" &>> $logFile
}

function messageToLog {
  sepToLog
  printf "$1" &>> $logFile
  sepToLog
}

function nameToLog {
  messageToLog "Running $1"
}

function timeToLog {
  now=$(date +"%T")
  messageToLog $now
}

# Cleaning log file
echo "" &> $logFile
timeToLog
echo "Arguments provided $@" &>> $logFile

if [ "$#" -lt 2 ] || [ "$#" -eq 3 ] || [ "$#" -gt 4 ]; then
  echo "You should provide 2 or 4 parameters"
  echo "You should provide 2 or 4 parameters" >> $logFile
else
  fileName=`downloadYoutube "$1" "$2"`
  if [ "$#" -eq 4 ]; then
    cutMP3 "$fileName" "$3" "$4"
  else
    echo mv "$tmpDir/$fileName" "$defaultLibraryDir/$fileName" >> $logFile 2>&1
    mv "$tmpDir/$fileName" "$defaultLibraryDir/$fileName"
  fi
  timeToLog
fi
