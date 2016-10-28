# Description:

#Mplayer = require('node-mplayer')
sys = require('sys')
exec = require('child_process').exec


hellos = [
    "Well hello there, %",
    "Hey %, Hello!",
    "Marnin', %",
    "Good day, %",
    "Good 'aye!, %"
]
mornings = [
    "Good morning, %",
    "Good morning to you too, %",
    "Good day, %",
    "Good 'aye!, %"
]
module.exports = (robot) ->
    robot.hear /(.*)/, (msg) ->
      mesedz = "#{msg.message.toString()}"
      #mesedz = "Imć #{msg.message.user.name} zapowiada. #{msg.message.toString()}"
      child = exec "mplayer -really-quiet -user-agent \"Mozilla\" \"http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=1&textlen=64&client=tw-ob&q=#{mesedz}&tl=Pl-pl\"", (error, stdout, stderr) ->
        msg.send stdout
      if mesedz in ["us", "US", "U.S.", "u.s."]
        child = exec "mplayer -really-quiet -endpos 21 /home/pi/hubot/usanthem.mp3", (error, stdout, stderr) ->
          msg.send stdout
      if mesedz in ["kaiser"]
        child = exec "mplayer -really-quiet -endpos 27 /home/pi/hubot/kaiser.mp3", (error, stdout, stderr) ->
          msg.send stdout

        #player1 = new Mplayer("http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=1&textlen=64&client=tw-ob&q=Dupa&tl=Pl-pl")
        #player1.play()
        #hello = msg.random hellos
        #msg.send hello.replace "%", msg.message.user.name
