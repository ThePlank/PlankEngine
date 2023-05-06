package display.objects;

import display.objects.Note;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.FlxCamera;
import flixel.FlxBasic.IFlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import classes.Options;
import classes.PlayerSettings;
import flixel.util.FlxSort;
import flixel.util.FlxSignal;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import classes.Conductor;
import flixel.system.FlxSoundGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

enum Player
{
	NONE;
	CPU;
	PLAYER1;
}

@:access(Note)
class StrumLine extends FlxTypedSpriteGroup<FlxSprite>
{
	public var strumLine:FlxSprite;
	public var noteHit:FlxTypedSignal<Int->Void>;
	public var strumLineNotes:FlxSpriteGroup;
	// public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;
	public var notes:FlxTypedSpriteGroup<Note>;
	public var scrollSpeed:Float = 1;
	public var score:Int = 0;
	public var combo:Int = 0;
	public var char:Character;
	public var player:Player;

	public var onHit:FlxTypedSignal<Int>;

	static var strumHeight:Int = FlxG.height;


	public function new(player:Player = NONE, char:Character, ?tweenStrums:Bool = true)
	{
		super();
		this.char = char;
		this.player = player;

		strumLine = new FlxSprite(0, 50);
		strumLine.alpha = 0.5;
		// add(strumLine);

		strumLineNotes = generateStaticArrows(tweenStrums);
		add(strumLineNotes);

		// noteSplashes = new FlxTypedSpriteGroup<NoteSplash>();

		// var noteSplash:NoteSplash = new NoteSplash(0, 0, 0);
		// noteSplash.alpha = 0.1;
		// noteSplashes.add(noteSplash);

		// add(noteSplashes);

		strumLine.makeGraphic(Std.int(strumLineNotes.width), 10);

		notes = new FlxTypedSpriteGroup<Note>();
		add(notes);

		noteHit = new FlxTypedSignal<Int->Void>();
	}



	private function generateStaticArrows(?tweenStrums:Bool = true):FlxSpriteGroup
	{
		var strumNotes:FlxSpriteGroup = new FlxSpriteGroup();

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += Note.swagWidth * i;
			var dir:String = Note.getNameFromDirection(i);
			babyArrow.animation.addByPrefix('static', 'arrow${dir.toUpperCase()}');
			babyArrow.animation.addByPrefix('pressed', '${dir} press', 24, false);
			babyArrow.animation.addByPrefix('confirm', '${dir} confirm', 24, false);

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (tweenStrums)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');

			strumNotes.add(babyArrow);
		}

		return strumNotes;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		handleNotes();

