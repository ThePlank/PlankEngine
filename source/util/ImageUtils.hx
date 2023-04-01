package util;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class ImageUtils
{
	static public function drawInsideBorder(data:BitmapData, width:Int, color:FlxColor)
	{
		data.lock();

		// LEFT
		var leftRect = new Rectangle(0, 0, width, data.height);
		data.fillRect(leftRect, color);

		// TOP
		var topRect = new Rectangle(0, 0, data.width, width);
		data.fillRect(topRect, color);

		// RIGHT
		var rightRect = new Rectangle(data.width - width, 0, width, data.height);
		data.fillRect(rightRect, color);

		// BOTTOM
		var bottomRect = new Rectangle(0, data.height - width, data.width, width);
		data.fillRect(bottomRect, color);

		data.unlock();

		return data;
	}

	static public function getAverageColor(data:BitmapData):FlxColor {
		var color:Int = 0;

		for (y in 0...data.height) {
			for (x in 0...data.width) {
				color += data.getPixel(x, y);
			}
		}

		color = Std.int(color / (data.width * data.height));
		return FlxColor.fromInt(color);
	}
}