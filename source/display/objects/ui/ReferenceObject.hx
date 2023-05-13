package display.objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;


/**
 * Just a little helper object that i use when i make UI's.
 */
class ReferenceObject extends FlxSprite {
    
    override function graphicLoaded() {
        super.graphicLoaded();
        scrollFactor.set();
        visible = false;
    }

    override function update(delta:Float) {
        super.update(delta);
        // i know this is a bit unnececary, but in case of something being added after create; make it always on top
        // Look ma! no cameras!
        if (FlxG.state.members.indexOf(this) != FlxG.state.members.length && FlxG.state.members.indexOf(this) != -1) {
            FlxG.state.members.unshift(this);
        }

        if (FlxG.keys.justPressed.SHIFT)
            visible = !visible;

        if (FlxG.keys.pressed.CONTROL && Math.abs(FlxG.mouse.wheel) > 0)
            alpha += FlxG.mouse.wheel * 0.25;
    }
}