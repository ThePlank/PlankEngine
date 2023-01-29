package;

import display.objects.StrumLine.Player;
import classes.GarbageCompactor;
import sys.io.FileOutput;
import sys.io.File;
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
import openfl.filesystem.File as OFLFile;
#if hl
import hl.UI;
#end

using StringTools;

typedef GameSettings = {
	gameWidth:Int,
	gameHeight:Int,
	initialState:Class<FlxState>,
	zoom:Float,
	framerate:Int,
	skipSplash:Bool,
	startFullscreen:Bool,
}

class Main extends Sprite
{

	// maybe add a .json file for this?///?//
	public static var settings:GameSettings = {
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

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		setupGame();
	}

	static var consoleClasses:Array<Class<Dynamic>> = [Options, System, Lib, Main, CoolUtil, ZipTools, PlayerSettings];
	static var consoleEnums:Array<Enum<Dynamic>> = [Player];

	function registerClasses()
	{
		for (unregisteredClass in consoleClasses)
			FlxG.console.registerClass(unregisteredClass);
		for (unregisteredEnum in consoleEnums)
			FlxG.console.registerEnum(unregisteredEnum);
	}

	var crashPath = "\\crashes";
	var crashName = "\\PLECrashlog_";

	// based off https://github.com/larsiusprime/crashdumper/blob/master/crashdumper/CrashDumper.hx
	function onError(error:UncaughtErrorEvent) {
		if (!FileSystem.exists(FileSystem.absolutePath(crashPath)))
			FileSystem.createDirectory(FileSystem.absolutePath(crashPath));

		var stack = getStackTrace();

		var name = crashName + Date.now().toString().replace("-", "_").replace(" ", "_").replace(":", "_");

		var file = File.write(FileSystem.absolutePath(crashPath + name));
		file.writeString(stack);
		file.close();
	}

	private function getStackTrace():String
		{
			var stackTrace:String = "";
			var stack:Array<StackItem> = CallStack.exceptionStack();
			#if flash
			stack.reverse();
			#end
			var item:StackItem;
			for (item in stack)
			{
				stackTrace += printStackItem(item) + "\n";
			}
			return stackTrace;
		}

	private function printStackItem(itm:StackItem):String
		{
			var str:String = "";
			switch( itm ) {
				case CFunction:
					str = "a C function";
				case Module(m):
					str = "module " + m;
				case FilePos(itm,file,line):
					if( itm != null ) {
						str = printStackItem(itm) + " (";
					}
					str += file;
					// if (SHOW_LINES)
					// {
						str += " line ";
						str += line;
					// }
					if (itm != null) str += ")";
				case Method(cname,meth):
					str += (cname);
					str += (".");
					str += (meth);
				#if (haxe_ver >= "3.1.0")
				case LocalFunction(n):
				#else
				case Lambda(n):
				#end
					str += ("local function #");
					str += (n);
			}
			return str;
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

		#if debug
		settings.initialState = TitleState;
		#end

		addChild(new FlxGame(settings.gameWidth, settings.gameHeight, settings.initialState, #if (flixel < "5.0.0") settings.zoom, #end settings.framerate, settings.framerate, settings.skipSplash, settings.startFullscreen));
		registerClasses();
		PlayerSettings.init();

		FlxG.signals.preStateCreate.add((state:FlxState) -> {
			GarbageCompactor.clearMajor();
		});

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
