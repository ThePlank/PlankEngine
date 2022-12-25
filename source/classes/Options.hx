package classes;

import haxe.DynamicAccess;
import flixel.util.FlxSave;
import sys.thread.Thread;
import flixel.FlxG;

class Options
{
	private static var deafultData:Map<String, Dynamic> = [
		"Yes" => "Yes", // do NOT delete this entry!
		"downscroll" => false
	];

	public static var saveData:FlxSave = new FlxSave();

	public static function init():FlxSave {
		saveData.bind("PlankEngineSettings", "PlankDev");
		if (getValue("Yes") == null)
			initSettings();
		
		return saveData;
	}

	#if (flixel < "5.0.0") 
	public static function save(?minFileSize:Null<Int> = 0, ?onComplete:Bool -> Void):Bool {
		return saveData.flush(minFileSize, onComplete);
	}

	public static function destroy(?minFileSize:Null<Int> = 0, ?onComplete:Bool -> Void):Bool {
		return saveData.close(minFileSize, onComplete);
	}
	#else
	public static function save(?minFileSize:Null<Int> = 0):Bool {
		return saveData.flush(minFileSize);
	}

	public static function destroy(?minFileSize:Null<Int> = 0):Bool {
		return saveData.close(minFileSize);
	}
	#end

	public static function setValue(key:String, value:Dynamic) {
		Reflect.setField(saveData.data, key, value);
	}


	public static function getValue(key:String):Dynamic {
		return Reflect.field(saveData.data, key);
	}

	public static function initSettings():Void {
		for (entry => value in deafultData.keyValueIterator()) {
			setValue(entry, value);
		}
	}
}
