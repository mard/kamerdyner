# Advanced Debugging With Node Inspector

[Source link](https://leanpub.com/automation-and-monitoring-with-hubot/read#leanpub-auto-debugging-your-scripts)


Sometimes it’s not enough just to print out the errors. For those occasions you may need heavy artillery - a full fledged debugger. Luckily, there is node-inspector. You will be especially happy with it if you are familiar with Chrome’s web inspector. To use node-inspector, first install the npm package. You should do it once, using -g switch to install it globally. Install as root.

Pleas note that `node-inspector` is compatible with node v6

```
root@botserv:~# npm install -g node-inspector
```

To start the debugger, run node-inspector either in the background (followed by &) or in a new shell. In following example it’s started without preloading all scripts (otherwise it’s a long wait), and inspector console running on port 8123, because both hubot and node-inspector use port 8080 by default. We could set PORT=8123 for hubot instead, but setting it for node-inspector is more convenient.

```
hubot@focus:~/campfire$ node-inspector --no-preload --web-port 8123
Node Inspector v0.7.0-1
   info  - socket.io started
   Visit http://127.0.0.1:8123/debug?port=5858 to start debugging.
```

Now, we will put debugger to add a breakpoint to our weather.coffee script and debugger will stop on that line when it gets executed.

`script/weather.coffee`

```
27       for w in data.weather
28         weather.push w.description
29       debugger
30       msg.reply "It's #{weather.join(', ')} in #{data.name}, #{data.sys.count\
31 ry}"
```

Now we have to start Hubot in a little different way:

```
hubot@focus:~/campfire$ HUBOT_LOG_LEVEL=debug coffee --nodejs --debug node_modules/.bin/hubot
debugger listening on port 5858
```

Then open http://127.0.0.1:8123/debug?port=5858 - the link that node-inspector gave you in it’s output in Chrome, or any other Blink based browser. Expect a little delay, because it will load all the scripts that Hubot normally requires just in time when needed. When you are able to see Sources tree in the top-left corner of your browser (you may need to click on the icon to expand it), get back to Hubot console and ask for the weather:

```
Hubot> what is the weather in Hawaii?
Hubot>
```

Don’t expect a response, because Chrome should now switch to weather.coffee and stop the execution at debugger line. Now you can step over the script line by line, add additional breakpoints by clicking on line nubers in any souce file from the Source tree in the left, or use the interactive console - there is Console tab at the top of the debugger, and a small > icon in bottom-left corner, which I prefer because it doesn’t close the source view.

You can type any JavaScript in the console, and it will execute. Let’s examine our weather array:

```
> weather
  - Array[2]
    0: "74 degrees"
    1: "broken clouds"
    length: 2
```

And the response from the weather API:

```
> data
  - Object
    base: "cmc stations"
    + clouds: Object
    cod: 200
    + coord: Object
    dt: 1389847230
    id: 5856195
    + main: Object
    name: ""
    - sys: Object
      country: "United States of America"
      message: 0.308
      sunrise: 1389892287
      sunset: 1389931892
    - weather: Array[1]
      - 0: Object
        description: "broken clouds"
        icon: "04n"
        id: 803
        main: "Clouds"
      length: 1
    + wind: Object
```

You can expand any part of the object tree to see what’s in it. You can also call functions:

```
> msg.send("Hello from node-inspector")
```

And in Hubot shell you should see:

```
Hubot> Hello from node-inspector
```

You can debug your web applications or any other JavaScript or CoffeeScript code using this technique. It’s even easier for web applications - just open Chrome Inspector and you’re set.