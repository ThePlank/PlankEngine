package states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends abstracts.MusicBeatState
{
	public static var leftState:Bool = false;
	var plankLogo:FlxSprite;

	public static var version:String = "69.420.0";
	public static var changelog:Array<String> = ["beans"];

	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('week54prototype', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		plankLogo = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('PlankEngineLogo'));
		plankLogo.scale.y = 0.3;
		plankLogo.scale.x = 0.3;
		plankLogo.x -= plankLogo.frameHeight;
		plankLogo.y -= 100;
		plankLogo.antialiasing = FlxG.save.data.antialiasing;
		add(plankLogo);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			'Plank engine is out of date!\nYour PLE version is ${MainMenuState.plankEngineVer}, but the newest version is ${version}.\n\nChangelog:\n', 32);

		for (i in changelog) {
			txt.text += '${i}\n';
		}

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);
	}

	var totalElapsed = 0.0;

	override function update(elapsed:Float)
	{
		totalElapsed += elapsed;
		if (controls.ACCEPT && MainMenuState.nightly == "")
		{
			fancyOpenURL("https://github.com/ThePlank/PlankEngine/tree/main/docs/changelogs" + version);
		}
		else if (controls.ACCEPT)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}

		plankLogo.y = (-100 + Math.sin(totalElapsed * 4) * 5);

		super.update(elapsed);
	}
}
