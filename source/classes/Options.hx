package classes;

import haxe.DynamicAccess;
import flixel.util.FlxSave;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.util.typeLimit.OneOfTwo;
import flixel.group.FlxSpriteGroup;

// i whould do OptionEntry<T> but idek ho to get the Class<Dynamic> of it
class OptionEntry {
	public var description:String;
	public var entryName:String;
	public var displayName:String;
	public var type:Class<Dynamic>;
	public var limits:{?min:Float, ?max:Float, ?incrementValue:Float, ?options:Array<Dynamic>};
	public var onChange:Dynamic->Void;

	public function new(entryName:String, displayName:String, description:String, type:Class<Dynamic>, ?onChange:Dynamic->Void, ?limits:{?min:Float, ?max:Float, ?incrementValue:Float, ?options:Array<Dynamic>}) {
		this.description = description;
		this.entryName = entryName;
		this.displayName = displayName;
		this.type = type;
		this.limits = limits;
		this.onChange = onChange;
	}
}

// lol image psych engine saving system

class Options
{
	public static var optionData:Map<String, OneOfTwo<Array<OptionEntry>, FlxSpriteGroup->Void>> = [];
	private static var deafultData:Map<String, Dynamic> = [
		"Yes" => "Yes", // do NOT delete this entry!
		"downscroll" => false,
		"flashingMenu" => true,
		"camZoom" => true,
		"autoPause" => false,
		"ghostTapping" => true,
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

	public static function resetSetting(key:String):Bool {
		if (getValue(key) == null && deafultData.exists(key)) {
			setValue(key, deafultData.get(key));
			return true;
		}
		return false;
	}

	public static function initOptions() {
		optionData['gameplay'] = [
			new OptionEntry('downscroll', 'Downscroll', 'Makes the notes scroll idk', Type.getClass(Bool)),
			new OptionEntry('flashingMenu', 'Sex Scenes', 'uhhh', Type.getClass(Bool)),
		];
	}
}
