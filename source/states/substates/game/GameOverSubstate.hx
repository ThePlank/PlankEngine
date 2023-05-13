package states.substates.game;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BlurFilter;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import states.abstr.UIBaseState;
import classes.Conductor;
import display.objects.game.Boyfriend;
import states.substates.abstr.MusicBeatSubstate;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.game.PlayState;
import states.ui.LoadingState;
import states.ui.StoryMenuState;
import states.ui.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float, layeredHuds:Array<FlxCamera>)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super(0xFF000000);
		
		var extendedBG = new FlxSprite(-FlxG.width / 2, -FlxG.width / 2);
		extendedBG.makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		extendedBG.scrollFactor.set();
		add(extendedBG); // stupid
		// todo: how to not stupid

		var blur = new BlurFilter(1, 1, BitmapFilterQuality.HIGH);
		FlxG.camera.zoom = FlxG.camera.zoom * 0.75;

		FlxTween.tween(blur, {blurX: 12, blurY: 12}, 2, {ease: FlxEase.expoOut});
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoOut});
		for (hud in layeredHuds) {
			hud.setFilters([blur]);
			FlxTween.tween(hud, {zoom: 5}, 2, {ease: FlxEase.circInOut, startDelay: 0.5});
		}

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.bpm = 100;

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(delta:Float)
	{
		super.update(delta);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				UIBaseState.switchState(StoryMenuState);
			else
				UIBaseState.switchState(FreeplayState);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
