package display.objects.ui.options;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

class AtlasMenuItem extends MenuItem {
    public var atlas:FlxAtlasFrames;

    public function new(x:Int = 0, y:Int = 0, name:String = "yesz", atlas:FlxAtlasFrames) {
        frames = atlas;
        this.atlas = atlas;
        super(x, y, name, callback);
    }

    override function setData(name:String = "", ?callback:Dynamic) {
        frames = atlas;
        animation.addByPrefix("idle", "" + name + " idle", 24);
        animation.addByPrefix("selected", "" + name + " selected", 24);
        super.setData(name, callback);
    }

    function changeAnim(anim) {
        animation.play(anim);
        updateHitbox();
    }

    override function idle() {
        changeAnim("idle");
    }

    override function select() {
        changeAnim("selected");
    }

    override function get_selected():Bool {
        if (animation.curAnim == null) return false;

        if (animation.curAnim.name == "selected")
            return true;
        else
            return false;

        return false;
    }
}