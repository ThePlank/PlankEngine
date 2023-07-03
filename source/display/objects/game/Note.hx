package display.objects.game;

import states.game.PlayState;
import classes.Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPool;

using StringTools;

typedef NoteData = {
	var strumTime:Float;
	@:optional var mustPress:Bool; // useless data to note, only here for PlayState
	var noteData:Int;
}

class Note extends FlxSprite
{
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var noteScore:Float = 1;
	public var strumTime:Float;
	public var distance:Float;
	public var sustainLength:Float;
	public var mustPress:Bool;
	public var isSustainNote:Bool;
	public var noteData:Int;

	public static var swagWidth:Float = 160 * 0.7;

	public static var __pool:FlxPool<Note>;

	public function new(strumTime:Float, ?noteData:Int, ?prevNote:Note)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}
	}

	public function reload(noteData:NoteData) {

	}

	private static var noteMap:Array<String> = [
		"left",
		"down",
		"up",
		"right",
	];

	private static var colorMap:Array<String> = [
		"purple",
		"blue",
		"green",
		"red",
	];

	public static function getColorFromDirection(dir:Int):String 
		return colorMap[dir];

	public static function getNameFromDirection(dir:Int):String 
		return noteMap[dir];

	override function update(delta:Float)
	{
		super.update(delta);

			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
