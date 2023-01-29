package display.objects;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class TrackerAnchor {
    public static var TOP(default, null):FlxPoint = new FlxPoint(0.5, 1);
    public static var LEFT(default, null):FlxPoint = new FlxPoint(0, 0.5);
    public static var RIGHT(default, null):FlxPoint = new FlxPoint(1, 0.5);
    public static var BOTTOM(default, null):FlxPoint = new FlxPoint(0.5, 0);
    public static var CENTER(default, null):FlxPoint = new FlxPoint(0.5, 0.5);
}

class TrackedSprite extends flixel.FlxSprite {
    // public var anchor:FlxPoint = TrackerAnchor.RIGHT; todo
    public var tracker:FlxObject;
    public var padding:Int = 15;

    public function new(tracker:FlxObject, ?padding:Int) {
        this.tracker = tracker;
        if (padding != null)
            this.padding = padding;

        super();
    }

    override function update(elapsed:Float) {
        if (tracker != null) {
            scrollFactor.put();
            scrollFactor = tracker.scrollFactor.clone();
            var pos = new FlxPoint((tracker.x + tracker.width) + padding, (tracker.y + tracker.height) - (height / 2));
            setPosition(pos.x, pos.y);
        }
        // pos.scalePoint(anchor);
        super.update(elapsed);
    }
}