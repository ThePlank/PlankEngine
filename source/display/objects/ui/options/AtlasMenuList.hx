package display.objects.ui.options;

import display.objects.ui.options.AtlasMenuItem;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;

class AtlasMenuList<T:AtlasMenuItem> extends MenuTypedList<T> {

    public var atlas:FlxAtlasFrames;

    public function new(atlas:String, nav:NavControls = Vertical, wrap:WrapMode) {
        super(nav, wrap);
        this.atlas = Paths.getSparrowAtlas(atlas);
    }
}