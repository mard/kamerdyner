# include .env as in normal programming langages
while IFS=$'\n\r' read line; do #IFS used to trim out CR or LF from the end of .env
        export $line;
done < .env

function post_to_slack {
    escapedText=$(echo $1 | sed 's/"/\"/g' | sed "s/'/\'/g" )
    json="{\"text\": \"$escapedText\", \"username\": \"von Nogay\"}"
    curl -s -d "payload=$json" "$HACKATON_SLACK_WEBHOOK_URL"
}

# random number range 0-9
random=`grep -m1 -ao '[0-9]' /dev/urandom | sed s/0/10/ | head -n1`
if (( random > 6 )); then
   post_to_slack "#ciekaweczyzdazy"
fi
