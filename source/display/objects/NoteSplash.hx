package display.objects;

import flixel.FlxG;
import flixel.FlxSprite;

// yes, this is stolen from week 7.

class NoteSplash extends FlxSprite {
    public function new(x:Int = 0, y:Int = 0, noteData:Int = 0) {

        super(x, y);

        frames = Paths.getSparrowAtlas('noteSplashes', 'shared');
        animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
        animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
        animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
        animation.addByPrefix("note3-0", "note impact 1 red", 24, false);
        animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
        animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
        animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
        animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
        setupNoteSplash(x, y, noteData);
    }

    public function setupNoteSplash(x:Int = 0, y:Int = 0, noteData:Int = 0) {
        setPosition(x, y);
        alpha = 0.6;
        animation.play("note" + noteData + "-" + FlxG.random.int(0, 1), 0);
        var curanim = animation.curAnim;
        curanim.frameRate = curanim.frameRate + FlxG.random.int(-2, 2);
        updateHitbox();
        offset.set(.3 * width, .3 * height);
    }
    
    override function update(elapsed:Float) {
        if (animation.curAnim.finished) {
            // clup penguin is
            kill();
        }

        super.update(elapsed);
    }
}