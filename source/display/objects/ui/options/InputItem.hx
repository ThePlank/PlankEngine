package display.objects.ui.options;

import classes.Controls;
import classes.PlayerSettings;
import flixel.input.keyboard.FlxKey;

class InputItem extends TextMenuItem {
    public var input:Int;
    public var index:Int;
    public var control:Control;
    public var device:Device;

    public function new(x:Int = 0, y:Int = 0, device:Device, control:Control, index:Int = -1, Callback:Dynamic) {
        this.input = this.index = -1;
        this.device = device;
        this.control = control;
        this.index = index;
        this.input = getInput();


        super(x, y, getLabel(input), Default, Callback);
    }

    public function updateDevice(device) {
        if (device != this.device) {
            this.device = device;
            this.input = getInput();
            this.label.text = getLabel(input);
        }
    }

    public function getInput() {
        var inputShid:Array<Int> = PlayerSettings.player1.controls.getInputsFor(this.control, this.device);
        if (this.index < inputShid.length) {
            if (inputShid[index] != 27 || inputShid[index] != 6)
                return inputShid[index];
            if (inputShid.length > 2)
                return inputShid[2];
        }
        return -1;
    }

    public function getLabel(coolInput) {
        if (coolInput == -1) 
            return "---";

        var corn:String = InputFormatter.format(coolInput, device);

        return corn;
    }
}