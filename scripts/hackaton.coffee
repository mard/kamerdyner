# Description:

#Mplayer = require('node-mplayer')
util = require('util')
exec = require('child_process').exec
_ = require('underscore')
fs = require('fs')
os = require('os');

formatTime = (h, m, s) ->
  return "#{("00"+h).slice(-2)}:#{("00"+m).slice(-2)}:#{("00"+s).slice(-2)}"

getAddr = ->
  result = null
  ifaces = os.networkInterfaces()
  Object.keys(ifaces).forEach (ifname) ->
    ifaces[ifname].forEach (iface) ->
      if iface.family == 'IPv4' and iface.internal == false
        result = iface.address
  result

messageTagLink = (tag) ->
  attachments = [
    (
      title: "#{tag}.mp3"
      title_link: "http://#{getAddr()}/kamerdyner/#{tag}.mp3"
    )
  ]
  message = ( 
    text: "Bitte ein #{tag}"
    attachments: attachments
    username: "kamerdyner"
    as_user: true
  )
  return message

module.exports = (robot) ->
  no_hasztag_msg = "Das Hasztagen Ich weiss nicht"
  robot.hear /#(\w+)/, (msg) ->
    file_name = robot.brain.get "Franz.tags.#{msg.match[1].toString().toLowerCase()}"
    
    if (file_name != null && file_name != undefined && file_name.length > 0)
      try
        file_exists = fs.statSync file_name
      catch
        return msg.reply "File for tag '#{msg.match[1].toString().toLowerCase()}' does not exist: '#{file_name}'"
      
      exec "mplayer -really-quiet #{file_name}", (error, stdout, stderr) ->
          if (stderr?) && (error?) && (stderr)
            msg.reply "Was für’n Scheiß! #{stderr}"
            return
          return msg.send stdout
    else
      return msg.reply no_hasztag_msg

  robot.error (err, res) ->
    robot.logger.error "#{err}\n#{err.stack}"
    if res?
      res.reply "#{err}\n#{err.stack}"

  robot.hear /^Franz (sing|singen) (\w+)/, (msg) ->
    # group 2 - tag
    tag = "#{msg.match[2].toString().toLowerCase()}"
    if robot.brain.get("Franz.tags.#{tag}")
      msg.send messageTagLink tag
    else
      msg.reply no_hasztag_msg

  robot.hear /^Franz (ip|adres|address|addresses|\?)$/, (msg) ->
    adresses = "Network interfaces:\n"
    ifaces = os.networkInterfaces();
    Object.keys(ifaces).forEach (ifname) ->
      ifaces[ifname].forEach (iface) ->
        if !iface.internal
          adresses += "#{ifname} #{iface.family} - Address: #{iface.address} MAC: #{iface.mac}\n"
    msg.reply adresses

  robot.hear /^Franz (hilfe|help|\?)$/, (msg) ->
    help = "List of all commands:\n" +
     "#tagname - plays file associated with tagname\n" +
     "Franz remember all https://www.youtube.com/watch?v=I583TE-3Grw as franztag - saves whole audio track from the provided youtube video under tag 'franztag'\n" +
     "Franz remember https://www.youtube.com/watch?v=I583TE-3Grw as franztag between 00:10 and 00:15 - saves audio track between 10th and 15th seconds under tag 'franztag'\n" +
     "Franz add franztag - adds tag 'franztag', expecting that the corresponding file alteady exists at the desired path (for adding manually edited files)\n" +
     "Franz forget franztag - removes tag 'franztag'\n" +
     "Franz check franztag - checks if tag 'franztag' exists\n" +
     "Franz list - lists all available tags\n" +
     "Franz sing|singen franztag - responds with a link to mp3 file associated with the tag to listen it via browser (works only if clopduino and client are in the same network)\n" +
     "Franz logs|log - shows log of the last processed tag (for troubleshooting)\n" +
     "Franz ip|adres|address|addresses - shows list of all network intefaces\n" +
     "Franz hilfe|help|? - shows this help\n"
    msg.reply help

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
      cmd = "#{process.cwd()}/scripts/download-and-cut.sh '#{url}' #{tag}"
      exec cmd, (error, stdout, stderr) ->
        if (stderr?) && (error?) && (stderr)
          msg.reply "Was für’n Scheiß! #{stderr}"
          return
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

      cmd = "#{process.cwd()}/scripts/download-and-cut.sh '#{url}' #{tag} #{formatTime(0,msg.match[6], msg.match[7])} #{formatTime(0,msg.match[9], msg.match[10])}"
      exec cmd, (error, stdout, stderr) ->
        if (stderr?) && (error?) && (stderr)
          msg.reply "Was für’n Scheiß! #{stderr}"
          return
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
      msg.reply no_hasztag_msg

  robot.hear /^Franz log[s]?$/, (msg) ->
    logFile = "/media/pen/kamerdyner/tmp/YTlog.txt"
    fs.readFile logFile, (err, data) ->
      if err
        msg.reply "Couldn't reach to file #{logFile} ERROR: #{err}"
        return
      msg.reply data

  robot.hear /^Franz list$/, (msg) ->
    tag_string = "Franz.tags."
    brain_data = robot.brain.data._private
    if (Object.keys(brain_data).length == 0)
      msg.reply "Scheiße! Ih habe keine data."
    else
      tags = []
      _.filter brain_data, (item, key) ->
        if key.toString().startsWith(tag_string)
          match_key = key.toString().replace(tag_string, "")
          try
            if fs.statSync item
              tags.push match_key
            return
          catch
            tags.push "!#{match_key}"
            return

      return msg.reply "#{tags.join(", ")}\nTags starting with '!' have no corresponding files on disk"

  robot.hear /(.*)/, (msg) ->
    papugaRoomId = 'C2VHW8PNE'
    if msg.message.room.toUpperCase() in [papugaRoomId] && msg.message.user.name.toString().toLowerCase() not in ['slackbot']
      child = exec "mplayer -speed 1.3 -really-quiet -user-agent \"Mozilla\" \"http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=1&textlen=64&client=tw-ob&q=#{msg.message.toString()}&tl=Pl-pl\"", (error, stdout, stderr) ->
        msg.send stdout
