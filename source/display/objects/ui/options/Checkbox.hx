package display.objects.ui.options;

import flixel.FlxSprite;


class Checkbox extends FlxSprite {
    public var daValue(default, set):Bool = false;

    public function new(x:Int = 0, y:Int = 0, enabled:Bool = false) {
        super(x, y);
        frames = Paths.getSparrowAtlas("checkbox");
        animation.addByPrefix("static", "static", 24, false);
        animation.addByPrefix("checked", "selected", 24, false);
        antialiasing = true;
        setGraphicSize(Std.int(0.7 * width));
        updateHitbox();
        daValue = enabled;
    }

    function set_daValue(val:Bool) {
        if (val)
            animation.play("checked", true);
        else
            animation.play("static");
        return val;
    }

}