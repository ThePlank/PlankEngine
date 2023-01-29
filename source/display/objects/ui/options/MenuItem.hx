package display.objects.ui.options;

import flixel.FlxSprite;

class MenuItem extends FlxSprite {

    public var fireInstantly:Bool = false;
    public var name:String = "i forgor";
    public var callback:Dynamic;
    @:isVar public var selected(get, never) = false;

    public function new(X:Int = 0, Y:Int = 0, name:String = "", ?callback:Dynamic) {
        super(X, Y);
        antialiasing = true;
        setData(name, callback);
    }

    public function setData(name:String = "", ?callback:Dynamic) {
        this.name = name;
        if (callback != null)
            this.callback = callback;
    }

    public function setItem(name:String = "", ?callback:Dynamic) {
        setData(name, callback);

        if (selected)
            select();
        else
            idle();
    }
    
    public function idle() {
        alpha = 0.6;
    }

    public function select() {
        alpha = 1;
    }

    public function get_selected() {
        return alpha == 1;
    }
}