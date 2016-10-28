#!/bin/bash
#Directory where downloaded mp3 files are stored - kamerdyner's library
defaultLibraryDir='/media/pen/kamerdyner'
#Temp dir where downloading and encoding happens
tmpDir='/media/pen/kamerdyner/tmp'
#Log file:
logFile="$tmpDir/YTlog.txt"

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
	if [ ! -d "$tmpDir" ]; then
		mkdir -p "$tmpDir"
	fi

    # usage: downloadYoutube "url" "tag"
    outputTemplate="%(title)s.%(ext)s"
    #checkIfPackageInstalled "youtube-dl" ## &>> $logFile
    parameters="--extract-audio --audio-format mp3"

    outputFileName=`youtube-dl --get-filename $parameters -o "$outputTemplate" "$1"`
    outputName=`echo "$outputFileName" | cut -d'.' -f1`
    firstOutputFileName="$outputName.mp3"
    realOutputFileName="$2.mp3"

    printf "\noutputFileName:$outputFileName\noutputName:$outputName\nfirstOutputFileName:$firstOutputFileName\nrealOutputFileName:$realOutputFileName\n\n" &>> $logFile

    pushd $tmpDir &>> $logFile
      youtube-dl $parameters -o "$outputTemplate" "$1"  &>> $logFile
      mv "$firstOutputFileName" "$realOutputFileName"  &>> $logFile
    popd &>> $logFile

    echo "$realOutputFileName"
}

function cutMP3 {
	if [ -f "$tmpDir/ffmpeg.mp3" ]; then
		rm "$tmpDir/ffmpeg.mp3"
 	fi
 	mv "$tmpDir/$1" "$tmpDir/ffmpeg.mp3"
 	ffmpeg -y -i "$tmpDir/ffmpeg.mp3" -ss $2 -to $3 -c copy "$defaultLibraryDir/$1" &>> $logFile
 	if [ -f "$tmpDir/ffmpeg.mp3" ]; then
 		rm "$tmpDir/ffmpeg.mp3"
 	fi
}

# For testing purposes
#m=$(downloadYoutube "https://www.youtube.com/watch?v=QuwvJw1mrWY" "BedzieDzialacNIE")
#echo "You should have file saved as \"$m\""
#cutMP3 "$defaultLibraryDir/$m" "00:00:01" "00:00:04" "$defaultLibraryDir/outputTAK.mp3"

# Sample usage:
# ./download-and-cut.sh "https://www.youtube.com/watch?v=QuwvJw1mrWY" "BedzieDzialacNIE" "00:00:01" "00:00:04"
# or
# ./download-and-cut.sh "https://www.youtube.com/watch?v=QuwvJw1mrWY" "BedzieDzialacNIE"

if [ "$#" -lt 2 ] || [ "$#" -eq 3 ] || [ "$#" -gt 4 ]; then
    echo "You should provide 2 or 4 parameters"
else
  # Cleaning log file
  echo "" &> $logFile
	fileName=`downloadYoutube "$1" "$2"`
	if [ "$#" -eq 4 ]; then
		cutMP3 "$fileName" "$3" "$4"
	else
		mv "$tmpDir/$fileName" "$defaultLibraryDir/$fileName"
	fi
fi
