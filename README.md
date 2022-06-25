
<div align="center">
  


  [![forthebadge](https://forthebadge.com/images/badges/0-percent-optimized.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/does-not-contain-treenuts.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/compatibility-club-penguin.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/built-with-swag.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/mom-made-pizza-rolls.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/designed-in-ms-paint.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/you-didnt-ask-for-this.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/it-works-why.svg)](https://forthebadge.com)
  [![forthebadge](https://forthebadge.com/images/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)
  [![shield](https://img.shields.io/badge/sex-is%20cool-white?style=for-the-badge)](https://shields.io)
  [![shield](https://img.shields.io/badge/do%20not-sue%20me-red?style=for-the-badge)](https://shields.io)
  [![shield](https://img.shields.io/badge/hscript-sucks%20ass-yellowgreen?style=for-the-badge)](https://shields.io)
  ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/ThePlank/PlankEngine/Build?label=stolen%20cli&logo=github&style=for-the-badge)
  ![GitHub repo file count](https://img.shields.io/github/directory-file-count/ThePlank/PlankEngine?label=the%20ammount%20of%20spaghetti&style=for-the-badge)
  ![GitHub forks](https://img.shields.io/github/forks/ThePlank/PlankEngine?label=table%20forks&logo=github&style=for-the-badge)
  ![GitHub](https://img.shields.io/github/license/ThePlank/PlankEngine?style=for-the-badge)
  ![GitHub issues](https://img.shields.io/github/issues/ThePlank/PlankEngine?logo=github&style=for-the-badge)
  [![Twitter](https://img.shields.io/twitter/url?label=talk%20crap%20about%20the%20engine&logoColor=purple&style=social&url=https%3A%2F%2Fgithub.com%2FThePlank%2FPlankEngine)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2FThePlank%2FPlankEngine)



![Logo](assets/preload/images/plankEngineLogo.png "Title")
  
Brings numerous quality of life and features together
# Friday Night Funkin'
This is the repository for Friday Night Funkin, a game originally made for Ludum Dare 47 "Stuck In a Loop".

Play the Ludum Dare prototype here: https://ninja-muffin24.itch.io/friday-night-funkin

Play the Newgrounds one here: https://www.newgrounds.com/portal/view/770371

Support the project on the itch.io page: https://ninja-muffin24.itch.io/funkin

> If you make a mod and distribute a modified / recomipled version, you must open source your mod as well.
# Plank Engine
Plank Engine is a modification of Friday Night Funkin' Kade Engine that provides quality of life inprovements.

This game was made with love to Newgrounds and it's community. Extra love to Tom Fulp.

## Build instructions

These instructions are for compiling the game's source code!

If you want to just download and install and play the game normally, go to github to download the game for PC!

https://github.com/ThePlank/PlankEngine/releases

If you want to compile the game yourself, continue reading!

### Installing the Required Programs

</div>

First you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple). 
1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (Download 4.1.5 instead of 4.2.0 because 4.2.0 is broken and is not working with gits properly...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need is the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:


```
flixel
flixel-addons
flixel-ui
lime
openfl
hscript
```

<div align="center">

So for each of those type `haxelib install [library]` so shit like `haxelib install hscript`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.
5. Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

You should have everything ready for compiling the game! Follow the guide below to continue!


and you should be good to go there.

### Compiling game

Once you have all those installed, it's pretty easy to compile the game. You just need to run 'lime test html5 -debug' in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))

To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run 'lime test linux -debug' and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:

* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows 10 SDK (Any version)


This will install about 3GB of libraries, but once that is done you can open up a command line in the project's directory and run `lime test windows`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, `lime test mac` should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

# Credits

## Friday Night Funkin'
[ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer

[PhantomArcade3K](https://twitter.com/phantomarcade3k) and 

[Evilsk8r](https://twitter.com/evilsk8r) - Art

[Kawaisprite](https://twitter.com/kawaisprite) - Musician
## Plank Engine
[ThePlank (me!)](https://github.com/ThePlank) - Owner And Main Coder

[SnakDev](https://github.com/SnakDev) - Co-Owner and stupid detail adder
## Special Thanks
[KadeDev](https://github.com/KadeDev) - Kade Engine

[Verwex](https://github.com/Verwex) - Memory counter

### Additional guides

[Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)


</div>
