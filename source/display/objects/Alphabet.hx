package display.objects;

import util.CoolUtil.FPSLerp;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import display.objects.ui.AtlasText;

using StringTools;

enum AlphabetAlignment {
	LEFT;
	MIDDLE;
	RIGHT;
}

/**
 * AtlasText but worse
 */
@:deprecated('Does this work the same as Alphabet? Yes. Is it alphabet? no. Should you use this? no.')
class Alphabet extends AtlasText
{
	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;
	public var alignmenrt:AlphabetAlignment = RIGHT;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, ?typed:Bool = false)
	{
		super(x, y, text, (bold ? AtlasFont.Bold : AtlasFont.Default));
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var point:FlxPoint = getNormalizedPosition();

			x = FPSLerp.lerp(x, point.x, 0.16);
			y = FPSLerp.lerp(y, point.y, 0.16);
			point.putWeak();
		}

		super.update(elapsed);
	}

	// i don't know if i should use "normalized", but fuck it.
	public function getNormalizedPosition():FlxPoint {
		var point:FlxPoint = FlxPoint.get();

		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		switch (alignmenrt) {
			case MIDDLE:
				point.y = (scaledY * 120) + (FlxG.height * 0.48);
				point.x = (FlxG.width / 2) - (width / 2);
			default:
				point.y = (scaledY * 120) + (FlxG.height * 0.48);
				point.x = (targetY * 20) + 90;
			
		}

		return point;
	}
}

// typedef Alphabet = display.objects.ui.AtlasText;