package display.objects.ui;

import flixel.FlxSprite;
import haxe.Exception;
import display.objects.game.Character.CharacterData;
import display.objects.game.Character;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var character:String = 'bf';
	public var isPlayer:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		character = char;
		this.isPlayer = isPlayer;
		try {
			doStuff();
		} catch(ex:Exception) {
			character = 'bf';
			doStuff();
		}
	}

	function doStuff() {
		var image = Paths.image(Paths.getPath('characters/$character/icon.png'));
		if (image == null) throw 'Missing icon';
		loadGraphic(image, true, 150, 150);
		var data:CharacterData = Character.getCharData(character);

		antialiasing = data.antialias;
		animation.add('normal', [0], 0, false, isPlayer);
		animation.add('losing', [1], 0, false, isPlayer);
		animation.play('normal');
		scrollFactor.set();
	}

	override function update(delta:Float)
	{
		super.update(delta);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
