# Description:

#Mplayer = require('node-mplayer')
sys = require('sys')
exec = require('child_process').exec

formatTime = (h, m, s) ->
  return "#{("00"+h).slice(-2)}:#{("00"+m).slice(-2)}:#{("00"+s).slice(-2)}"

module.exports = (robot) ->
  robot.hear /#(\w+)/, (msg) ->
    file_name = robot.brain.get "Franz.tags.#{msg.match[1].toString().toLowerCase()}"
    if file_name.length > 0
      exec "mplayer -really-quiet #{file_name}", (error, stdout, stderr) ->
          msg.send stdout

  robot.hear /^Franz remember all (https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)) as (\w+)/, (msg) ->
    # group 1 - url
    # group 4 - tag
    if robot.brain.get("Franz.tags.#{msg.match[4].toString().toLowerCase()}")
      msg.reply "Do diaska, das hasztagen już istnieje!"
    else
      tag = msg.match[4].toString().toLowerCase()
      url = msg.match[1].toString()
      file_name = "/media/pen/kamerdyner/#{tag}.mp3"
      msg.reply "Ich arbeite..."
      cmd = "/home/pi/hubot/scripts/download-and-cut.sh '#{url}' #{tag}"
      exec cmd, (error, stdout, stderr) ->
        robot.brain.set "Franz.tags.#{tag}", file_name
        msg.reply "Sehr gut her general! #{tag}"

  robot.hear /^Franz add (\w+)/, (msg) ->
    # group 1 - tag
    if robot.brain.get("Franz.tags.#{msg.match[1].toString().toLowerCase()}")
      msg.reply "Do diaska, das hasztagen już istnieje!"
    else
      tag = msg.match[1].toString().toLowerCase()
      file_name = "/media/pen/kamerdyner/#{tag}.mp3"
      robot.brain.set "Franz.tags.#{tag}", file_name
      msg.reply "Sehr gut her obersturmbannfuhrer! #{tag}"

  robot.hear /^Franz remember (https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/=]*)) as (\w+) between (([0-5]?\d):([0-5]\d)) and (([0-5]?\d):([0-5]\d))/, (msg) ->
    # group 1 - url
    # group 4 - tag
    # group 5 - start
    # group 8 - end
    start = 60*msg.match[6]+1*msg.match[7]
    end = 60*msg.match[9]+1*msg.match[10]
    if start >= end
      msg.reply "Die zeit ist Scheiße!"
      return
    if robot.brain.get("Franz.tags.#{msg.match[4].toString().toLowerCase()}")
      msg.reply "Do diaska, das hasztagen już istnieje!"
    else
      tag = msg.match[4].toString().toLowerCase()
      url = msg.match[1].toString()
      file_name = "/media/pen/kamerdyner/#{tag}.mp3"
      msg.reply "Ich arbeite..."
      cmd = "/home/pi/hubot/scripts/download-and-cut.sh '#{url}' #{tag} #{formatTime(0,msg.match[6], msg.match[7])} #{formatTime(0,msg.match[9], msg.match[10])}"
      exec cmd, (error, stdout, stderr) ->
          robot.brain.set "Franz.tags.#{tag}", file_name
          msg.reply "Sehr gut her obersturmbannfuhrer! #{tag}"

  robot.hear /^Franz forget (\w+)/, (msg) ->
    file_name = robot.brain.get("Franz.tags.#{msg.match[1].toString().toLowerCase()}")
    if file_name
      exec "rm #{file_name}"
      robot.brain.remove "Franz.tags.#{msg.match[1].toString().toLowerCase()}"

      msg.reply "Sehr gut her oberleutnant!"
    else
      msg.reply "Das NullHasztagenException"

  robot.hear /^Franz check (\w+)/, (msg) ->
    file_name = robot.brain.get("Franz.tags.#{msg.match[1].toString().toLowerCase()}")
    if file_name
      msg.reply file_name
    else
      msg.reply "Das Hasztagen Ich weiss nicht"

  robot.hear /(.*)/, (msg) ->
    papugaRoomId = 'C2VHW8PNE'
    if msg.message.room.toUpperCase() in [papugaRoomId] && msg.message.user.name.toString().toLowerCase() not in ['slackbot']
      child = exec "mplayer -really-quiet -user-agent \"Mozilla\" \"http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=1&textlen=64&client=tw-ob&q=#{msg.message.toString()}&tl=Pl-pl\"", (error, stdout, stderr) ->
        msg.send stdout
