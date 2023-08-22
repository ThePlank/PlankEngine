package states.abstr;

import flixel.util.FlxStringUtil;
import lime.system.System;

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

	private var metronomeEnabled:Bool = false;

	private var trackedObjects:Array<FlxBasic> = [];

	override function add(Object:FlxBasic):FlxBasic {
		trackedObjects.push(Object);
		return super.add(Object);
	}

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		FlxG.watch.add(this, 'curBeat', 'Current beat');
		FlxG.watch.add(this, 'curStep', 'Current step');
		FlxG.watch.add(Conductor, 'bpm', 'BPM');
		FlxG.watch.add(Conductor, 'songPosition', 'Song position');
		FlxG.watch.add(Conductor, 'crochet', 'Crochet');
		FlxG.watch.add(Conductor, 'offset', 'Offset');
		super.create();
	}

	override function update(delta:Float)
	{
		totalElapsed += delta;

		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(delta);
	}

	private function updateBeat():Void {
		curBeat = Math.floor(curStep / 4);
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
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{

		//do literally nothing dumbass


		if (!metronomeEnabled) return;

		var stupid:FlxSound = FlxG.sound.play(Paths.sound("metronomeTick"), 1);

		if (curBeat % 4 == 0)
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
