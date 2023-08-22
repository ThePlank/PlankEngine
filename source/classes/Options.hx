package classes;

import flixel.util.FlxSave;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.util.typeLimit.OneOfTwo;
import flixel.group.FlxSpriteGroup;
import Type.ValueType;

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

// lol imagine psych engine saving system

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
		"testInt" => 0,
		"testFloat" => 0,
	];

	public static var saveData:FlxSave = new FlxSave();

	public static function init():FlxSave {
		saveData.bind("PlankEngineSettings", "PlankDev");
		if (getValue("Yes") == null)
			initSettings();

		for (entry => value in Options.deafultData.keyValueIterator())
			Options.resetSetting(entry);
		
		return saveData;
	}

	#if (flixel < "5.0.0") 
	public static function save(?minFileSize:Null<Int> = 0, ?onComplete:Bool -> Void):Bool
		return saveData.flush(minFileSize, onComplete);
	public static function destroy(?minFileSize:Null<Int> = 0, ?onComplete:Bool -> Void):Bool
		return saveData.close(minFileSize, onComplete);
	#else
	public static function save(?minFileSize:Null<Int> = 0):Bool
		return saveData.flush(minFileSize);

	public static function destroy(?minFileSize:Null<Int> = 0):Bool
		return saveData.close(minFileSize);
	#end

	public static function setValue(key:String, value:Dynamic)
		return Reflect.setField(saveData.data, key, value);


	public static function getValue(key:String):Dynamic
		return Reflect.field(saveData.data, key);

	public static function initSettings():Void
		for (entry => value in deafultData.keyValueIterator())
			setValue(entry, value);

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
			new OptionEntry('flashingMenu', 'Flashing Lights', 'uhhh', Type.getClass(Bool)),
			new OptionEntry('camZoom', 'cumpenis', 'uhhh', Type.getClass(Bool)),
			new OptionEntry('testInt', 'balls', 'balls', Type.getClass(Int), null, {min: 0, max: 420, incrementValue: 10}), // my balls itch
			new OptionEntry('testFloat', 'die', 'amen break', Type.getClass(Float), null, {min: 0, max: 1, incrementValue: 0.1}), // my balls itch
		];
	}
}
