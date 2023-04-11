package classes;

import lime.graphics.Image;
import flixel.FlxG;
import haxe.Json;
import classes.hscript.PlankState;
import classes.hscript.PlankScript;
import haxe.io.Path;
import openfl.media.Sound;
import classes.Song;
import flixel.system.FlxSound;
import sys.io.File;
import openfl.display.BitmapData;
import sys.FileSystem;
import lime.graphics.ImageType;
import lime.system.System;
import sys.FileSystem;

using StringTools;

typedef ModWindowSettings =
{
	@:optional var windowName:String;
	@:optional var windowIcon:String;
}

// typedef ModSongData =
// {
// 	var inst:Sound;
// 	@:optional var voices:Sound;
// }

typedef ModSongData =
{
	var inst:String;
	@:optional var voices:String;
}

typedef SwagWeek =
{
	var weekName:String;
	var weekDescription:String;
	var characters:Array<String>;
	var songs:Array<String>;
	var freeplayIcons:Array<String>;
	var showInFreeplay:Bool;
	var showInWeek:Bool;
	var weekIndex:Int;
	var freeplayColor:Int;
}

class ModWeek
{
	public var weekName:String;
	public var weekDescription:String;
	public var characters:Array<String>;
	public var songs:Array<String>;
	public var freeplayIcons:Array<String>;
	public var showInFreeplay:Bool;
	public var showInWeek:Bool;
	public var weekIndex:Int;
	public var freeplayColor:Int;

	// i am extremly sorry
	public function new(json:SwagWeek)
	{
		this.weekName = json.weekName;
		this.weekDescription = json.weekDescription;
		this.characters = json.characters;
		this.songs = json.songs;
		this.freeplayIcons = json.freeplayIcons;
		this.showInFreeplay = json.showInFreeplay;
		this.showInWeek = json.showInWeek;
		this.weekIndex = json.weekIndex;
		this.freeplayColor = json.freeplayColor;
	}
}

class Mod
{
	public static final MOD_PATH:String = "User Mods\\Plank Engine";

	public static final MOD_FOLDERS:Array<String> = [ // please forgive me for this, i tried to prent this from happening
		"characters",
		"data",
		"font",
		"globalScripts",
		"images",
		"music",
		"settings",
		"songs",
		"sounds",
		"states",
		"videos",
		"weeks",
	];

	public static var selectedMod:Mod = null;

	public var modName:String;
	public var modDescription:String;
	public var windowSettings:Null<ModWindowSettings>;

	public var modPath:String;

	/**
	 * Creates a new mod
	 * @param modPath  
	 */
	public function new(modPath:String)
	{
		var json:{name:String, description:String, windowSettings:Null<ModWindowSettings>} = Json.parse(getContent(FileSystem.absolutePath('${System.documentsDirectory}$MOD_PATH\\$modPath\\mod.json')));
		this.modName = json.name;
		this.modDescription = json.description;
		this.windowSettings = json.windowSettings;
		this.modPath = modPath;
	}

	public function getPath(path:String):String
	{
		path.replace('/', '\\');
		return '${System.documentsDirectory}$MOD_PATH\\$modPath\\$path';
	}

	public function getContent(path:String):String
	{
		return File.getContent(path);
	}

	public function hasFile(path:String):Bool
	{
		return FileSystem.exists(getPath(path));
	}

	public function getImage(path:String):BitmapData
	{
		return BitmapData.fromFile(getPath('images/$path.png'));
	}

	public function getXML(xml:String):String
	{
		return getPath('images/$xml.xml');
	}

	public function getSong(name:String):ModSongData
	{
		// return {
		// 	inst: Sound.fromFile(getPath('songs/$name/Inst.${Paths.SOUND_EXT}')),
		// 	voices: Sound.fromFile(getPath('songs/$name/Voices.${Paths.SOUND_EXT}')) // this won't error if it can't find it
		// }

		return {
			inst: getPath('songs/$name/Inst.${Paths.SOUND_EXT}'),
			voices: getPath('songs/$name/Voices.${Paths.SOUND_EXT}')
		}
	}

