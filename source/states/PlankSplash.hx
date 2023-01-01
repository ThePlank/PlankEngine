package states;

import states.abstr.UIBaseState;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import motion.easing.Back;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import flixel.util.FlxColor;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import util.CoolUtil;
import flixel.system.FlxSound;
import flixel.system.FlxAssets;
import motion.easing.Expo;
import motion.Actuate;
import flixel.FlxG;
import display.objects.Flixel;
import openfl.display.Bitmap;
import flixel.FlxState;

class PlankSplash extends UIBaseState {

    private var flixel:Flixel;
    private var flixelLabel:TextField;
    private var skipLabel:TextField;
    private var flixelSound:FlxSound;

    var escapeTimer:Float = 0;

    override function create() {
        FlxG.autoPause = false;
        FlxG.mouse.visible = false;
        FlxG.fixedTimestep = false;

        backgroundSettings = {
            enabled: false,
            bgColor: 0x00000000
        }

		// #if FLX_KEYBOARD
		// FlxG.keys.enabled = false;
		// #end

        var window = CoolUtil.getMainWindow();

        flixel = new Flixel(true);
        // i fucking hate centering a object without FlxSprite.ScreenCenter();
        flixel.x = (window.width / 2) - (flixel.width / 2);
        flixel.y = (window.height / 2) - (flixel.height / 2);

        flixel.scaleX = 0;
        flixel.scaleY = 0;
        flixel.rotation = 180;
        FlxG.stage.addChild(flixel);

        flixelLabel = new TextField();
		flixelLabel.selectable = false;
		flixelLabel.embedFonts = true;
		var dtf = new TextFormat(FlxAssets.FONT_DEFAULT, 16, 0xFFFFFFFF);
		dtf.align = TextFormatAlign.CENTER;
		flixelLabel.defaultTextFormat = dtf;
		flixelLabel.text = "HaxeFlixel";
        flixelLabel.y = (window.height / 2) - (flixel.height / 2) + 125;
        flixelLabel.x = (window.width / 2) - (flixelLabel.width / 2);
        flixelLabel.alpha = 0;

        flixel.onPartChange.add((color:FlxColor) -> {
            flixelLabel.textColor = color;
        });

        skipLabel = new TextField();
		skipLabel.selectable = false;
		skipLabel.embedFonts = true;
		var dtfSkip = new TextFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF);
		dtfSkip.align = TextFormatAlign.LEFT;
		skipLabel.defaultTextFormat = dtf;
		skipLabel.text = "Skipping...";
        skipLabel.y = (window.height) - (32);
        skipLabel.alpha = 0;

		FlxG.stage.addChild(skipLabel);
		FlxG.stage.addChild(flixelLabel);

        // after tween height is 135
        var tween = Actuate.tween(flixel, 1, {scaleX: 1.35, scaleY: 1.35, rotation: 0});
        var tweenText = Actuate.tween(flixelLabel, 1.2, {alpha: 1});
        tweenText.ease(Expo.easeOut);
        tween.ease(Expo.easeOut);
        
		flixelSound = FlxG.sound.load(FlxAssets.getSound("flixel/sounds/flixel"));
        flixelSound.play();
        flixelSound.onComplete = plankPart;
        
        
        super.create();
    }

    private var plankSound:FlxSound;
    private var plankLabel:Bitmap;
    function plankPart() {

        var window = CoolUtil.getMainWindow();

        plankSound = FlxG.sound.load(Paths.sound("plankSplash"));
        plankSound.play();
        plankSound.onComplete = endPart;

        var flixelTween = Actuate.tween(flixel, 1, {x: flixel.x - 250});
        var flixelTweenText = Actuate.tween(flixelLabel, 1, {x: flixelLabel.x - 250});
        flixelTween.ease(Back.easeOut);
        flixelTweenText.ease(Back.easeOut);
        flixelTweenText.delay(0.05);

        var plankBitmap = Paths.image("plank");
        plankLabel = new Bitmap(plankBitmap.bitmap);
		FlxG.stage.addChild(plankLabel);

        plankLabel.x = (window.width / 2) - (flixel.width / 2) + FlxG.width / 2;
        plankLabel.y = (window.height / 2) - (flixel.height / 2);

        var tween = Actuate.tween(plankLabel, 1, {x: plankLabel.x - FlxG.width / 2});
        tween.ease(Back.easeOut);
    }

    function endPart() {
        var flixelTween = Actuate.tween(flixel, 2, {x: flixel.x - FlxG.width / 2, alpha: 0});
        var flixelTweenText = Actuate.tween(flixelLabel, 2, {x: flixelLabel.x - FlxG.width / 2, alpha: 0});
        flixelTween.ease(Expo.easeOut);
        flixelTweenText.ease(Expo.easeOut);
        flixelTween.delay(0.05);

        var tween = Actuate.tween(plankLabel, 2, {x: plankLabel.x + FlxG.width / 2, alpha: 0});
        tween.ease(Expo.easeOut);

        new FlxTimer().start(2, die);
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.pressed.ESCAPE)
            escapeTimer += 1;
        else
            escapeTimer = 0;

        if (escapeTimer >= 100)
            die();

        if (skipLabel != null)
            skipLabel.alpha = FlxMath.remapToRange(escapeTimer, 0, 100, 0, 1);

        super.update(elapsed);
    }

    function die(?stupid) {
        // #if FLX_KEYBOARD
        // FlxG.keys.enabled = true;
        // #end

        FlxG.stage.removeChild(flixel);
        flixel = null;
        FlxG.stage.removeChild(flixelLabel);
        FlxG.stage.removeChild(skipLabel);
        flixelLabel = null;
        skipLabel = null;

        if (plankLabel != null) {
            FlxG.stage.removeChild(plankLabel);
            plankLabel = null;
        }

        UIBaseState.switchState(TitleState);
    }
}