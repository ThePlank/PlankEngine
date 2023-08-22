package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.display.Shape;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

// todo: refactor some of the code,
// maybe change the volume change sound;
// fix the sound tray not showing up on some resolutions (specifically when getting close to 1:1?)

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{

	public var active:Bool;

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;
	
	var volumeText:TextField;
	var bg:Bitmap;
	public var pussy:Shape;

	var _height:Int = 50;

	public function new()
	{
		super();

		bg = new Bitmap(new BitmapData(1, _height, true, 0x7F000000));
		bg.scaleX = FlxG.stage.window.width;
		addChild(bg);

		volumeText = new TextField();
		volumeText.width = FlxG.stage.window.width;
		volumeText.y = 10;
		volumeText.x = 10;
		volumeText.multiline = false;
		volumeText.wordWrap = false;
		volumeText.selectable = false;

		var dtf:TextFormat = new TextFormat('VCR OSD Mono', 20, 0xffffff);
		dtf.align = TextFormatAlign.LEFT;
		volumeText.defaultTextFormat = dtf;
		addChild(volumeText);
		volumeText.text = "0%";

		pussy = new Shape();
		addChild(pussy);

		titties = new FlxTimer();

		y = FlxG.stage.window.height;

		redrawBar();
		pussy.y = _height - pussy.height;

		FlxG.stage.window.onResize.add((w, h) -> {
			bg.scaleX = w;
			volumeText.width = FlxG.stage.window.width;
			redrawBar();
			x = -FlxG.game.x;
		});
	}

	public var barThickness:Int = 5;
	public var barHeight:Int = 15;

	public function redrawBar() {
		// outline
        pussy.graphics.clear();
        pussy.graphics.beginFill(0x000000);
        pussy.graphics.drawRect(0, 0, FlxG.stage.window.width, barHeight);
        pussy.graphics.endFill();

        // fill
        pussy.graphics.beginFill(0xFFFFFF);
        pussy.graphics.drawRect(barThickness, barThickness, (FlxG.stage.window.width - barThickness * 2) * (FlxG.sound.volume * (FlxG.sound.muted ? 0 : 1)), barHeight - barThickness * 2);
        pussy.graphics.endFill();

	}

	public function screenCenter() {
		// :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 :3 
	}

	public var balls:Float;
	public var boobs:FlxTween;
	public var titties:FlxTimer;

	public function update(delta:Float):Void
		y = FlxMath.lerp(FlxG.stage.window.height, FlxG.stage.window.height - _height, balls);

	public function show(up:Bool = false):Void {
		boobs?.cancel();
		boobs = FlxTween.num(balls, 1, 1, {ease: FlxEase.expoOut}, v -> balls = v);

		titties.start(1.5, (tmr) -> {
			boobs?.cancel();
			boobs = FlxTween.num(balls, 0, 1, {ease: FlxEase.expoOut, onComplete: (twn) -> {
				active = visible = false;
				if (FlxG.save.isBound) {
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
					FlxG.save.flush();
				}
			}}, v -> balls = v);
		});

		if (!silent)
		{
			var sound = Paths.sound('cowbell');
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		volumeText.text = '${Math.round(FlxG.sound.volume * 100) * (FlxG.sound.muted ? 0 : 1)}%';
		redrawBar();

		active = visible = true;
	}
}
#end
