package display.objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteGroup;
import flixel.FlxObject;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class Notification extends FlxSpriteGroup {
    public static final NOTIFICATION_HEIGHT:Int = 200;
    public static final NOTIFICATION_WIDTH:Int = 400;
    public static final NOTIFICATION_PADDING:Int = 5;
    public static final NOTIFICATION_TIMEBAR_HEIGHT:Int = 10;

    public static var notifications:Array<Notification> = [];
    public var timeBar:FlxBar;
    public var timer:FlxTimer;
    public var body:FlxSpriteGroup;

    function makeBackground() {
        var bg = new FlxSprite();
        trace(width);
        bg.makeGraphic( Std.int(body.width), NOTIFICATION_HEIGHT, 0x84000000);
        bg.updateHitbox();

        return bg;
    }

    function makeTimebar() {
        var bar = new FlxBar(0, NOTIFICATION_HEIGHT - NOTIFICATION_TIMEBAR_HEIGHT, FlxBarFillDirection.LEFT_TO_RIGHT, Std.int(body.width), NOTIFICATION_TIMEBAR_HEIGHT, timer, "progress", 0, 1, false);
        bar.createGradientFilledBar([0xFF4a2e00, 0xFF644816], 1, 0, false);
        bar.createColoredEmptyBar(0x00000000, false);

        return bar;
    }

    public function new(body:FlxSpriteGroup, time:Float) {
        super(FlxG.width, 0);
        scrollFactor.set();
		notifications.push(this);
        this.body = body;
        add(makeBackground());
        timer = new FlxTimer();
        timeBar = makeTimebar();
        add(timeBar);
        add(body);
        FlxG.sound.load(Paths.sound("notification")).play();
		FlxTween.tween(this, {x: FlxG.width - width}, 0.7, {ease: FlxEase.sineInOut, onComplete: function(stupid) {
            timer.start(time, timerEnd);
        }});
    }

    function timerEnd(stupid) {
        FlxTween.tween(this, {x: FlxG.width + width}, 0.7, {ease: FlxEase.sineInOut, onComplete: function(stupid) {
            notifications.remove(this);
            destroy();
        }});
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);

		y = FlxMath.lerp(y, FlxG.height - (Notification.NOTIFICATION_HEIGHT + Notification.NOTIFICATION_PADDING) * (Math.abs(notifications.indexOf(this)) + 1), 0.4);
    }
}