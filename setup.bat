@echo off
cls
color 5

:haxePrompt
set /P c=Do you have Haxe installed? [Y/N]
if /I "%c%" EQU "Y" goto :install
if /I "%c%" EQU "N" goto :linkToHaxe
goto :haxePrompt

:linkToHaxe
start https://haxe.org/
pause
exit
pause
color 7

:install
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib install actuate
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc 
pause
exit
pause
color 7