package states.abstr;

import states.substates.ModSelectionSubstate;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

typedef UIBackgroudSettings =
{
	var enabled:Bool;
	var bgColor:FlxColor;
	@:optional var scrollFactor:Array<Float>;
	@:optional var bgColorGradient:Array<FlxColor>;
	@:optional var gradientChunks:Int;
	@:optional var position:Array<Int>;
	@:optional var sizeMultiplier:Float;
}

class UIBaseState extends MusicBeatState
{
	var backgroundSettings:UIBackgroudSettings = {
		enabled: true,
		bgColor: 0xFFFDE871,
		scrollFactor: [0.5, 0.5]
	};

	var bg:FlxSprite;

	private function createBackground(settings:UIBackgroudSettings):FlxSprite
	{
		var createdBG:FlxSprite = new FlxSprite(0, 0, Paths.image("menuDesat"));
		createdBG.color = settings.bgColor;

		if (settings.scrollFactor != null)
			createdBG.scrollFactor.set(settings.scrollFactor[0], settings.scrollFactor[1]);

		if (settings.position != null)
			createdBG.setPosition(settings.position[0], settings.position[1]);

		if (settings.sizeMultiplier != null)
            createdBG.setGraphicSize(Std.int(createdBG.width * settings.sizeMultiplier));

        createdBG.updateHitbox();
		createdBG.screenCenter();
		createdBG.antialiasing = true;

		if (settings.bgColorGradient != null) {
            FlxGradient.overlayGradientOnFlxSprite(createdBG, Std.int(createdBG.width), Std.int(createdBG.height), settings.bgColorGradient, 0, 0,
                (settings.gradientChunks != null ? settings.gradientChunks : 0), 90, true);
        }

		return createdBG;
	}

	override public function create()
	{
        if (backgroundSettings.enabled == true) {
		    this.bg = createBackground(backgroundSettings);
            insert(0, bg);
        }

		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.M)
			openSubState(new ModSelectionSubstate());
		
		super.update(elapsed);
	}
}
