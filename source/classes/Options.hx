package classes;

import haxe.DynamicAccess;
import flixel.util.FlxSave;
import sys.thread.Thread;
import flixel.FlxG;

class Option<T> {
	public var displayName:String; // roblox moment??/?/?/?//
	public var description:String;
	public var type:Class<T>;
	public var onChange:T->Void;

	public function new(displayName:String) {
		this.displayName = displayName;
	}
}

// lol image psych engine saving system

class Options
{
	private static var deafultData:Map<String, Dynamic> = [
		"Yes" => "Yes", // do NOT delete this entry!
		"downscroll" => false
	];

	private static var optionsMap:Map<String, Map<String, Option<Any>>> = [
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

	// this is the only part i'm not fond of

	public static function initOptions() {
		// GAMEPLAY

		var gameplayMap:Map<String, Option<Any>> = [];

		var downscroll:Option<Bool> = new Option("Downscroll");
		downscroll.description = "insert description here";

		gameplayMap.set("downscroll", downscroll);

		optionsMap.set("Gameplay", gameplayMap);

		

	}
}
