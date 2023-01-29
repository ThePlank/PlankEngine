package display.objects;

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

class StrumLine extends FlxSpriteGroup
{
	public var strumLine:FlxSprite;
	public var noteHit:FlxTypedSignal<Int->Void>;
	public var strumLineNotes:FlxSpriteGroup;
	public var notes:FlxTypedSpriteGroup<Note>;
	public var scrollSpeed:Float = 1;
	public var score:Int = 0;
	public var combo:Int = 0;
	public var char:Character;
	public var player:Player;

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
			trace(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

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
			// do ceepeeyou >:(
				checkNoteHit();
			case PLAYER1:
				keyShit();
				// port keyShit here
		}
	}

	public function addNote(note:Note)
	{
		notes.add(note);
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = PlayerSettings.player1.controls.UP;
		var right = PlayerSettings.player1.controls.RIGHT;
		var down = PlayerSettings.player1.controls.DOWN;
		var left = PlayerSettings.player1.controls.LEFT;

		var upP = PlayerSettings.player1.controls.UP_P;
		var rightP = PlayerSettings.player1.controls.RIGHT_P;
		var downP = PlayerSettings.player1.controls.DOWN_P;
		var leftP = PlayerSettings.player1.controls.LEFT_P;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlArrayHold:Array<Bool> = [left, down, up, right];

		notes.forEachAlive(function(note)
		{
			if (note.isSustainNote && note.canBeHit && controlArrayHold[note.noteData])
				goodNoteHit(note);
		});

		if (controlArray.indexOf(true) != -1)
		{
			char.holdTimer = 0;
			var HitNotes = [];
			var BadNotes = [];
			var DeleteNotes = [];
			notes.forEachAlive(function(note)
			{
				if (note.canBeHit && !note.tooLate && !note.wasGoodHit)
				{
					if (BadNotes.indexOf(note.noteData) != -1)
					{
						for (i in HitNotes.length...0)
						{
							var daNote:Note = HitNotes[i];
							if (daNote.noteData == note.noteData && Math.abs(daNote.strumTime - note.strumTime) < 1)
							{
								DeleteNotes.push(note);
								// break;
							}
							else if (daNote.noteData == note.noteData && daNote.strumTime > note.strumTime)
							{
								HitNotes.remove(daNote);
								HitNotes.push(note);
								// break;
							}
						}
					}
					else
					{
						HitNotes.push(note);
						BadNotes.push(note.noteData);
					}
				}

				var deletedNotes = 0;
				for (noteToDelete in 0...DeleteNotes.length)
				{
					var c:Note = DeleteNotes[noteToDelete];
					++deletedNotes;
					c.kill();
					notes.remove(c, true);
					c.destroy();
				}

				HitNotes.sort(function(a, b)
				{
					var notetypecompare:Int = Std.int(a.noteData - b.noteData);

					if (notetypecompare == 0)
					{
						return Std.int(a.strumTime - b.strumTime);
					}
					return notetypecompare;
				});

				/*if (perfectMode)
						goodNoteHit(HitNotes[0]);
					else */
				if (HitNotes.length > 0)
				{
					for (deletedNote in deletedNotes...controlArray.length)
					{
						if (controlArray[deletedNote] && BadNotes.indexOf(deletedNote) == -1)
							badNoteHit();
					}

					for (note in 0...HitNotes.length)
					{
						var DaNote = HitNotes[note];
						if (controlArray[DaNote.noteData])
							goodNoteHit(DaNote);
					}
				}
				else if (!Options.getValue("ghostTapping"))
					badNoteHit(false);
			});
		}

		if (char.holdTimer > Conductor.stepCrochet * 4 * 0.001
			&& controlArrayHold.indexOf(true) == -1
			&& char.animation.curAnim.name.startsWith("sing")
			&& !char.animation.curAnim.name.endsWith("miss"))
			char.playAnim("idle");

		strumLineNotes.forEach(function(spr)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != "confirm")
			{
				spr.animation.play("pressed", true);
			}
			if (!controlArrayHold[spr.ID])
			{
				spr.animation.play("static");
				spr.color = FlxColor.WHITE;
			}
			if (spr.animation.curAnim.name == "confirm") {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else
				spr.centerOffsets();

		});
	}

	function noteMiss(direction:Int = 1, playSound:Bool = true):Void
	{
		// if (!char.stunned)
		// {
		FlxG.sound.play(Paths.soundRandom("missnote", 1, 3), FlxG.random.float(0.1, 0.2));
		switch (direction)
		{
			case 0:
				char.playAnim("singLEFTmiss", true);
			case 1:
				char.playAnim("singDOWNmiss", true);
			case 2:
				char.playAnim("singUPmiss", true);
			case 3:
				char.playAnim("singRIGHTmiss", true);
		}
		// }
	}

	function badNoteHit(playSound:Bool = true)
	{
		var daTapping = Options.getValue("ghostTapping");

		if (!daTapping)
			return;

		if (PlayerSettings.player1.controls.LEFT_P)
			noteMiss(0, playSound);
		if (PlayerSettings.player1.controls.DOWN_P)
			noteMiss(1, playSound);
		if (PlayerSettings.player1.controls.UP_P)
			noteMiss(2, playSound);
		if (PlayerSettings.player1.controls.RIGHT_P)
			noteMiss(3, playSound);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteHit();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
			}

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
					spr.centerOffsets();
				}
			});

			note.wasGoodHit = true;

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

			note.x = strumLineNotes.members[Std.int(Math.abs(note.noteData))].x;
			note.y = (strumLine.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)));

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

			if (note.tooLate)
			{
				note.active = false;
				note.visible = false;

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
	}

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

		var coolText:FlxText = new FlxText(0, 0, 0, "", 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
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

		score += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.image(daRating));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

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
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
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

	public function checkNoteHit() {
		notes.forEachAlive((note:Note) -> {
			if (note.strumTime <= Conductor.songPosition)
				note.wasGoodHit = true;

			if (note.wasGoodHit)
				{
					// noteHit.dispatch(Math.abs(note.noteData));
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
}
