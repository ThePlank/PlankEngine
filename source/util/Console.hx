package util;

import haxe.PosInfos;
import lime.utils.LogLevel;

// https://stackoverflow.com/questions/5762491/how-to-print-color-in-console-using-system-out-println
// yes, java moment.
using flixel.util.FlxStringUtil;

class ConsoleColors
{
	// Reset
	public static final RESET = "\033[0m"; // Text Reset

	// Regular Colors
	public static final BLACK = "\033[0;30m"; // BLACK
	public static final RED = "\033[0;31m"; // RED
	public static final GREEN = "\033[0;32m"; // GREEN
	public static final YELLOW = "\033[0;33m"; // YELLOW
	public static final BLUE = "\033[0;34m"; // BLUE
	public static final PURPLE = "\033[0;35m"; // PURPLE
	public static final CYAN = "\033[0;36m"; // CYAN
	public static final WHITE = "\033[0;37m"; // WHITE

	// Bold
	public static final BLACK_BOLD = "\033[1;30m"; // BLACK
	public static final RED_BOLD = "\033[1;31m"; // RED
	public static final GREEN_BOLD = "\033[1;32m"; // GREEN
	public static final YELLOW_BOLD = "\033[1;33m"; // YELLOW
	public static final BLUE_BOLD = "\033[1;34m"; // BLUE
	public static final PURPLE_BOLD = "\033[1;35m"; // PURPLE
	public static final CYAN_BOLD = "\033[1;36m"; // CYAN
	public static final WHITE_BOLD = "\033[1;37m"; // WHITE

	// Underline
	public static final BLACK_UNDERLINED = "\033[4;30m"; // BLACK
	public static final RED_UNDERLINED = "\033[4;31m"; // RED
	public static final GREEN_UNDERLINED = "\033[4;32m"; // GREEN
	public static final YELLOW_UNDERLINED = "\033[4;33m"; // YELLOW
	public static final BLUE_UNDERLINED = "\033[4;34m"; // BLUE
	public static final PURPLE_UNDERLINED = "\033[4;35m"; // PURPLE
	public static final CYAN_UNDERLINED = "\033[4;36m"; // CYAN
	public static final WHITE_UNDERLINED = "\033[4;37m"; // WHITE

	// Background
	public static final BLACK_BACKGROUND = "\033[40m"; // BLACK
	public static final RED_BACKGROUND = "\033[41m"; // RED
	public static final GREEN_BACKGROUND = "\033[42m"; // GREEN
	public static final YELLOW_BACKGROUND = "\033[43m"; // YELLOW
	public static final BLUE_BACKGROUND = "\033[44m"; // BLUE
	public static final PURPLE_BACKGROUND = "\033[45m"; // PURPLE
	public static final CYAN_BACKGROUND = "\033[46m"; // CYAN
	public static final WHITE_BACKGROUND = "\033[47m"; // WHITE

	// High Intensity
	public static final BLACK_BRIGHT = "\033[0;90m"; // BLACK
	public static final RED_BRIGHT = "\033[0;91m"; // RED
	public static final GREEN_BRIGHT = "\033[0;92m"; // GREEN
	public static final YELLOW_BRIGHT = "\033[0;93m"; // YELLOW
	public static final BLUE_BRIGHT = "\033[0;94m"; // BLUE
	public static final PURPLE_BRIGHT = "\033[0;95m"; // PURPLE
	public static final CYAN_BRIGHT = "\033[0;96m"; // CYAN
	public static final WHITE_BRIGHT = "\033[0;97m"; // WHITE

	// Bold High Intensity
	public static final BLACK_BOLD_BRIGHT = "\033[1;90m"; // BLACK
	public static final RED_BOLD_BRIGHT = "\033[1;91m"; // RED
	public static final GREEN_BOLD_BRIGHT = "\033[1;92m"; // GREEN
	public static final YELLOW_BOLD_BRIGHT = "\033[1;93m"; // YELLOW
	public static final BLUE_BOLD_BRIGHT = "\033[1;94m"; // BLUE
	public static final PURPLE_BOLD_BRIGHT = "\033[1;95m"; // PURPLE
	public static final CYAN_BOLD_BRIGHT = "\033[1;96m"; // CYAN
	public static final WHITE_BOLD_BRIGHT = "\033[1;97m"; // WHITE

	// High Intensity backgrounds
	public static final BLACK_BACKGROUND_BRIGHT = "\033[0;100m"; // BLACK
	public static final RED_BACKGROUND_BRIGHT = "\033[0;101m"; // RED
	public static final GREEN_BACKGROUND_BRIGHT = "\033[0;102m"; // GREEN
	public static final YELLOW_BACKGROUND_BRIGHT = "\033[0;103m"; // YELLOW
	public static final BLUE_BACKGROUND_BRIGHT = "\033[0;104m"; // BLUE
	public static final PURPLE_BACKGROUND_BRIGHT = "\033[0;105m"; // PURPLE
	public static final CYAN_BACKGROUND_BRIGHT = "\033[0;106m"; // CYAN
	public static final WHITE_BACKGROUND_BRIGHT = "\033[0;107m"; // WHITE
}

class Console
{
	public static function log(stuffs:Dynamic, ?level:LogLevel = INFO, ?info:PosInfos)
	{
		info.className = info.className.remove(".hx");
		info.className = info.className.toUpperCase();

		var mainText = '';

		switch (level)
		{
			case INFO:
				mainText = ConsoleColors.BLUE;
			case DEBUG:
				mainText = ConsoleColors.GREEN;
			case ERROR:
				mainText = ConsoleColors.RED_BOLD;
			case WARN:
				mainText = ConsoleColors.YELLOW_BOLD;
			case NONE:
			case VERBOSE:
				mainText = ConsoleColors.PURPLE;
		}

		mainText += '[${info.className} LINE ${info.lineNumber}]:';
		mainText +=  '${ConsoleColors.RESET} ';
		mainText +=  '${stuffs}';

		println(mainText);
	}

	private static inline function print(message:Dynamic):Void
	{
		#if sys
		Sys.print(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(message);
		#else
		trace(message);
		#end
	}

	private static inline function println(message:Dynamic):Void
	{
		#if sys
		Sys.println(Std.string(message));
		#elseif flash
		untyped __global__["trace"](Std.string(message));
		#elseif js
		untyped #if haxe4 js.Syntax.code #else __js__ #end ("console").log(message);
		#else
		trace(Std.string(message));
		#end
	}

	public static function init()
	{
		haxe.Log.trace = (stuffs:Dynamic, ?info:PosInfos) ->
		{
			log(stuffs, INFO, info);
		}
	}
}
