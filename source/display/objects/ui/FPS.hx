package display.objects.ui;

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
import openfl.display.Sprite;

class PlankFPS extends Sprite
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
	public var baseText:TextField;
	public var outlineTexts:Array<TextField> = [];
	private var outlineWidth:Int = 2;
	private var outlineQuality:Int = 8;
	var defaultTextFormat:TextFormat;

	public var text(get, set):String; 


	public function new(x:Float = 10, y:Float = 10)
	{
		super();

		this.x = x;
		this.y = y;

		this.defaultTextFormat = new TextFormat("VCR OSD Mono", 18, normalColor);

		baseText = new TextField();
		baseText.defaultTextFormat = this.defaultTextFormat;
		baseText.selectable = false;
		baseText.mouseEnabled = false;
		baseText.width = FlxG.width;

		currentFPS = 0;
		currentMemory = 0;
		maxMemory = 0;

		for (i in 0...outlineQuality) {
			var otext:TextField = new TextField();
			otext.x = Math.sin(i) *outlineWidth;
			otext.y = Math.cos(i) *outlineWidth;
			otext.defaultTextFormat = this.defaultTextFormat;
			otext.textColor = outlineColor;
			otext.width = baseText.width;
			otext.selectable = false;
			otext.mouseEnabled = false;
			outlineTexts.push(otext);
			addChild(otext);
		}

		addChild(baseText);

		text = "FPS: ";

	}

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		currentFPS = Math.floor(Math.max(1 / (deltaTime / 1000), 0)); // clamp the value so it doesent go to -2147483647 FPS

		var stats:{currentMemory:Float, totalAllocated:Float, allocationCount:Float} = hl.Gc.stats();
		currentMemory = stats.currentMemory;
		if (currentMemory > maxMemory)
			maxMemory = currentMemory;

		text = 'FPS: ${currentFPS}\n';
		text += 'MEM: ${FlxStringUtil.formatBytes(currentMemory)} / ${FlxStringUtil.formatBytes(maxMemory)}';

		#if (gl_stats && !disable_cffi && (!html5 || !canvas))
		text += "\ntotalDC: " + openfl.display._internal.stats.Context3DStats.totalDrawCalls();
		text += "\nstageDC: " + openfl.display._internal.stats.Context3DStats.contextDrawCalls(openfl.display._internal.stats.DrawCallContext.STAGE);
		text += "\nstage3DDC: " + openfl.display._internal.stats.Context3DStats.contextDrawCalls(openfl.display._internal.stats.DrawCallContext.STAGE3D);
		#end

		var mappedFPS = FlxMath.remapToRange(currentFPS, FlxG.drawFramerate, FlxG.drawFramerate, 0, 1);

		baseText.textColor = FlxColor.interpolate(normalColor, maxColor, FlxEase.cubeIn(mappedFPS));
	}

	private function set_text(value:String):String {
		baseText.text = value;
		for (text in outlineTexts) {
			text.text = value;
		}
		return value;
	}

	private function get_text():String 
		return baseText.text;
}