		switch (player)
		{
			case NONE:
			case CPU:
				checkNoteHit();
			case PLAYER1:
				keyShit();
		}
	}

	public function addNote(note:Note)
	{
		notes.add(note);
	}

	private function keyShit():Void
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT,
			PlayerSettings.player1.controls.DOWN,
			PlayerSettings.player1.controls.UP,
			PlayerSettings.player1.controls.RIGHT
		];
		var pressArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT_P,
			PlayerSettings.player1.controls.DOWN_P,
			PlayerSettings.player1.controls.UP_P,
			PlayerSettings.player1.controls.RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			PlayerSettings.player1.controls.LEFT_R,
			PlayerSettings.player1.controls.DOWN_R,
			PlayerSettings.player1.controls.UP_R,
			PlayerSettings.player1.controls.RIGHT_R
		];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) /*!boyfriend.stunned && */)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		// PRESSES, check for note hits
		if (pressArray.contains(true) /*!boyfriend.stunned && */)
		{
			char.holdTimer = 0;

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			/*if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else */
			if (possibleNotes.length > 0)
			{
				for (shit in 0...pressArray.length)
				{ // if a direction is hit that shouldn't be
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit);
				}
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			}
			else
			{
				// for (shit in 0...pressArray.length)
					// if (pressArray[shit])
						// noteMiss(shit);
			}
		}

		if (char.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (char.animation.curAnim.name.startsWith('sing') && !char.animation.curAnim.name.endsWith('miss'))
			{
				char.playAnim('idle');
			}
		}

		strumLineNotes.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		// whole function used to be encased in if (!boyfriend.stunned)
		health -= 0.04;
		combo = 0;

		// if (!practiceMode)
		//	songScore -= 10;

		// vocals.volume = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		switch (direction)
		{
			case 0:
				char.playAnim('singLEFTmiss', true);
			case 1:
				char.playAnim('singDOWNmiss', true);
			case 2:
				char.playAnim('singUPmiss', true);
			case 3:
				char.playAnim('singRIGHTmiss', true);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note, note.strumTime);
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					char.playAnim('singLEFT', true);
				case 1:
					char.playAnim('singDOWN', true);
				case 2:
					char.playAnim('singUP', true);
				case 3:
					char.playAnim('singRIGHT', true);
			}

			strumLineNotes.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			// vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	private function handleNotes()
	{
		notes.forEachAlive((note:Note) ->
		{
			note.distance = ((Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)));
			var strum:FlxSprite = strumLineNotes.members[Std.int(Math.abs(note.noteData))];
			// var direction:Float = strum.angle * Math.PI / 180;
			// note.x = strum.x + Math.cos(direction);
			// note.y = strum.y + Math.sin(strum.angle * Math.PI / 180) * note.distance;
			// note.angle = strum.angle;
			note.x = strum.x;
			note.y = strum.y - note.distance;

			// i am so fucking sorry for this if condition
			if (note.isSustainNote
				&& note.y + note.offset.y <= strumLine.y + Note.swagWidth / 2
				&& ((note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
			{
				var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - note.y, note.width * 2, note.height * 2);
				swagRect.y /= note.scale.y;
				swagRect.height -= swagRect.y;

				note.clipRect = swagRect;
			}

			if (note.tooLate && player != CPU )
			{
				note.active = false;
				note.visible = false;
				noteMiss(note.noteData);

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
	}

	// turns out that you cant only have note because that makes the inputs tighter????///?/??/?/?/??/
	private function popUpScore(note:Note, ?strumTime:Float):Void
	{
		var noteDiff:Float = Math.abs((strumTime != null ? strumTime : note.strumTime) - Conductor.songPosition);

		var coolText:FlxText = new FlxText(0, 0, 0, "", 32);
		coolText.x = strumLine.width / 2;
		coolText.y = strumHeight / 2;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		// if (daRating == 'sick') {
			// var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash);
			// noteSplash.setupNoteSplash(Note.swagWidth  * note.noteData , strumLine.y, note.noteData);
			// noteSplashes.add(noteSplash);
		// }

		score += score;

		rating.loadGraphic(Paths.image(daRating));
		rating.x = coolText.x - 40;
		rating.y = coolText.y - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.angularAcceleration = FlxG.random.int(-45, 45);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.x = coolText.x;
		comboSpr.y = coolText.y;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.angularAcceleration = FlxG.random.int(-45, 45);

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = true;

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y = coolText.y + 80;

			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.angularAcceleration = FlxG.random.int(-45, 45);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	public function checkNoteHit()
	{
		notes.forEachAlive((note:Note) ->
		{
			if (note.y > FlxG.height)
			{
				note.active = false;
				note.visible = false;
			}
			else
			{
				note.visible = true;
				note.active = true;
			}

			if (note.strumTime <= Conductor.songPosition)
				note.wasGoodHit = true;

			if (note.wasGoodHit)
			{
				var altAnim:String = "";

				// if (note.altAnim)
				// altAnim = '-alt';

				switch (Math.abs(note.noteData))
				{
					case 0:
						char.playAnim('singLEFT' + altAnim, true);
					case 1:
						char.playAnim('singDOWN' + altAnim, true);
					case 2:
						char.playAnim('singUP' + altAnim, true);
					case 3:
						char.playAnim('singRIGHT' + altAnim, true);
				}

				char.holdTimer = 0;

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
	}

	public function sortNotes()
	{
		notes.sort(FlxSort.byY, FlxSort.DESCENDING);
	}

	override function set_angle(value:Float):Float {
		var pivot:FlxPoint = FlxPoint.get(width / 2, strumHeight / 2);
		strumLineNotes.forEach((sprite:FlxSprite) -> {
			var spritePoint:FlxPoint = FlxPoint.get(sprite.x, sprite.y);
			spritePoint.pivotDegrees(pivot, value);
			sprite.x = spritePoint.x;
			sprite.y = spritePoint.y;
			spritePoint.put();
		});

		return super.set_angle(value);
	}
}