package;

import states.PlankSplash;
import util.Console;
import flixel.util.FlxTimer;
// import crashdumper.CrashDumper;
// import crashdumper.SessionData;
import lime.utils.LogLevel;
import haxe.CallStack;
import haxe.CallStack.StackItem;
import openfl.events.UncaughtErrorEvent;
import haxe.PosInfos;
import haxe.Log;
import classes.PlayerSettings;
import sys.FileSystem;
import util.ZipTools;
import util.CoolUtil;
import openfl.system.System;
import display.objects.PlankFPS;
import flixel.FlxG;
import classes.Highscore;
import classes.Options;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import states.TitleState;
#if hl
import hl.UI;
#end

using StringTools;

class Main extends Sprite
{

	// maybe add a .json file for this?///?//
	public static var settings = {
		gameWidth: 1280, // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		gameHeight: 720, // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		initialState: PlankSplash, // The FlxState the game starts with.
		zoom: -1.0, // If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, // How many frames per second the game should run at.
		skipSplash: true, // Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false, // Whether to start the game in fullscreen on desktop targets
	}


	// public final CRASH_SESSION_ID:String = SessionData.generateID("PlankEngine_");

	private static var current:Main;
	// var dumper:CrashDumper;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		current = new Main();
		Lib.current.addChild(current);
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		#if (hl && !HL_CONSOLE)
		UI.closeConsole(); // AAAAAAAASDFDADHAJDAKSAD THIS TOOK ME SO LONG TO FIGURE OUT
		#end

		Options.init();
		Highscore.load();
		Console.init();

		// dumper = new CrashDumper(CRASH_SESSION_ID #if flash , stage #end);

		setupGame();
	}

	static var consoleClasses:Array<Class<Dynamic>> = [Options, System, Lib, Main, CoolUtil, ZipTools];

	function registerClasses()
	{
		for (unregisteredClass in consoleClasses)
			FlxG.console.registerClass(unregisteredClass);
	}



	function onError(error:UncaughtErrorEvent)
	{
	}



	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (settings.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / settings.gameWidth;
			var ratioY:Float = stageHeight / settings.gameHeight;
			settings.zoom = Math.min(ratioX, ratioY);
			settings.gameWidth = Math.ceil(stageWidth / settings.zoom);
			settings.gameHeight = Math.ceil(stageHeight / settings.zoom);
		}

		#if !debug
		// settings.initialState = TitleState;
		#end

		addChild(new FlxGame(settings.gameWidth, settings.gameHeight, settings.initialState, #if (flixel < "5.0.0") settings.zoom, #end settings.framerate, settings.framerate, settings.skipSplash, settings.startFullscreen));
		registerClasses();
		PlayerSettings.init();

		#if !mobile
		addChild(new PlankFPS(10, 3));
		#end
	}

	public static function get():Main
	{
		if (current != null)
			return current;

		return null;
	}

	function stackOverflow(X:Int):Int {
		return 1 + stackOverflow(X);
	}
}
