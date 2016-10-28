# Description:

#Mplayer = require('node-mplayer')
sys = require('sys')
exec = require('child_process').exec

formatTime = (h, m, s) ->
  return "#{("00"+h).slice(-2)}:#{("00"+m).slice(-2)}:#{("00"+s).slice(-2)}"

module.exports = (robot) ->
  robot.hear /#(\w+)/, (msg) ->
    url = robot.brain.get "Franz.tags.#{msg.match[1].toString().toLowerCase()}"
    if url.length > 0
      msg.send url
  robot.hear /^Franz remember (https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)) as (\w+)( between (([0-5]?\d):([0-5]\d)) and (([0-5]?\d):([0-5]\d)))?/, (msg) ->
    # group 1 - url
    # group 4 - tag
    # group 6 - start
    # group 9 - end
    start = 60*msg.match[7]+1*msg.match[8]
    end = 60*msg.match[10]+1*msg.match[11]
    msg.reply formatTime(0,msg.match[7],msg.match[8])
    if start >= end
      msg.reply "Die zeit ist Scheiße!"
      return
    if robot.brain.get("Franz.tags.#{msg.match[4].toString().toLowerCase()}")
      msg.reply "Do diaska, das hasztagen już istnieje!"
    else
      robot.brain.set "Franz.tags.#{msg.match[4].toString().toLowerCase()}", msg.match[1].toString()
      msg.reply "Sehr gut her obersturmbannfuhrer!"
  robot.hear /^Franz forget (\w+)/, (msg) ->
    if robot.brain.get("Franz.tags.#{msg.match[1].toString().toLowerCase()}")
      robot.brain.remove "Franz.tags.#{msg.match[1].toString().toLowerCase()}"
      msg.reply "Sehr gut her oberleutnant!"
    else
      msg.reply "Das NullHasztagenException"
  robot.hear /^Franz check (\w+)/, (msg) ->
    url = robot.brain.get("Franz.tags.#{msg.match[1].toString().toLowerCase()}")
    if url
      msg.reply url
    else
      msg.reply "Das Hasztagen Ich weiss nicht"
  robot.hear /(.*)/, (msg) ->
    if msg.message.room.toLowerCase() in ['kamerdyner'] && msg.message.user.name.toLowerCase() not in ['slackbot']
      child = exec "mplayer -really-quiet -user-agent \"Mozilla\" \"http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=1&textlen=64&client=tw-ob&q=#{msg.message.toString()}&tl=Pl-pl\"", (error, stdout, stderr) ->
        msg.send stdout
