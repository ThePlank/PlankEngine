package display.objects;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.io.Path;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int = 0):Void
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('noteSplashes');

		animation.addByPrefix('note1', 'note splash blue 1', 24, false);
		animation.addByPrefix('note2', 'note splash green 1', 24, false);
		animation.addByPrefix('note0', 'note splash purple 1', 24, false);
		animation.addByPrefix('note3', 'note splash red 1', 24, false);

		setupNoteSplash(x, y, noteData);

		// alpha = 0.75;
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0)
	{
		setPosition(x, y);
		alpha = 0.6;

		animation.play('note' + noteData, true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();

		offset.set(width * 0.3, height * 0.3); // todo: add mr beast
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}