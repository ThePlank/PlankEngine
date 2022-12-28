package states;

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

class PlankSplash extends FlxState {

    private var flixel:Flixel;
    private var flixelGlow:GlowFilter;
    private var flixelLabel:TextField;
    private var flixelSound:FlxSound;

    override function create() {
        FlxG.autoPause = false;
        FlxG.mouse.visible = false;
        FlxG.fixedTimestep = false;

		#if FLX_KEYBOARD
		FlxG.keys.enabled = false;
		#end

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
        flixelTweenText.delay(0.05);

        var tween = Actuate.tween(plankLabel, 2, {x: plankLabel.x + FlxG.width / 2, alpha: 0});
        tween.ease(Expo.easeOut);

        new FlxTimer().start(2, (stupid) -> {
            #if FLX_KEYBOARD
            FlxG.keys.enabled = true;
            #end

            FlxG.switchState(new TitleState());
        });
    }
}