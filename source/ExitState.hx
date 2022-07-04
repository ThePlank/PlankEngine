import flixel.*;
import flash.system.System;

class ExitState extends FlxState
{
	public function new()
	{
		super();
		closeGame();
	}

	public function closeGame()
	{
		System.exit(0);
	}
}
// CLoses the game without jumpscares
