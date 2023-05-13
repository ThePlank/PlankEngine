package display.objects.ui;

import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import openfl.display.Sprite;
import flixel.util.FlxTimer;

import openfl.display.Graphics;

class Flixel extends Sprite
{
	private static var times:Array<Float> = [0.041, 0.184, 0.334, 0.495, 0.636];
	private static var colors:Array<FlxColor> = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];

	private var functions:Array<Void->Void>;
	private var curPart:Int = 0;
	public var onPartChange:FlxTypedSignal<FlxColor -> Void> = new FlxTypedSignal<FlxColor -> Void>();

	public function new(animate:Bool = false)
	{
		super();

		functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

        if (animate)
            this.animate();
        else
            for (fun in functions)
                fun();
	}

	public function animate(){
        for (time in times) {
            new FlxTimer().start(time, timerCallback);
        }
	}

	function timerCallback(Timer:FlxTimer):Void
	{
		functions[curPart]();
		onPartChange.dispatch(colors[curPart]);
		curPart++;
	}

	function drawGreen():Void
	{
		graphics.beginFill(0x00b922); //https://cdn.discordapp.com/attachments/1083070583245373564/1086191612780097616/speed.gif
		graphics.moveTo(0, -37);
		graphics.lineTo(1, -37);
		graphics.lineTo(37, 0);
		graphics.lineTo(37, 1);
		graphics.lineTo(1, 37);
		graphics.lineTo(0, 37);
		graphics.lineTo(-37, 1);
		graphics.lineTo(-37, 0);
		graphics.lineTo(0, -37);
		graphics.endFill();
	}

	function drawYellow():Void
	{
		graphics.beginFill(0xffc132);
		graphics.moveTo(-50, -50);
		graphics.lineTo(-25, -50);
		graphics.lineTo(0, -37);
		graphics.lineTo(-37, 0);
		graphics.lineTo(-50, -25);
		graphics.lineTo(-50, -50);
		graphics.endFill();
	}

	function drawRed():Void
	{
		graphics.beginFill(0xf5274e);
		graphics.moveTo(50, -50);
		graphics.lineTo(25, -50);
		graphics.lineTo(1, -37);
		graphics.lineTo(37, 0);
		graphics.lineTo(50, -25);
		graphics.lineTo(50, -50);
		graphics.endFill();
	}

	function drawBlue():Void
	{
		graphics.beginFill(0x3641ff);
		graphics.moveTo(-50, 50);
		graphics.lineTo(-25, 50);
		graphics.lineTo(0, 37);
		graphics.lineTo(-37, 1);
		graphics.lineTo(-50, 25);
		graphics.lineTo(-50, 50);
		graphics.endFill();
	}

	function drawLightBlue():Void
	{
		graphics.beginFill(0x04cdfb);
		graphics.moveTo(50, 50);
		graphics.lineTo(25, 50);
		graphics.lineTo(1, 37);
		graphics.lineTo(37, 1);
		graphics.lineTo(50, 25);
		graphics.lineTo(50, 50);
		graphics.endFill();
	}
}
