package display.objects.ui.options;

import classes.Controls.Device;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyList;

using StringTools;

class InputFormatter {

    static public var dirReg:EReg = new EReg("^(l|r).?-(left|right|down|up)$","");

    static public function format(key:Int, device:Device = Keys):String {
        switch (device) {
            case Keys:
                return getKeyName(key);
            case Gamepad(id):
                var gamepadKey = FlxG.gamepads.getByID(id).mapping.getInputLabel(key);
                return shortenButtonName(gamepadKey);
        }
        return "?";
    }

    static public function shortenButtonName(key):String {
            if (key == null) {
                key = "";
            }
            if (key == null)
                return "[?]";
            if (dirReg.match(key)) {
                key =  dirReg.matched(1).toUpperCase() + " ";
                var b = dirReg.matched(2);
                return key + (b.charAt(0).toUpperCase() + b.substr(1).toLowerCase());
            }
            return key.charAt(0).toUpperCase() + key.substr(1).toLowerCase();
    }
    
    static public function getKeyName(name:Int):String {
        switch (name) {
            case 8:
                return "BckSpc";
            case 17:
                return "Ctrl";
            case 18:
                return "Alt";
            case 20:
                return "Caps";
            case 33:
                return "PgUp";
            case 34:
                return "PgDown";
            case 48:
                return "0";
            case 49:
                return "1";
            case 50:
                return "2";
            case 51:
                return "3";
            case 52:
                return "4";
            case 53:
                return "5";
            case 54:
                return "6";
            case 55:
                return "7";
            case 56:
                return "8";
            case 57:
                return "9";
            case 96:
                return "#0";
            case 97:
                return "#1";
            case 98:
                return "#2";
            case 99:
                return "#3";
            case 100:
                return "#4";
            case 101:
                return "#5";
            case 102:
                return "#6";
            case 103:
                return "#7";
            case 104:
                return "#8";
            case 105:
                return "#9";
            case 106:
                return "#*";
            case 107:
                return "#+";
            case 109:
                return "#-";
            case 110:
                return "#.";
            case 186:
                return ";";
            case 188:
                return ",";
            case 190:
                return ".";
            case 191:
                return "/";
            case 192:
                return "`";
            case 219:
                return "[";
            case 220:
                return "\\";
            case 221:
                return "]";
            case 222:
                return "'";
            case 301:
                return "PrtScrn";
            default:
                return FlxKey.toStringMap.get(name);
        }
    }
}