package display.objects.ui.options;

import classes.PlayerSettings;
import classes.Controls;
import display.objects.ui.options.NavControl;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import haxe.ValueException;
import haxe.ds.Map;
import flixel.util.FlxSignal;
import flixel.group.FlxGroup.FlxTypedGroup;

class MenuTypedList<T:MenuItem> extends FlxTypedGroup<T> {

    public var busy:Bool = false;
    public var byName:Map<String, T> = new Map<String, T>();
    public var wrapMode:WrapMode = Both;
    public var navControls:NavControl = Vertical;
    public var enabled:Bool = true;
    public var onAcceptPress:FlxSignal = new FlxSignal();
    public var onChange:FlxTypedSignal<T->Void> = new FlxTypedSignal<T->Void>();
    public var selectedIndex:Int = 0;

    public function new(nav:NavControl = Vertical, ?wrap:WrapMode) {
        navControls = nav;
        if (wrap != null)
            wrapMode = wrap;
        else {
            switch(nav) {
                case Horizontal:
                    wrap = Horizontal;
                case Vertical:
                    wrap = Vertical;
                default:
                    wrap = Both;
            }
        }
        super();
    }

    public function addItem(name:String, item:T) {
        if (this.selectedIndex == this.length)
            item.select();
        byName.set(name, item);
        add(item);
        return item;
    }

    public function resetItem(key:String, newName:String, callback:Dynamic) {
        if (!byName.exists(key))
            throw new ValueException("No item named: " + key + "!!!!!!!!!");
        var dick = byName.get(key);
        if (byName.exists(key))
            byName.remove(key);
        byName.set(newName, dick);
        dick.setItem(newName, callback);
        return dick;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);



        if (enabled && !busy) {

            var idk:Bool = true;
            var idk2:Bool = true;
            var forgor:Int;
            var controlss:Controls = PlayerSettings.player1.controls;

            switch(wrapMode.getIndex()) {
                case 0:
                case 2:
                    idk = true;
                default:
                    idk = false;
            }

            switch(wrapMode.getIndex()) {
                case 1:
                case 2:
                    idk2 = true;
                default:
                    idk2 = false;
            }

            switch(navControls) {
                case Horizontal:
                    forgor = navAxis(selectedIndex, length, controlss.UI_LEFT_P, controlss.UI_RIGHT_P, idk);
                case Vertical:
                    var e = controlss.UI_UP_P;
                    var d = controlss.UI_DOWN_P;
                    forgor = navAxis(selectedIndex, length, e, d, idk2);
                case Both:
                    var e = controlss.UI_LEFT_P || controlss.UI_UP_P;
                    var d = controlss.UI_RIGHT_P || controlss.UI_DOWN_P;
                    forgor = navAxis(selectedIndex, length, e, d, this.wrapMode.getIndex() != 3);
                case Columns(num):
                    forgor = navGrid(num, controlss.UI_LEFT_P, controlss.UI_RIGHT_P, idk, controlss.UI_UP_P, controlss.UI_DOWN_P, idk2);
                case Rows(num):
                    forgor = navGrid(num, controlss.UI_UP_P, controlss.UI_DOWN_P, idk2, controlss.UI_LEFT_P, controlss.UI_RIGHT_P, idk);
            }

            if (selectedIndex != forgor) {
                FlxG.sound.play(Paths.sound("scrollMenu"));
                selectItem(forgor);
            }

            if (controlss.ACCEPT)
                accept();


        }

    }

    function accept() {
        var item:MenuItem = cast(members[selectedIndex], MenuItem);
        // if (item.callback == null) return;
        onAcceptPress.dispatch();
        if (item.fireInstantly) {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            item.callback();
        } else {
            busy = true;
            FlxG.sound.play(Paths.sound("confirmMenu"));
            FlxFlicker.flicker(item, 1, 0.06, true, false, function(bruh) {
                busy = false;
                item.callback();
            });
        }
    }

    function selectItem(thing) {
        members[selectedIndex].idle();
        selectedIndex = thing;
        var newSelect:T = members[selectedIndex];
        newSelect.select();
        onChange.dispatch(newSelect);
    }


    function navAxis(a, b, c, d, e) {
		if (c == d) return a;
		c ? 0 < a ? --a : if (e) a = b - 1 : a < b - 1 ? ++a : if (e) a = 0;
		return a;
    }

    function navGrid(a, b, c, d, e, f, h):Int {
        var m = Math.ceil(length / a);
        var n = Math.floor(selectedIndex / a);
        var k = selectedIndex % a;
        var l = navAxis(k, a, b, c, d);
        var z = navAxis(n, m, e, f, h);
        return Std.int(Math.min(length - 1, z * a + l)) | 0;
    }
}