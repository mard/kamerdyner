#!/bin/bash
# Picks a random slogan defined in /media/pen/kamerdyner/standup_slogans.txt file and sends to DDI hackaton channel
# to announce standup time
#
# Requirements:
# 1. File with slogans one slogan per line starting with #
#    expected in: /media/pen/kamerdyner/standup_slogans.txt
# 2. '.env' file with HACKATON_SLACK_WEBHOOK_URL variable set
#     or just HACKATON_SLACK_WEBHOOK_URL variable in the scope of the script

standup_slogans_filename=/media/pen/kamerdyner/standup_slogans.txt

while read line; do export $line ; done < ./.env

cat "$standup_slogans_filename" | grep . | sort -R | tail -1 | while read slogan; do
	escapedText=$(echo $slogan | sed 's/"/\"/g' | sed "s/'/\'/g" )
	json="{\"text\": \"$escapedText\", \"username\": \"von Nogay\"}"

	curl -s -d "payload=$json" "$HACKATON_SLACK_WEBHOOK_URL"
done
