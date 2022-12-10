package states.substates;

import flixel.util.FlxColor;
import flixel.FlxG;
import classes.Mod;
import states.substates.abstr.MusicBeatSubstate;
import flixel.group.FlxGroup.FlxTypedGroup;
import display.objects.Alphabet;

class ModSelectionSubstate extends MusicBeatSubstate
{
	public static var mods:Array<Mod> = [];

	var alphabetGroup:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var selected:Bool = false;

	public function new()
	{
		mods = Mod.getAvalibleMods();
		super(0x60000000);
	}

	override function create()
	{
		super.create();

        alphabetGroup = new FlxTypedGroup<Alphabet>();
        add(alphabetGroup);

		var i:Int = 0;
		for (mod in mods)
		{
			var modText:Alphabet = new Alphabet(0, (70 * i) + 30, mod.modName, true, false);
			modText.isMenuItem = true;
			modText.targetY = i++;
            modText.scrollFactor.set();
            alphabetGroup.add(modText);
		}

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

        if (selected) return;

		if (upP)
			changeSelection(-1);

		if (downP)
			changeSelection(1);

		if (accepted) {
            selected = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4);
            FlxG.sound.music.fadeOut(0.4, 0, (bween) -> {
                Mod.selectedMod = mods[curSelected];
                Mod.selectedMod.initMod();
                FlxG.resetState();
            });
        }

        if (back)
            close();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = alphabetGroup.length - 1;
		if (curSelected >= alphabetGroup.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in alphabetGroup.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
