package states.substates.game;

import states.abstr.UIBaseState;
import util.CoolUtil;
import display.objects.ui.Alphabet;
import states.substates.abstr.MusicBeatSubstate;
import classes.Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.game.PlayState;
import states.ui.MainMenuState;
import display.objects.ui.MenuList;
import display.objects.ui.AtlasText;
import display.objects.ui.AtlasText.AtlasFont;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:MenuList;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];

	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new MenuList(0, 0, VERTICAL(true));
		grpMenuShit.padding = 100;
		grpMenuShit.moveWithCurSelection = true;
		grpMenuShit.focused = true;
		grpMenuShit.canSelect = true;
		grpMenuShit.screenCenter(Y);
		grpMenuShit.x = 50;
		grpMenuShit.onSelect.add((selection) -> {
			var daSelected:String = menuItems[selection];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					UIBaseState.switchState(MainMenuState);
			}
		});
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:AtlasText = new AtlasText(0, 0, menuItems[i], AtlasFont.Bold);
			grpMenuShit.add(songText);
		}

		// changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(delta:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * delta;

		super.update(delta);
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
}
