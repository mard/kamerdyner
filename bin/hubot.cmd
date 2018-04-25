@echo off

rem call npm install
SETLOCAL
SET PATH=node_modules\.bin;node_modules\hubot\node_modules\.bin;%PATH%

SET HUBOT_LOG_LEVEL=debug

node_modules\.bin\hubot.cmd --name "kamerdyner" %* 