	public function getMusic(name:String):String
	{
		// return Sound.fromFile(getPath('music/$name.${Paths.SOUND_EXT}'));
		return getPath('music/$name.${Paths.SOUND_EXT}');
	}

	public function getSound(name:String):String
	{
		// return Sound.fromFile(getPath('sound/$name.${Paths.SOUND_EXT}'));
		return getPath('sound/$name.${Paths.SOUND_EXT}');
	}

	public function getSongData(name:String, difficulty:String):SwagSong
	{
		var rawJson:String = getContent(getPath('data/$name/$difficulty.json'));

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return Song.parseJSONshit(rawJson);
	}

	public function getData(file:String):String
	{
		return getContent(getPath('data/$file'));
	}

	public function getFont(font:String):String
	{
		return getPath('fonts/$font');
	}

	public function getScripts(song:String):Array<PlankScript>
	{
		var files:Array<String> = FileSystem.readDirectory(getPath('data/$song/'));

		for (file in files)
		{
			if (!file.endsWith(".hscript"))
				files.remove(file);
		}

		return [for (script in files) new PlankScript(getContent(getPath('data/$song/$script')))];
	}

	public function getGlobalScripts():Array<PlankScript>
	{
		var files:Array<String> = FileSystem.readDirectory(getPath('globalScripts/'));

		for (file in files)
		{
			if (!file.endsWith(".hscript"))
				files.remove(file);
		}

		return [
			for (script in files)
				new PlankScript(getContent(getPath('globalScripts/$script')))
		];
	}

	public function getState(path:String):PlankState
	{
		return new PlankState(new PlankScript(getContent(getPath('states/$path'))));
	}

	public function getWeeks():Array<ModWeek>
	{
		var files:Array<String> = FileSystem.readDirectory(getPath('weeks/'));
		var decodedFiles:Array<Dynamic> = [];

		for (file in files)
		{
			if (!file.endsWith(".json"))
			{
				files.remove(file);
				continue;
			}
			decodedFiles.push(Json.parse(file));
		}

		return [for (week in decodedFiles) new ModWeek(week)];
	}

	public static function getAvalibleMods():Array<Mod>
	{
		var mods:Array<String> = FileSystem.readDirectory('${System.documentsDirectory}$MOD_PATH\\');

		for (mod in mods)
		{
			if (!FileSystem.isDirectory('${System.documentsDirectory}$MOD_PATH\\$mod'))
			{
				mods.remove(mod);
			}
		}

		return [for (mod in mods) new Mod(mod)];
	}

	public static function init():Void {
		if (!FileSystem.exists('${System.documentsDirectory}$MOD_PATH')) {
			FileSystem.createDirectory('${System.documentsDirectory}$MOD_PATH');
			trace('my balls itch');
		}
	}

	public function initMod()
	{
		if (windowSettings != null)
		{
			FlxG.stage.window.title = (windowSettings.windowName != null ? windowSettings.windowName : "Friday Night Funkin': Plank Engine");
			if (windowSettings.windowIcon != null)
			{
				var icon = getImage(windowSettings.windowIcon).image;
				icon.format = RGBA32;

				FlxG.stage.window.setIcon(icon);
			}
		}
	}

	public static function createMod(name:String, metadata:{name:String, description:String, ?windowSettings:Null<ModWindowSettings>}):String {
		// openfl.utils.Assets.list()
		for (folder in MOD_FOLDERS) {
			FileSystem.createDirectory('${System.documentsDirectory}$MOD_PATH\\$name\\$folder');
			trace('itchy balls $folder');
		}

		File.saveContent('${System.documentsDirectory}$MOD_PATH\\$name\\mod.json', Json.stringify(metadata));
		return '${System.documentsDirectory}$MOD_PATH\\$name';
	}

	public static function reset()
	{
		FlxG.stage.window.title = "Friday Night Funkin': Plank Engine";

		// todo: find out what icon we should use
	}
}
