package display.objects.ui.options;

import flixel.FlxSprite;
import flixel.text.FlxText;

class TextTypedMenuItem extends MenuItem {

    @:isVar public var label(default, set):AtlasText; 

    public function new(X:Int = 0, Y:Int = 0, label:AtlasText, name:String = "", ?callback:Dynamic) {
        super(X, Y, name, callback);

        this.label = label;

    }

    public function setEmptyBackground() {
        var WidthBeforeDisaster = width;
        var HeightBeforeDisaster = height;
        makeGraphic(1,1,0); // disaster
        width = WidthBeforeDisaster;
        height = HeightBeforeDisaster;
    }

    public function set_label(thing:AtlasText) {
        if (thing != null) {
            thing.x = this.x;
            thing.y = this.y;
            thing.alpha = this.alpha;
        }
        return this.label = thing;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (label != null)  {
            label.update(elapsed);
            label.alpha = alpha;
            label.x = x;
            label.y = y;
        }
    }

    override function draw() {
        super.draw();

        if (label != null) {
            label.cameras = cameras;
            var labelScroll = label.scrollFactor;
            var itemScroll = scrollFactor;
            labelScroll.set(itemScroll.x, itemScroll.y);
            itemScroll.putWeak();
            label.draw();
        }
    }
}