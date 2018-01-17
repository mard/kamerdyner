#!/bin/bash
# hubot_forever.sh start | stop | restart

#2017-03-07 MP Change default Hubot port from 8080 to 8081 - due to Squid
export EXPRESS_PORT=8081

## Configuration

BASEDIR=$(cd "$(dirname "$0")/.."; pwd)
NODE_MODULES=$BASEDIR/node_modules
LOG=$BASEDIR/log/hubot.log
PID=$BASEDIR/tmp/pids/hubot.pid
source $BASEDIR/config/hubot.cfg

## Ensure
mkdir -p $(dirname "${LOG}")
mkdir -p $(dirname "${PID}")
cd $BASEDIR

## Forever Commands

function start {
  forever start \
    -p $BASEDIR \
    --minUptime 10 \
    --spinSleepTime 100 \
    --pidFile $PID \
    --append \
    -l $LOG \
    -c node_modules/coffee-script/bin/coffee node_modules/.bin/hubot \
    --adapter slack

  # Start log monitoring
  #pkill --full hubot_log_monitoring.sh
  #nohup $BASEDIR/bin/hubot_log_monitoring.sh $LOG &>/dev/null &
}

function stop {
  # Kill current instance of hubot
  if [ -f $PID ];then
    #$NODE_MODULES/forever/bin/forever stop `cat $PID`
    forever stop `cat $PID`
  fi
}

case $1 in
  start) start;;
  stop) stop;;
  restart) stop;start;;
  --) break;;
esac
