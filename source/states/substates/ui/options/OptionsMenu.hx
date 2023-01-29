package states.substates.ui.options;

import display.objects.ui.options.PageName;
import display.objects.ui.options.TextMenuList;
import display.objects.ui.options.Page;
import flixel.FlxState;
import flixel.util.FlxSignal.FlxTypedSignal;

class OptionsMenu extends Page {

    var items:TextMenuList;
    public var onEnterState:FlxTypedSignal<Void -> Void>;

    public function new() {
        super();
        items = new TextMenuList(Vertical);
        add(items);

        onEnterState = new FlxTypedSignal<Void -> Void>();

        createItem("controls", function() {
            onSwitch.dispatch(PageName.Controls);
        });
        createItem("preferences", function() {
            onSwitch.dispatch(PageName.Preferences);
        });
        createItem("exit", exit);
    }

    public function GPDoTHing() {
        onEnterState.dispatch();
    }

    override function update(elapsed:Float) {
        items.enabled = enabled;
        super.update(elapsed);
        items.forEach(function(item) {
            item.screenCenter(X);
            item.x -= item.width / 2;
        });
    }

    public function hasMultipleOptions() {
        return this.items.length > 2;
    }

    function createItem(name:String, callback:Dynamic, fireInstantly:Bool = true) {
        var cool = items.createItem(0, 100 + 100 * items.length, name, Bold, callback, fireInstantly);
        cool.screenCenter(X);
        cool.x -= cool.width / 2;
        return cool;
    }
}