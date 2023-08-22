package display.objects.game;

import display.objects.game.Note;
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
import display.objects.game.Sustain;

using StringTools;

enum Player
{
	NONE;
	CPU;
	PLAYER1;
}

typedef HitData = {
	var note:Note;
	var rating:String;
	var score:Int;
	var combo:Int;
	var noteDiff:Float;
}

@:access(Note)
class StrumLine extends FlxTypedSpriteGroup<FlxSprite>
{
	public var noteHit:FlxTypedSignal<HitData->Void>;
	public var onMiss:FlxTypedSignal<Int->Void>;

	public var strumLineNotes:FlxSpriteGroup;
	public var notes:FlxTypedSpriteGroup<Note>;
	public var sustains:FlxTypedSpriteGroup<Sustain>;

	public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;
	public var noteSplashesEnabled:Bool;

	public var scrollSpeed:Float = 1;
	public var score:Int = 0;
	public var combo:Int = 0;

	public var char:Null<Character>;
	public var player:Player;

	static var strumHeight:Int = FlxG.height;

	public function new(x:Int, y:Int, player:Player = NONE, ?char:Character, ?tweenStrums:Bool = false)
	{
		super(x, y);
		this.char = char;
		this.player = player;

		this.noteSplashesEnabled = player == PLAYER1;

		strumLineNotes = generateStaticArrows(tweenStrums);
		add(strumLineNotes);

		noteSplashes = new FlxTypedSpriteGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(0, 0, 0);
		noteSplash.alpha = 0.1;
		noteSplashes.add(noteSplash);

		add(noteSplashes);

		sustains = new FlxTypedSpriteGroup<Sustain>();

		notes = new FlxTypedSpriteGroup<Note>();
		add(notes);
		// add(sustains);

		noteHit = new FlxTypedSignal<HitData->Void>();
		onMiss = new FlxTypedSignal<Int->Void>();
	}

	private function generateStaticArrows(?tweenStrums:Bool = true):FlxSpriteGroup
	{
		var strumNotes:FlxSpriteGroup = new FlxSpriteGroup();

		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, 0);

			babyArrow.frames = Paths.getSparrowAtlas('notes/strums');

			babyArrow.antialiasing = true;
			babyArrow.scale.set(0.7, 0.7);

			babyArrow.x += Note.swagWidth * i;
			var anim:String = 'arrow${Note.getNameFromDirection(i).toUpperCase()}';
			babyArrow.animation.addByPrefix('static', '${anim}0', 24, true);
			babyArrow.animation.addByPrefix('pressed', '${anim}press', 24, false);
			babyArrow.animation.addByPrefix('confirm', '${anim}confirm', 24, false);

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

