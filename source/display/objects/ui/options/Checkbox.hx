package display.objects.ui.options;

import flixel.FlxSprite;


class Checkbox extends FlxSprite {
    public var daValue(default, set):Bool = false;

    public function new(x:Int = 0, y:Int = 0, enabled:Bool = false) {
        super(x, y);
        frames = Paths.getSparrowAtlas("checkbox");
        animation.addByPrefix("uncheck", "Check Box unselected", 24, true);
        animation.addByPrefix("select", "Check Box selecting animation", 24, false);
        animation.addByPrefix("selectStatic", "Check Box Selected Static", 24, true);
        antialiasing = true;
        // setGraphicSize(Std.int(0.7 * width));
        updateHitbox();
        daValue = enabled;
        animation.finishCallback = (name:String) -> {
            if (name == "select")
                animation.play("selectStatic", true);
        }
    }

    function set_daValue(val:Bool) {
        if (val)
            animation.play("select", true);
        else
            animation.play("uncheck");
        return val;
    }

}