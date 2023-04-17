package;

import classes.ChartParser;
import haxe.io.Bytes;
import byteConvert.ByteConvert;
import classes.FL.FLFile;
import states.UnexpectedCrashState;
import haxe.Exception;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display.Stage;
import haxe.Timer;
import classes.hscript.PlankScript;
import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import classes.Conductor;
import haxe.EnumFlags;
import classes.NorwayBanner;
import display.objects.StrumLine.Player;
import sys.io.FileOutput;
import sys.io.File;
import states.PlankSplash;
import util.Console;
import flixel.util.FlxTimer;
// import crashdumper.CrashDumper;
// import crashdumper.SessionData;
import states.AmigaVibeState;
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
import display.objects.FPS;
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
		zoom: 1.0, // If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, // How many frames per second the game should run at.
		skipSplash: true, // Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false, // Whether to start the game in fullscreen on desktop targets
	}


	// public final CRASH_SESSION_ID:String = SessionData.generateID("PlankEngine_");

	private static var current:Main;
	public var game:FlxGame;
	public var fpsCounter:PlankFPS;
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
		stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (error:UncaughtErrorEvent) -> {
			error.preventDefault();
			error.stopImmediatePropagation();
		});
		#if hl
		hl.Api.setErrorHandler(onError);
		#end
		setupGame();
	}

	static var consoleClasses:Array<Class<Dynamic>> = [Options, System, Lib, Main, CoolUtil, ZipTools, PlayerSettings, Conductor, Paths];
	static var consoleEnums:Array<Enum<Dynamic>> = [Player];

	function registerClasses()
	{
		for (unregisteredClass in consoleClasses)
			FlxG.console.registerClass(unregisteredClass);
		for (unregisteredEnum in consoleEnums)
			FlxG.console.registerEnum(unregisteredEnum);
	}

	var crashPath = "\\crashes";
	var crashName = "\\PLECrashlog";

	// todo: truncate the callstack for da popup because it can cause
	// l
	// o
	// n
	// g
	// messagebox (windows doesent like that)
	#if hl
	function onError(error:Dynamic) {
		var callstack:String = try Std.string(error) catch(_:Exception) "Unknown";
		callstack += '\n';
		callstack += CallStack.toString(CallStack.exceptionStack(true));


		Console.log(callstack, ERROR);

		var params:EnumFlags<DialogFlags> = new EnumFlags<DialogFlags>();
		params.set(IsError);

		if (!FileSystem.isDirectory(FileSystem.absolutePath(crashPath))) {
			FileSystem.createDirectory(FileSystem.absolutePath(crashPath));
		}

		var timeString:String = DateTools.format(Date.now(), '%F_%T').replace(':', "-");

		File.saveContent('${FileSystem.absolutePath(crashPath)}\\${crashName}_${timeString}.txt', callstack);
		
		// if (game == null)
			UI.dialog("Plank Engine Crash Dialog", callstack, params);
		// else {
			// FlxG.switchState(new UnexpectedCrashState());
		// }

		return;
	}
	#end

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

		#if (debug)
		settings.initialState = TitleState;
		#end

		game = new FlxGame(settings.gameWidth, settings.gameHeight, settings.initialState, #if (flixel < "5.0.0") settings.zoom, #end settings.framerate, settings.framerate, settings.skipSplash, settings.startFullscreen);
		addChild(game);
		stage.addEventListener(Event.ENTER_FRAME, update);
		registerClasses();
		classes.Mod.init();
		PlayerSettings.init();

		// var file = new FLFile(CoolUtil.BytestoIntArray(File.getBytes(Paths.getPath('data/reddit.fsc', BINARY))));
		// trace(ChartParser.fromFSC(ChartParser.fscToNotes(file)).notes[0]);

		var sucess:Bool = FlxG.save.bind("PlankEngine", "PlankDev");

		FlxG.signals.postStateSwitch.add(clearYourMom);
		FlxG.signals.postGameReset.add(clearYourMom);
		FlxG.signals.focusLost.add(clearYourMom);
		FlxG.signals.focusGained.add(clearYourMom);
		
		#if !mobile
		fpsCounter = new PlankFPS(10, 3);
		for (text in fpsCounter.outlineTexts)
			addChild(text);
		addChild(fpsCounter);
		#end
	}

	function clearYourMom():Void {
		Paths.clearUnusedMemory();
		// Paths.clearStoredMemory();
		Paths.gc(true, 15);
	}

	function update(event:Event) {
		#if (haxe >= "4.3.0" && hl) // only avalible on 4.3rc+
		hl.Api.checkReload();
		#end
	}

	public static function get():Main
	{
		if (current != null)
			return current;

		return null;
	}
}
