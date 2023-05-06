package states;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.FlxGame;
import openfl.geom.Rectangle;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxState;
import display.objects.ScrollableSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import haxe.CallStack;
import haxe.Exception;
import flixel.ui.FlxButton;

@:access(flixel.FlxCamera)
class UnexpectedCrashState extends FlxState {
    var exceptionStack:String;
    var error:String;
    var fetus:String;

    var buttons:Map<String, ()->Void> = [
        'Return to main menu' => () -> states.abstr.UIBaseState.switchState(MainMenuState),
    ];

    public function new(e:Dynamic, stack:CallStack) {
        super();
        exceptionStack = CallStack.toString(stack);
        error = try Std.string(e) catch(_:Exception) "Unknown";
        fetus = Main.saveCrash(error, stack, 'handled');
        buttons.set('Open crash report', () -> lime.system.System.openFile(fetus)); // diediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediediedie
    }

    override function create() {
        super.create();

        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound("unhandledError"));

        var bg = new FlxSprite(0, 0);
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
        add(bg);
        var halftone = new FlxBackdrop(Paths.image('halftonedots'), X);
        halftone.velocity.x = -10;
        halftone.y = FlxG.height - halftone.height;
        halftone.setColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
        add(halftone);

        FlxG.camera.zoom = 1.5;
        flixel.tweens.FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: flixel.tweens.FlxEase.expoOut, startDelay: 0.1});
        FlxG.camera.flash(FlxColor.RED);

        var errorScrollable:ScrollableSprite = new ScrollableSprite(0, -FlxG.height * 0.5, FlxG.width, FlxG.height * 0.75);
        var text:FlxText = new FlxText(0,  FlxG.height * 0.05, FlxG.width, error, 32);
        text.alignment = CENTER;
        errorScrollable.add(text);
        var text:FlxText = new FlxText(0,  FlxG.height * 0.05 + 32 + 16, FlxG.width, exceptionStack, 24);
        text.alignment = CENTER;
        errorScrollable.add(text);
        add(errorScrollable);
        flixel.tweens.FlxTween.tween(errorScrollable, {y: FlxG.height * 0.05}, 1, {ease: flixel.tweens.FlxEase.expoOut, startDelay: 0.25});
        var stupid:Int = 1;
        for (text => callback in buttons) {
            trace((FlxG.width * stupid)  * 0.1);
            var butt:FlxButton = new FlxButton((FlxG.width  * 0.1) + (FlxG.width  * (0.5 + stupid)), FlxG.height * 0.9, text, callback);
            butt.scale.x = 2;
            butt.updateHitbox();
            butt.label.fieldWidth = butt.width;
            add(butt);
            stupid++;
        }
    }
}