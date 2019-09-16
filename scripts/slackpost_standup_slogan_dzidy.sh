#!/bin/bash
# Picks a random slogan defined in /media/pen/kamerdyner/standup_slogans.txt file and sends to DDI hackaton channel
# to announce standup time

webhook_url=https://hooks.slack.com/services/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

cat /media/pen/kamerdyner/standup_slogans_dzidy.txt | grep . | sort -R | tail -1 | while read slogan; do
	echo $slogan
	escapedText=$(echo $slogan | sed 's/"/\"/g' | sed "s/'/\'/g" )
	json="{\"text\": \"$escapedText\", \"username\": \"von Nogay\"}"
	
	curl -X POST -H 'Content-type: application/json' --data ''"$json"'' "$webhook_url"
done
