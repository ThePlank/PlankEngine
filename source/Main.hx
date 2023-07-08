package;

import classes.ChartParser;
import haxe.io.Bytes;
import byteConvert.ByteConvert;
import classes.FL.FLFile;
import states.ui.UnexpectedCrashState;
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
import display.objects.game.StrumLine.Player;
import sys.io.FileOutput;
import sys.io.File;
import states.ui.PlankSplash;
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
import display.objects.ui.FPS;
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
import states.ui.TitleState;
// import sdl.Window as SdlWindow;
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


	private static var current:Main;
	public var game:FlxGame;
	public var fpsCounter:PlankFPS;

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

	@:access(flixel.FlxGame)
	@:access(openfl.display.Stage)
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
		Options.initOptions();
		Highscore.load();
		Console.init();

		stage.rethowErrors = false;
		stage.onError.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) -> {
			FlxG.game._requestedState = new UnexpectedCrashState(e.error, CallStack.exceptionStack(true));
			FlxG.game.switchState();
			stage.__rendering = false; // make it render again
		});
		setupGame();

		#if hl
		hl.Api.setErrorHandler(Main.onError);
		#end
	}

	static var consoleClasses:Array<Class<Dynamic>> = [Options, System, Lib, Main, CoolUtil, ZipTools, PlayerSettings, Conductor, Paths #if hl , hl.Gc #end];
	static var consoleEnums:Array<Enum<Dynamic>> = [Player];

	function registerClasses()
	{
		for (unregisteredClass in consoleClasses)
			FlxG.console.registerClass(unregisteredClass);
		for (unregisteredEnum in consoleEnums)
			FlxG.console.registerEnum(unregisteredEnum);
	}

	public static var crashPath = "\\crashes";
	public static var crashName = "\\PLECrashlog";
	static var skipErrors = false;

	// todo: truncate the callstack for da popup because it can cause
	// l
	// o
	// n
	// g
	// messagebox (windows doesent like that)
	#if hl
	public static function onError(error:Dynamic) {
		if (skipErrors)
			return;

		var stack:CallStack = CallStack.exceptionStack(true);
		var callstack:String = try Std.string(error) catch(_:Exception) "Unknown";
		callstack += '\n';
		callstack += CallStack.toString(stack);

		Console.log(callstack, ERROR);

		var params:EnumFlags<DialogFlags> = new EnumFlags<DialogFlags>();
		params.set(IsError);

		saveCrash(error, stack, 'unhandled');

		UI.dialog("Plank Engine Crash Dialog", callstack, params);
	}
	#end

	static public function saveCrash(error:Dynamic, stack:CallStack, subdirectory:String):String {
		var callstack:String = try Std.string(error) catch(_:Exception) "Unknown";
		callstack += '\n';
		callstack += CallStack.toString(stack);
		if (!FileSystem.isDirectory(FileSystem.absolutePath(crashPath)))
			FileSystem.createDirectory(FileSystem.absolutePath(crashPath));

		if (!FileSystem.isDirectory(FileSystem.absolutePath('$crashPath\\$subdirectory')))
			FileSystem.createDirectory(FileSystem.absolutePath('$crashPath\\$subdirectory'));

		var timeString:String = DateTools.format(Date.now(), '%F_%T').replace(':', "-");

		File.saveContent('${FileSystem.absolutePath(crashPath)}\\$subdirectory\\${crashName}_${timeString}.txt', callstack);
		return '${FileSystem.absolutePath(crashPath)}\\$subdirectory\\${crashName}_${timeString}.txt';
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
		stage.window.frameRate = settings.framerate;

		#if (debug)
		settings.initialState = TitleState;
		#end

		game = new FlxGame(settings.gameWidth, settings.gameHeight, settings.initialState, #if (flixel < "5.0.0") settings.zoom, #end settings.framerate, settings.framerate, settings.skipSplash, settings.startFullscreen);
		addChild(game);
		// stage.addEventListener(Event.ENTER_FRAME, update);
		registerClasses();
		classes.Mod.init();
		PlayerSettings.init();
		// classes.Discord.DiscordClient.initialize();

		var sucess:Bool = FlxG.save.bind("PlankEngine", "PlankDev");

		FlxG.signals.postStateSwitch.add(clearYourMom);
		FlxG.signals.postGameReset.add(clearYourMom);
		FlxG.signals.focusLost.add(clearYourMom);
		FlxG.signals.focusGained.add(clearYourMom);
		
		#if !mobile
		fpsCounter = new PlankFPS(10, 3);
		addChild(fpsCounter);
		#end
	}

	function clearYourMom():Void {
		Paths.clearUnusedMemory();
		// Paths.clearStoredMemory();
		Paths.gc(true, 15);
	}

	function update(event:Event) {
		#if hl
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