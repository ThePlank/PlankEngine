package display.objects.ui.options;

import states.substates.ui.options.Prompt;
import classes.PlayerSettings;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSignal;

class Page extends FlxTypedGroup<Dynamic> {
    public var canExit = true;
    public var enabled = true;
    public var onExit:FlxSignal;
    public var onSwitch = new FlxTypedSignal<PageName->Void>();

    public function new(?maxItems:Int) {
        enabled = canExit = true;

        onExit = new FlxSignal();

        super(maxItems);
    }

    public function exit() {
        onExit.dispatch();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (enabled)
            updateEnabled(elapsed);
    }

    function openPrompt(prompt:Prompt, callback:()->Void) {
        enabled = false;
        prompt.closeCallback = function() {
            enabled = true;
            callback();
        }
        FlxG.state.openSubState(prompt);
    }

    function updateEnabled(elapsed:Float) {
        if (canExit && PlayerSettings.player1.controls.BACK)
            exit();
    }

    override function destroy() {
        super.destroy();
        // @:privateAccess FlxDestroyUtil.destroyArray(onSwitch);
    }
    
}