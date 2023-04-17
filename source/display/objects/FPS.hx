package display.objects;

import flixel.util.FlxStringUtil;
import openfl.Lib;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import openfl.Memory;
import lime.system.System;
import openfl.text.TextFormat;
import openfl.text.TextField;

class PlankFPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	private var currentMemory:Float;
	private var maxMemory:Float;

	private var maxColor:FlxColor = 0xFFEC5454;
	private var normalColor:FlxColor = 0xFF000000;
	private var outlineColor:FlxColor = 0xFFFFFFFF;
	public var outlineTexts:Array<TextField> = [];
	private var outlineWidth:Int = 2;
	private var outlineQuality:Int = 8;


	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		currentMemory = 0;
		maxMemory = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 18, normalColor);
		width = 250;
		text = "FPS: ";

		for (i in 0...outlineQuality) {
			var otext:TextField = new TextField();
			otext.x = x + Math.sin(i) *outlineWidth;
			otext.y = y + Math.cos(i) *outlineWidth;
			otext.defaultTextFormat = this.defaultTextFormat;
			otext.textColor = outlineColor;
			otext.width = this.width;
			outlineTexts.push(otext);
		}

	}

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		currentFPS = Math.floor(1 / (deltaTime / 1000));

		text = 'FPS: ${currentFPS}\n';

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
		text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
		text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
		#end

		currentMemory = 0;
		if (currentMemory > maxMemory)
			maxMemory = currentMemory;

		text += 'MEM: ${FlxStringUtil.formatBytes(currentMemory)}\n';
		text += 'MEM MAX: ${FlxStringUtil.formatBytes(maxMemory)}\n';

		// 4000MB = 4GB, max memory usage of Windows
		var mappedMemory = FlxMath.remapToRange(currentMemory, 0, 4000, 0, 1);
		var mappedFPS = FlxMath.remapToRange(currentFPS, Lib.current.stage.frameRate, Lib.current.stage.frameRate / 2, 0, 1);

		textColor = FlxColor.interpolate(normalColor, maxColor, FlxEase.cubeIn((mappedMemory + mappedFPS) / 2));
	}

	@:noCompletion override private function set_text(value:String):String {
		for (text in outlineTexts) {
			text.text = value;
		}
		return super.set_text(value);
	}
}
