#!/bin/bash
# Additional functions for downloading and saving files from Youtube
function checkIfPackageInstalled {
  # usage: checkIfPackageInstalled PackageName
  if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Package $1 missing. I will try to install it."
    sudo apt-get install $1;
  else
    echo "Package $1 already installed."
  fi
}

function downloadYoutube {
    # usage: downloadYoutube "url" "folder"
    outputTemplate="%(title)s.%(ext)s"
    checkIfPackageInstalled "youtube-dl" >> /dev/null
    parameters="--extract-audio --audio-format mp3"

    outputFileName=`youtube-dl --get-filename $parameters -o "$outputTemplate" "$1"`
    outputName=`echo "$outputFileName" | cut -d'.' -f1`
    realOutputFileName="$outputName.mp3"

    pushd $2 >> /dev/null
      youtube-dl $parameters -o "$outputTemplate" "$1" >> /dev/null
    popd >> /dev/null

    echo "$realOutputFileName"
}

# For testing purposes
m=$(downloadYoutube "https://www.youtube.com/watch?v=QuwvJw1mrWY" "/home/ddi")
echo "You should have file saved as \"$m\""
