package states.ui;

import openfl.filters.ShaderFilter;
import display.shaders.ShutterEffect;
import states.ui.options.OptionsState;
import classes.Mod;
import states.abstr.UIBaseState;
#if (discord_rpc || hldiscord)
import classes.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends UIBaseState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	// var optionShit:Array<String> = ['story mode', 'freeplay', 'donate'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if (discord_rpc || hldiscord)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}

		persistentUpdate = persistentDraw = true;

		backgroundSettings = {
			enabled: true,
			bgColor: 0xFFFDE871,
			position: [0, -80],
			scrollFactor: [0, 0.18],
			sizeMultiplier: 1.1,
		}

		super.create();

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = createBackground({
			enabled: true,
			bgColor: 0xFFfd719b,
			position: [0, -80],
			scrollFactor: [0, 0.18],
			sizeMultiplier: 1.1,
		});
		magenta.visible = false;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		// ill update this to be automatic but balls
		var versionShit:FlxText = new FlxText(5, 0, 0, 'Plank Engine v0.1\n${classes.macros.Version.version()}\nBase Game v${Application.current.meta.get('version')}', 12);
		versionShit.y = FlxG.height - versionShit.height - 5;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		// var notifGroup = new flixel.group.FlxSpriteGroup();
		// var text = new FlxText(0, 15, display.objects.ui.Notification.NOTIFICATION_WIDTH, 'A new Plank Engine version has released!');
		// text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// notifGroup.add(text);
		// var notif = new display.objects.ui.Notification(notifGroup, 25);
		// showNotification(notif);

	}

	var selectedSomethin:Bool = false;

	override function update(delta:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.fadeIn(0.5, FlxG.sound.music.volume, 0.8);
		}

		if (FlxG.keys.justPressed.H)
			throw "guh????";

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				UIBaseState.switchState(TitleState);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										UIBaseState.switchState(StoryMenuState);
										trace("Story Menu Selected");
									case 'freeplay':
										LoadingState.loadAndSwitchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										FlxG.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
		}

		super.update(delta);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
