package states.ui;

import openfl.Lib;
#if hlvideo
import display.objects.HashlinkVideo.Video;
#end
import flixel.util.FlxGradient;
import sys.FileSystem;
import flixel.group.FlxSpriteGroup;
import display.objects.ui.Notification;
import flixel.ui.FlxButton;
import openfl.filters.ShaderFilter;
import display.shaders.ColorSwap;
import flixel.addons.display.FlxBackdrop;
import openfl.display.BitmapData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import display.objects.ui.ScrollableSprite;
import haxe.xml.Fast;
import display.objects.ui.Flixel;
import haxe.Json;
import classes.Mod;
import states.abstr.UIBaseState;
import classes.Options;
import classes.Conductor;
import classes.Highscore;
import classes.PlayerSettings;
import display.objects.ui.Alphabet;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import states.abstr.MusicBeatState;
import display.objects.ui.AtlasText;
import flixel.util.FlxAxes;

using StringTools;

class TitleState extends UIBaseState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var settings:{bpm:Int, rgbEnabled:Bool, bgImage:String,
	backdrop:{enabled:Bool, axes:Array<Bool>, velocity:Array<Int>, image:String, alpha:Float},
	gf:{position:Array<Int>, antialiasing:Bool},
	logo:{position:Array<Int>, antialiasing:Bool},
	titleText:{position:Array<Int>, antialiasing:Bool}} = Json.parse(Paths.getTextFromFile("data/freakyMenu.json"));

	var curWacky:Array<String> = [];

	override public function create():Void
	{
		backgroundSettings = {
			imageFile: settings.bgImage
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT
		trace('yes?: ${Options.getValue("Yes")}');

		super.create();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		UIBaseState.switchState(FreeplayState);
		#elseif CHARTING
		UIBaseState.switchState(ChartingState);
		#else
		startIntro();
		#end

		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
	}

	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var stupid:ColorSwap;
	//var outline:display.shaders.OutlineShader;
	var thingy:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var backdrop:FlxBackdrop;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = Paths.image("square");
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			// FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.7, new FlxPoint(-1, 0), {asset: diamond, width: 32, height: 32},
				// new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			// FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.7, new FlxPoint(1, 0),
				// {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			
				// FlxTransitionableState.defaultTransOut.tweenOptions.ease = FlxEase.quartOut;
				// FlxTransitionableState.defaultTransIn.tweenOptions.ease = FlxEase.circOut;

			// transIn = FlxTransitionableState.defaultTransIn;
			// transOut = FlxTransitionableState.defaultTransOut;
		}

		Conductor.bpm = settings.bpm;

		persistentUpdate = true;

		if (settings.backdrop.enabled) {
			var grid:FlxGraphic = Paths.image(settings.backdrop.image);
			var axes:FlxAxes = FlxAxes.fromBools(settings.backdrop.axes[0], settings.backdrop.axes[1]);
			backdrop = new FlxBackdrop(grid, axes);
			if (axes == X) backdrop.y = FlxG.height - backdrop.height;
			backdrop.alpha = settings.backdrop.alpha;
			backdrop.velocity.set(settings.backdrop.velocity[0], settings.backdrop.velocity[1]);
			add(backdrop);
		}

		logo = new FlxSprite(settings.logo.position[0], settings.logo.position[1]);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.antialiasing = settings.logo.antialiasing;
		add(logo);

		gfDance = new FlxSprite(settings.gf.position[0], settings.gf.position[1]);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = settings.gf.antialiasing;
		add(gfDance);
		
		stupid = new ColorSwap();
		var filter:ShaderFilter = new ShaderFilter(stupid.shader);
		if (settings.rgbEnabled) FlxG.camera.setFilters([filter]);

		titleText = new FlxSprite(settings.titleText.position[0], settings.titleText.position[1]);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.antialiasing = settings.titleText.antialiasing;
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxG.mouse.visible = true;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		#if hlvideo
		var video = new Video();
		video.loadPath("D:/Documents/hlvideotest/res/Untitledav1.mkv");
		video.scale.x = (FlxG.width / 256);
		video.scale.y = (FlxG.height / 144);
		video.updateHitbox();
		add(video);
		#end
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(delta:Float)
	{
		if (!initialized)
			return;

		if (FlxG.keys.pressed.LEFT)
			stupid.update(-delta * 0.15);

		if (FlxG.keys.pressed.RIGHT)
			stupid.update(delta * 0.15);

		Conductor.songPosition = FlxG.sound?.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, (tmr:FlxTimer) ->
			{
				UIBaseState.switchState(MainMenuState);
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(delta);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:AtlasText = new AtlasText(0, 0, textArray[i], AtlasFont.Bold);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:AtlasText = new AtlasText(0, 0, text, AtlasFont.Bold);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();
		danceLeft = !danceLeft;

		logo?.animation.play('bump');
		gfDance?.animation.play((danceLeft ? 'danceLeft' : 'danceRight'));

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				add(ngSpr);
			case 8:
				deleteCoolText();
				remove(ngSpr);
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
