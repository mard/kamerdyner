#!/bin/sh
HUBOT_LOG_LEVEL=debug coffee --nodejs --debug node_modules/.bin/hubot --adapter shell --name "[dbg]kamerdyner" "$@"