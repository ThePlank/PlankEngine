package display.objects;

import openfl.display.DisplayObject;
import openfl.display.Sprite;
import flixel.FlxSprite;

class FlxOFLSprite extends FlxSprite {
    private var _sprite:Sprite;

    public function new(?x:Int = 0, ?y:Int = 0) {
        _sprite = new Sprite();
        super(x, y);

    }

    public function add(item:DisplayObject) {
        return _sprite.addChild(item);
    }

    public function insert(item:DisplayObject, index:Int) {
        return _sprite.addChildAt(item, index);
    }

    public function remove(item:DisplayObject) {
        return _sprite.removeChild(item);
    }

    override function draw() {
        super.draw();

        pixels.draw(_sprite);
    }
}