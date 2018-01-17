#!/bin/bash
# Sends message to DDI's hackaton channel
# Usage: slackpost "<message>"
#
# Requirements
# 1. '.env' file with HACKATON_SLACK_WEBHOOK_URL variable set
#     or just HACKATON_SLACK_WEBHOOK_URL variable in the scope of the script

while read line; do export $line ; done < ./.env

text=$1

if [[ $text == "" ]]
then
        echo "No text specified"
        exit 1
fi

escapedText=$(echo $text | sed 's/"/\"/g' | sed "s/'/\'/g" )
json="{\"text\": \"$escapedText\", \"username\": \"von Nogay\"}"

curl -s -d "payload=$json" "$HACKATON_SLACK_WEBHOOK_URL"
