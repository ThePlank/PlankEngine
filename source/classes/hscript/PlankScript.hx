package classes.hscript;

import display.objects.Alphabet;
import display.objects.Character;
import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

// TODO: make this class
class PlankScript {
    public static var parser:Parser = new Parser();
    public static var scripts:Array<PlankScript> = [];

    var source:String;
    var expression:Expr;
    public var interp:Interp;

    public var variables(get, null):Map<String, Dynamic>;

    public function new(code:String) {
        this.source = code;
        this.interp = new Interp();
        expression = parser.parseString(source);
        setupVariables();
    }

    private function setupVariables() {
        interp.variables.set('FlxG', FlxG);
		interp.variables.set('FlxSprite', FlxSprite);
		interp.variables.set('FlxCamera', FlxCamera);
		interp.variables.set('FlxTimer', FlxTimer);
		interp.variables.set('FlxTween', FlxTween);
		interp.variables.set('FlxEase', FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Mod', Mod);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('sendMessage', function(value:Array<Dynamic>)
		{
			sendMessage(value);
		});
    }

    public function sendMessage(value:Array<Dynamic>) {
        for (script in scripts)
            script.callFunction("onMessage", value);
    }

    public function callFunction(functionName:String, arguments:Array<Dynamic>) {
        @:privateAccess
        var callReturn:Dynamic = interp.fcall(expression, functionName, arguments);
        
        return callReturn;
    }

	function get_variables():Map<String, Dynamic> {
		return interp.variables;
	}
}