	override function update(delta:Float)
	{
		super.update(delta);
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

	public function addNote(note:flixel.util.typeLimit.OneOfTwo<Note, Sustain>) {
		if (note is Note)
			notes.add(note);
		else if (note is Sustain)
			sustains.add(note);
		else throw 'what?';
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
		/*
		if (holdArray.contains(true))
		{
			sustains.forEachAlive(function(daNote:Sustain)
			{
				if (daNote.canBeHit && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}*/

		// PRESSES, check for note hits
		if (pressArray.contains(true) /*!boyfriend.stunned && */)
		{
			if (char != null) char.holdTimer = 0;

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

		if (char != null) {
			if (char.holdTimer > Conductor.stepCrochet * char.singTime * 0.001 && !holdArray.contains(true))
			{
				if (char.animation.curAnim.name.startsWith('sing') && !char.animation.curAnim.name.endsWith('miss'))
				{
					char.playAnim('idle');
				}
			}
		}

		strumLineNotes.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');
			
			spr.centerOffsets();
			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		combo = 0;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		switch (direction)
		{
			case 0:
				charPlayAnim('singLEFTmiss', true);
			case 1:
				charPlayAnim('singDOWNmiss', true);
			case 2:
				charPlayAnim('singUPmiss', true);
			case 3:
				charPlayAnim('singRIGHTmiss', true);
		}
		
		onMiss.dispatch(direction);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			combo += 1;
			popUpScore(note, note.strumTime);

			switch (note.noteData)
			{
				case 0:
					charPlayAnim('singLEFT', true);
				case 1:
					charPlayAnim('singDOWN', true);
				case 2:
					charPlayAnim('singUP', true);
				case 3:
					charPlayAnim('singRIGHT', true);
			}

			strumLineNotes.members[Std.int(Math.abs(note.noteData))].animation.play('confirm', true);
			updateNoteAnimationOffsets();

			note.wasGoodHit = true;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	private function getStrumFromData(noteData:Int)
		return strumLineNotes.members[noteData];

	private function handleNotes()
	{
		notes.forEachAlive((note:Note) ->
		{
			note.distance = ((Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2)));
			var strum:FlxSprite = getStrumFromData(Std.int(Math.abs(note.noteData)));
			// var direction:Float = strum.angle * Math.PI / 180;
			// note.x = strum.x + Math.cos(direction);
			// note.y = strum.y + Math.sin(strum.angle * Math.PI / 180) * note.distance;
			// note.angle = strum.angle;
			note.x = strum.x;
			note.y = strum.y - note.distance;
			if (note.sustain != null) {
				note.sustain.y = note.y;
				note.sustain.x = (note.x / 2 - note.sustain.width / 2);
			}

			// i am so fucking sorry for this if condition
			if (note.isSustainNote
				&& note.y + note.offset.y <= strum.y + Note.swagWidth / 2
				&& ((note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
			{
				var swagRect = new FlxRect(0, strum.y + Note.swagWidth / 2 - note.y, note.width * 2, note.height * 2);
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

		sustains.forEachAlive((note:Sustain) -> {
			if (note.parent.strumTime + note.length < Conductor.songPosition) {
				note.active = false;
				note.visible = false;

				note.kill();
				sustains.remove(note, true);
				note.destroy();
			}
		});

	}

	static public function generatePopup(data:HitData):FlxSpriteGroup {
		var group:FlxSpriteGroup = new FlxSpriteGroup();

		var rating:FlxSprite = new FlxSprite(-40, -60, Paths.image('ratings/${data.rating}'));
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.angularAcceleration = FlxG.random.int(-45, 45);

		var comboSpr:FlxSprite = new FlxSprite(0, 0, Paths.image('ratings/combo'));
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.angularAcceleration = FlxG.random.int(-45, 45);
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		rating.scale.set(0.7, 0.7);
		rating.antialiasing = true;

		comboSpr.scale.set(0.7, 0.7);
		comboSpr.antialiasing = true;
		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(data.combo / 100));
		seperatedScore.push(Math.floor((data.combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(data.combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite((43 * daLoop) - 90, 80, Paths.image('ratings/num${Std.int(i)}'));

			numScore.antialiasing = true;
			numScore.scale.set(0.5, 0.5);
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.angularAcceleration = FlxG.random.int(-45, 45);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (data.combo >= 10 || data.combo == 0)
				group.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		group.add(rating);
		group.add(comboSpr);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
				group.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		return group;
	}

	private function popUpScore(note:Note, ?strumTime:Float):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

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

		if (daRating == 'sick' && noteSplashesEnabled) {
			var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(note.x - x, note.y - y, note.noteData); // die
			noteSplashes.add(noteSplash);
		}

		score += score;
		
		noteHit.dispatch({
			note: note,
			rating: daRating,
			score: score,
			combo: combo,
			noteDiff: note.strumTime - Conductor.songPosition,
		});
	}

	public function checkNoteHit()
	{
		strumLineNotes.forEach(function(spr:FlxSprite) {
			updateNoteAnimationOffsets();
			spr.animation.finishCallback = (name) -> {if (name == 'confirm') spr.animation.play('static');}
		});

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

			if (note.strumTime <= Conductor.songPosition) {
				goodNoteHit(note);
				if (char != null) char.holdTimer = 0;
			}
		});
	}

	private function updateNoteAnimationOffsets() {
		strumLineNotes.forEach(function(spr:FlxSprite) {
			spr.centerOffsets();
			if (spr.animation.curAnim.name == 'confirm') {
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			// possibly make player a setter for this? :3 spr.animation.finishCallback = (name) -> {if (name == 'confirm') spr.animation.play('static');}
		});
	}

	function charPlayAnim(name:String, ?force:Bool = false)
		if (char != null) char.playAnim(name, force);

	public function sortNotes()
		notes.sort(FlxSort.byY, FlxSort.DESCENDING);

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