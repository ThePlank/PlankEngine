package states.abstr;

import flixel.system.FlxSound;
import haxe.io.Path;
import classes.Mod;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.FlxBasic;
import classes.Conductor;
import classes.PlayerSettings;
import classes.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import classes.Controls;

class MusicBeatState extends FlxUIState
{
	public var totalElapsed:Float = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	private var metronomeEnabled:Bool = true;

	private var trackedObjects:Array<FlxBasic> = [];

	override function add(Object:FlxBasic):FlxBasic {
		trackedObjects.push(Object);
		return super.add(Object);
	}

	override function switchTo(nextState:FlxState):Bool {
		for (basic in trackedObjects) {
			remove(basic);
		}
		return super.switchTo(nextState);
	}

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		totalElapsed += elapsed;

		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / Conductor.timeNumerator);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % Conductor.timeDenominator == 0)
			beatHit();
	}

	public function beatHit():Void
	{

		//do literally nothing dumbass


		if (!metronomeEnabled) return;

		var stupid:FlxSound = FlxG.sound.play(Paths.sound("metronomeTick"), 1);

		if (curBeat % Conductor.timeNumerator == 0)
			stupid.pitch = 1.2;
	}

	override function openSubState(SubState:FlxSubState) {
		persistentUpdate = false;
		persistentDraw = true;
		super.openSubState(SubState);
	}

	public function isModLoaded():Bool {
		return Mod.selectedMod != null;
	}
}
