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

	@:noCompletion private var currentMemory:Float;
	@:noCompletion private var maxMemory:Float;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	private var maxColor:FlxColor = 0xFFEC5454;
	private var normalColor:FlxColor = 0xFFFFFFFF;

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

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = 'FPS: ${currentFPS}\n';

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			currentMemory = openfl.system.System.totalMemory;
			if (currentMemory > maxMemory)
				maxMemory = currentMemory;

            text += 'MEM: ${FlxStringUtil.formatBytes(currentMemory)}\n';
            text += 'MEM MAX: ${FlxStringUtil.formatBytes(maxMemory)}\n';

			// 4000MB = 4GB, max memory usage of Windows
			var mappedMemory = FlxMath.remapToRange(currentMemory, 0, 4000, 0, 1);
			var mappedFPS = FlxMath.remapToRange(currentFPS, Lib.current.stage.frameRate, Lib.current.stage.frameRate / 2, 0, 1);

			textColor = FlxColor.interpolate(normalColor, maxColor, FlxEase.cubeIn((mappedMemory + mappedFPS) / 2));
		}

		cacheCount = currentCount;
	}
}
