package states;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.Bitmap;
import flixel.FlxGame;
import openfl.geom.Rectangle;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.FlxState;

class UnexpectedCrashState extends FlxState {
    var oldState:Bitmap;
    
    public function new() {
        // take a quick grab of the state before switching to the state
        var rect = new Rectangle();
        var game:FlxGame = Main.get().game;
        rect.x = game.x;
        rect.y = game.y;
        rect.width = game.width;
        rect.height = game.height;

        oldState = FlxScreenGrab.grab(rect, false, false); 
        super();
    }

    override function create() {
        super.create();

        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound("unhandledError"));

        var oldStateBg = new FlxSprite(0, 0, oldState.bitmapData);
        add(oldStateBg);
    }
}