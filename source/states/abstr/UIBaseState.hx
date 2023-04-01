package states.abstr;

import openfl.display.BitmapData;
import sys.io.File;
import states.substates.ModSelectionSubstate;
import flixel.FlxState;
import display.objects.Alphabet;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import display.objects.Notification;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

typedef UIBackgroudSettings =
{
	var enabled:Bool;
	var bgColor:FlxColor;
	@:optional var imageFile:String;
	@:optional var scrollFactor:Array<Float>;
	@:optional var bgColorGradient:Array<FlxColor>;
	@:optional var gradientChunks:Int;
	@:optional var gradientAngle:Int;
	@:optional var gradientMix:Float;
	@:optional var position:Array<Int>;
	@:optional var sizeMultiplier:Float;
}

class UIBaseState extends MusicBeatState
{
	var backgroundSettings:UIBackgroudSettings = {
		enabled: true,
		imageFile: "menuDesat",
		bgColor: 0xFFFDE871,
		scrollFactor: [0.5, 0.5]
	};

	var bg:FlxSprite;

    public static var menus:Map<String, FlxState> = [];

	private function createBackground(settings:UIBackgroudSettings):FlxSprite
	{
		var createdBG:FlxSprite;
		if (settings.imageFile != "") {
			createdBG = new FlxSprite(0, 0, Paths.image("menuDesat"));
			createdBG.color = settings.bgColor;
		} else {
			createdBG = new FlxSprite(0, 0);
			createdBG.makeGraphic(FlxG.width, FlxG.height, settings.bgColor);
		}

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
			// https://groups.google.com/g/haxeflixel/c/erHfhP1wy-s
			var thingy = FlxGradient.createGradientFlxSprite(Std.int(createdBG.width), Std.int(createdBG.height), settings.bgColorGradient,
			(settings.gradientChunks == null ? 1 : settings.gradientChunks), (settings.gradientAngle != null ? settings.gradientAngle : 90), true);
			thingy.blend = HARDLIGHT; // does this do anything with FlxSprite.stamp()? too lazy to test it
			thingy.alpha = (settings.gradientMix == null ? 0.5 : settings.gradientMix);

			createdBG.stamp(thingy);
        }

		return createdBG;
	}

	public static function switchState(state:Class<FlxState>, ?args:Array<Dynamic>, ?forceNew:Bool = false) {
		if (args == null) args = [];

		var name = Type.getClassName(state);

		// if (menus.exists(name) && !forceNew) {
		// 	FlxG.switchState(menus.get(name));
		// 	return;
		// }

		var newState = Type.createInstance(state, args);
		menus.set(name, newState);
		FlxG.switchState(newState);

	}

	private function showNotification(notif:Notification) {
		add(notif);

	}

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        if (backgroundSettings.enabled) {
		    this.bg = createBackground(backgroundSettings);
            insert(0, bg);
        }

		for (notification in Notification.notifications) { // persistance
			// showNotification(notification);
		}


		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.M)
			openSubState(new ModSelectionSubstate());

		if (FlxG.keys.justPressed.T) {
			var stupid = new FlxSpriteGroup();
			stupid.add(new Alphabet(0, Notification.NOTIFICATION_HEIGHT / 2, "this is a test lol", true, false));
			showNotification(new Notification(stupid, 2.5));
		}
		
		super.update(elapsed);
	}
}
