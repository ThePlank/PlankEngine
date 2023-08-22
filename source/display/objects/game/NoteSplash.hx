package display.objects.game;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Path;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int = 0):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('notes/splashes');

		animation.addByPrefix('note0', 'note splash purple', 24, false);
		animation.addByPrefix('note1', 'note splash blue', 24, false);
		animation.addByPrefix('note2', 'note splash green', 24, false);
		animation.addByPrefix('note3', 'note splash red', 24, false);

		setupNoteSplash(x, y, noteData);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0)
	{
		setPosition(x, y);
		alpha = 0.6;

		animation.play('note$noteData', true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		updateHitbox();

		offset.set(width * 0.35, height * 0.35); // todo: add mr beast
	}

	override function update(delta:Float)
	{
		if (animation.curAnim.finished)
			/*clup penguin is*/ kill();

		super.update(delta);
	}
}