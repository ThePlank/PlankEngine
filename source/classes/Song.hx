package classes;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import classes.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
}

class Song {
	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = File.getContent(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
		return cast Json.parse(rawJson).song;
}
