package classes;

import flixel.system.frontEnds.BitmapFrontEnd;
import util.Console;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import flash.media.Sound;	
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif neko
import neko.vm.Gc;
#end

using StringTools;

// psike engine my beloved
@:access(openfl.display.BitmapData)
@:access(openfl.media.Sound)
@:access(flixel.system.frontEnds.BitmapFrontEnd)
@:access(lime.media.AudioBuffer)
class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	public static function excludeAsset(asset:Dynamic)
	{
		if ((asset is String))
		{
			var key:String = asset;
			for (v in keyExclusions)
				if (key.endsWith(v))
					return;
			keyExclusions.push(key);
			return;
		}
		if (!dumpExclusions.contains(asset))
			dumpExclusions.push(asset);
	}

	public static function unexcludeAsset(asset:Dynamic)
	{
		if ((asset is String))
		{
			var key:String = asset;
			for (v in keyExclusions)
				if (key.endsWith(v))
					keyExclusions.remove(v);
			return;
		}
		dumpExclusions.remove(asset);
	}

	public static function assetExcluded(asset:Dynamic):Bool
	{
		if ((asset is String))
		{
			var key:String = asset;
			for (v in keyExclusions)
				if (key.endsWith(v))
					return true;
			return false;
		}
		for (v in dumpExclusions)
			if (v == asset)
				return true;
		return false;
	}

	public static var dumpExclusions:Array<Dynamic> = [];
	public static var keyExclusions:Array<String> = [
		'music/freakyMenu.$SOUND_EXT',
		'music/breakfast.$SOUND_EXT',
		'images/square.png',
	];

	// this dumps the memory to inspect
	// good if yoy have memory problems

	@:noCompletion public inline static function _dumpMemory()
	{
		#if hl
		Gc.dumpMemory();
		#end
	}

	@:noCompletion private inline static function _gc(major:Bool)
	{
		#if (cpp || neko)
		Gc.run(major);
		#elseif hl
		Gc.major();
		#end
	}

	#if hl
	@:noCompletion private inline static function __init__() {
		var flags = Gc.flags;
		flags.unset(NoThreads);
		// flags.set(Profile);
		Gc.enable(true);
		Gc.flags = flags;
	}
	#end

	@:noCompletion public inline static function compress()
	{
		#if cpp
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif neko
		Gc.run(true);
		#end
	}

	public inline static function gc(major:Bool = false, repeat:Int = 1)
	{
		#if hl
		Gc.blocking(true);
		#end
		while (repeat-- > 0)
			_gc(major);
		#if hl
		Gc.blocking(false);
		#end
	}

	public static function decacheGraphic(key:String) {
		var obj = currentTrackedAssets.get(key);
		currentTrackedAssets.remove(key);
		if ((obj == null && (obj = FlxG.bitmap._cache.get(key)) == null) || assetExcluded(obj))
			return;

		OpenFlAssets.cache.removeBitmapData(key);
		OpenFlAssets.cache.clear(key);
		FlxG.bitmap._cache.remove(key);

		if (obj.bitmap != null)
		{
			obj.bitmap.lock();
			if (obj.bitmap.__texture != null)
				obj.bitmap.__texture.dispose();
			if (obj.bitmap.image != null)
				obj.bitmap.image.data = null;
			obj.bitmap.disposeImage();
		}

		obj.destroy();
		obj = null;
	}

	public static function decacheSound(key:String) {
		var obj = currentTrackedSounds.get(key);
		currentTrackedSounds.remove(key);
		if (obj == null && OpenFlAssets.cache.hasSound(key))
			obj = OpenFlAssets.cache.getSound(key);
		if (obj == null || assetExcluded(obj))
			return;

		OpenFlAssets.cache.removeSound(key);
		OpenFlAssets.cache.clear(key);

		if (obj.__buffer != null)
		{
			obj.__buffer.dispose();
			obj.__buffer = null;
		}
		obj = null;
	}

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !assetExcluded(key))
				decacheGraphic(key);
		}

		compress();
		// gc(true);
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory()
	{
		for (key in FlxG.bitmap._cache.keys())
		{
			if (key != null && !currentTrackedAssets.exists(key) && !assetExcluded(key))
				decacheGraphic(key);
		}

		for (key in currentTrackedSounds.keys())
		{
			if (key != null && !localTrackedAssets.contains(key) && !assetExcluded(key))
				decacheSound(key);
		}

		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
		gc(true);
		compress();
	}

	static public var currentLevel:String;

	static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	public static function getPath(file:String, ?type:AssetType, ?library:String):String
	{
		if (Mod.selectedMod != null) 
			if (FileSystem.exists(Mod.selectedMod.getPath(file))) 
				return Mod.selectedMod.getPath(file);

		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (fileExists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (fileExists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);

	inline static function getLibraryPathForce(file:String, library:String)
		return '$library:assets/$library/$file';

	inline public static function getPreloadPath(file:String = '')
		return 'assets/$file';

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
		return getPath(file, type, library);

	inline static public function txt(key:String, ?library:String)
		return getPath('data/$key.txt', TEXT, library);

	inline static public function xml(key:String, ?library:String)
		return getPath('data/$key.xml', TEXT, library);

	inline static public function json(key:String, ?library:String)
		return getPath('data/$key.json', TEXT, library);

	inline static public function shaderFragment(key:String, ?library:String)
		return getPath('shaders/$key.frag', TEXT, library);

	inline static public function shaderVertex(key:String, ?library:String)
		return getPath('shaders/$key.vert', TEXT, library);

	static public function video(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
		return returnSound('sounds', key, library);

	static public function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound
		return sound(key + FlxG.random.int(min, max), library);

	public static var streamMusic:Bool = false;

	static public function music(key:String, ?library:String, ?stream:Bool):Sound
	{
		return returnSound('music', key, library, stream || streamMusic // stream != null ? stream : (!MusicBeatState.inState(PlayState) || streamMusic)
		);
	}

	// streamlined the assets process more
	static public function image(key:String, ?library:String):FlxGraphic
		return returnGraphic(key, library);

	static public function inst(song:String, ?stream:Bool, forceNoStream:Bool = false):Sound
		return returnSound('data', '${formatToSongPath(song)}/Inst', !forceNoStream && (stream || streamMusic));

	static public function voices(song:String, ?stream:Bool, forceNoStream:Bool = false):Sound
		return returnSound('data', '${formatToSongPath(song)}/Voices', !forceNoStream && (stream || streamMusic));

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		key = getPath(key);
		if (FileSystem.exists(key))
			return File.getContent(key);
		return Assets.getText(key);
	}

	static public function font(key:String):String
	{
		if (Mod.selectedMod != null) {
			var file:String = Mod.selectedMod.getFont(key);
			if (FileSystem.exists(file))
				return file;
		}
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?onlyMods:Bool = false, ?library:String):Bool
	{
		if (!ignoreMods && FileSystem.exists(key))
			return true;

		return !onlyMods && OpenFlAssets.exists(key, type);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String):String
	{
		var invalidChars = ~/[~&\\;:<>#]+/g;
		var hideChars = ~/[.,'"%?!]+/g;

		var path:String = invalidChars.split(path.replace(' ', '-')).join('-');
		return hideChars.split(path).join('').toLowerCase();
	}

	// completely rewritten asset loading? fuck!
	private static var assetCompressTrack:Int = 0;

	@:noCompletion private static function stepAssetCompress():Void
	{
		assetCompressTrack++;
		if (assetCompressTrack > 6)
		{
			assetCompressTrack = 0;
			// gc(true);
			
		}
	}

	public static var hardwareCache:Bool = false;
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	@:keep public static function listAllGraphicMemory(args) {
		for (asset => graphic in currentTrackedAssets) {
			FlxG.log.add('$asset: ${flixel.util.FlxStringUtil.formatBytes(flixel.util.FlxBitmapDataUtil.getMemorySize(graphic.bitmap))}');
		}
	}

	public static function returnGraphic(key:String, ?library:String):FlxGraphic
	{
		var graph:FlxGraphic = null;

		var path:String = (key.endsWith('.png') ? key : getPath('images/$key.png', IMAGE, library) );
		path = path.substr(path.indexOf(':') + 1);
		if ((graph = currentTrackedAssets.get(path)) != null)
			return graph;

		localTrackedAssets.push(path);

		var bitmap:BitmapData = _regBitmap(path, hardwareCache, true);
		if (bitmap != null)
			graph = FlxGraphic.fromBitmapData(bitmap, false, path);

		if (graph != null)
		{
			graph.persist = true;
			currentTrackedAssets.set(path, graph);
			return graph;
		}

		Console.log('fuck $path doesent exist');
		return null;
	}

	private static function _regBitmap(key:String, hardware:Bool, file:Bool):BitmapData
	{
		stepAssetCompress();
		if (!file)
			return OpenFlAssets.getBitmapData(key, false, hardware);
		#if sys
		var newBitmap:BitmapData = BitmapData.fromFile(key);
		if (newBitmap != null)
			return OpenFlAssets.registerBitmapData(newBitmap, key, false, hardware);
		#end
		return null;
	}

	public static function regBitmap(key:String, ?hardware:Bool):BitmapData
	{
		if (hardware == null)
			hardware = hardwareCache;
		if (FileSystem.exists(key))
			return _regBitmap(key, hardware, true);
		if (OpenFlAssets.exists(key, IMAGE))
			return _regBitmap(key, hardware, false);
		return null;
	}

	public static var streamSounds:Bool = false;
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String, ?stream:Bool):Sound
	{
		var path:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		var uwu:String =  path.substr(path.indexOf(':') + 1);

		localTrackedAssets.push(uwu);
		var sound:Sound = currentTrackedSounds.get(uwu);

		// if no stream and sound is stream, fuck it, load one that arent stream
		if (!stream && sound != null && sound.__buffer != null && sound.__buffer.__srcVorbisFile != null)
		{
			decacheSound(uwu);
			sound = null;
		}
		if (sound == null)
			currentTrackedSounds.set(uwu, sound = _regSound(uwu, stream, true));
		if (sound != null)
			return sound;

		trace('oh no its returning "sound" null NOOOO: $uwu');
		return null;
	}

	private static function _regSound(key:String, stream:Bool, file:Bool):Sound
	{
		var snd:Sound = OpenFlAssets.getRawSound(key, stream, file);
		if (snd != null)
			stepAssetCompress();
		return snd;
	}

	public static function regSound(key:String, ?stream:Bool):Sound
	{
		if (stream == null)
			stream = streamSounds;
		if (OpenFlAssets.exists(key, SOUND))
			return _regSound(key, stream, false);
		return null;
	}
}
