package util;

import haxe.io.Bytes;
import flixel.FlxG;
import openfl.Lib;
import lime.ui.Window;
import states.game.PlayState;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', 'NORMAL', 'HARD'];

	public static inline function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static inline function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		return [for (item in daList) item.trim()];
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (num in min...max) num];
	}

	public static inline function getMainWindow():Window
	{
		return FlxG.stage.window;
	}

	// copied code from old plank engine (i think literally the only good code i have made there)
	// i dont know for where i got this from
	// pretty sure i made this myself
	
	public static function DynamicToIntArrayMap(dynamicObject:Dynamic)
	{
		var map:Map<String, Array<Int>> = new Map();
		for (field in Reflect.fields(dynamicObject))
		{
			map.set(field, Reflect.field(dynamicObject, field));
		}
		return map;
	}

}

class FPSLerp
{
	public static function lerpValue(ratio:Float):Float
	{
		return FlxG.elapsed / (1 / 60) * ratio;
	}

	public static function lerp(a:Float, b:Float, ratio:Float)
	{
		return a + lerpValue(ratio) * (b - a);
	}
}
