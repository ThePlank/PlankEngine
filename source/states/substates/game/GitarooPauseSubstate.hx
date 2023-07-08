package states.substates.game;

import states.abstr.UIBaseState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

import classes.Conductor;
import states.game.PlayState;
import states.ui.MainMenuState;

class GitarooPauseSubstate extends states.substates.abstr.MusicBeatSubstate
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;
	var pauseMusic:FlxSound;
	var oldSongBpm:Int;
	var oldSongPosition:Float;
	var bf:FlxSprite;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		// if (FlxG.sound.music != null)
			// FlxG.sound.music.stop();

		oldSongBpm = Conductor.bpm;
		oldSongPosition = Conductor.songPosition;
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('secretPause'), true, true);
		FlxG.sound.list.add(pauseMusic);
		pauseMusic.play(false);
		Conductor.bpm = 94;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		add(bg);

		bf = new FlxSprite(0, 30, Paths.image('pauseAlt/lowqualitybf'));
		bf.origin.y = bf.height;
		add(bf);
		bf.screenCenter(X);

		replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		add(cancelButton);

		add(new GitarooOption(cancelButton.x, cancelButton.y, 'CANCEL'));

		changeThing();

		super.create();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override public function beatHit() {
		cameras[0].zoom += 0.15;
		bf.scale.set(1.2, 0.8);
		bf.flipX = !bf.flipX;
	}

	override function update(delta:Float)
	{
		bf.scale.x = flixel.math.FlxMath.lerp(bf.scale.x, 1, 0.15);
		bf.scale.y = flixel.math.FlxMath.lerp(bf.scale.y, 1, 0.25);
		cameras[0].zoom = flixel.math.FlxMath.lerp(cameras[0].zoom, 1, 0.25);
		Conductor.songPosition = pauseMusic.time;

		if (controls.LEFT_P || controls.RIGHT_P)
			changeThing();

		if (controls.ACCEPT)
		{
			if (replaySelect)
			{
				UIBaseState.switchState(PlayState);
			}
			else
			{
				UIBaseState.switchState(MainMenuState);
			}
		}

		super.update(delta);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}


class GitarooOption extends flixel.group.FlxSpriteGroup {
	var bg:FlxSprite;
	var text:flixel.text.FlxText;
	public function new(x:Float, y:Float, text:String):Void {
		super(x, y);
		bg = new FlxSprite(0, 0, classes.Paths.image('pauseAlt/optionBG'));
		bg.color = 0xff75ddff;
		add(bg);
		this.text = new flixel.text.FlxText(0, 0, width + (text.length * 18), text, 80);
		this.text.x = (this.width / 2) - (this.text.width / 2);
		this.text.y = (this.height / 2);
		this.text.setFormat(Paths.font('vcr.ttf'), 80, 0xff000000, CENTER);
		add(this.text);
	}
}