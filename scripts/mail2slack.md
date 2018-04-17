# Mail2Slack

Simple script to monitor mailbox for annoucments with food deliviery arrivals to our office.
Picked message is forwarded to slack so Kamerdyner can say it loud to the team.

# Dependencies

- python 2.7

and some more modules:
```
pip install requests
pip install email
pip install python-dotenv
```

### Startup depedancy

- npm - for installation of pm2 only
- pm2 - process manager for node which is capable of running various scripts

```
npm i pm2 -g
```

# Configuration

The below environmental vars are used for setting up mail account details and slack webhook urls.

It can be read from `.env` file with `dotenv-python`. 

See example in `.env.example`

```
IMAP_USER=kamerdynerddi
IMAP_PASSWORD=******
IMAP_SERVER=smtp.gmail.com
HACKATON_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T02C7L9QD/B02CB0EG1/key1
PAPUGA_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T02C7L9QD/B8B8VTQ2D/key2
```

# Startup

By default it starts up with `pm2` via `/etc/rc.local`

```
pm2 start /home/pi/hubot/scripts/mail2slack.py --name "Mail2Slack"
```
