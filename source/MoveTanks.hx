
package;

import flixel.FlxG;
import flixel.FlxSprite;

class MoveTanks extends FlxSprite
{
public static var curStage:String = '';
var tankGround:BGSprite;

var tankX:Float = 400;
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankAngle:Float = FlxG.random.int(-90, 45);

function moveTank(?elapsed:Float = 0):Void
	{

			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
	}
}