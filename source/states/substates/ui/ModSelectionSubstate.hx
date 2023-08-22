package states.substates.ui;

import flixel.FlxSprite;
import display.objects.ui.ReferenceObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import classes.Mod;
import states.substates.abstr.MusicBeatSubstate;
import flixel.group.FlxGroup.FlxTypedGroup;
import display.objects.ui.Alphabet;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import states.abstr.UIBaseState;
import states.ui.ModEditorState;

class ModSelectionSubstate extends MusicBeatSubstate
{
	public static var mods:Array<Mod> = [];

	private var buttonMeta:Array<{name:String, clickCallback:Void->Void}> = [];

	var buttonGroup:flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup<flixel.ui.FlxButton>;
	var alphabetGroup:MenuList;
	var curSelected:Int = 0;
	var selected:Bool = false;

	public function new()
	{
		mods = Mod.getAvalibleMods();
		mods.push(null); // null = no mod

		buttonMeta.push({name: "import", clickCallback: () -> {}});
		buttonMeta.push({name: "edit", clickCallback: () -> {
			UIBaseState.switchState(ModEditorState, [EDITING(mods[alphabetGroup.curSelection])]);
		}});
		buttonMeta.push({name: "delete", clickCallback: () -> {}});
		buttonMeta.push({name: "add", clickCallback: () -> {
			UIBaseState.switchState(ModEditorState, [CREATING]);
		}});

		super(0x60000000);
	}

	override function create()
	{
		super.create();

		alphabetGroup = new MenuList(50, 0, VERTICAL(true));
		alphabetGroup.scrollFactor.set();
		alphabetGroup.focused = true;
		alphabetGroup.padding = 100;
		alphabetGroup.moveWithCurSelection = true;
		alphabetGroup.screenCenter(Y);
		alphabetGroup.onSelect.add((sel) -> {
			selected = true;
            FlxG.camera.fade(FlxColor.BLACK, 0.4);
            FlxG.sound.music.fadeOut(0.4, 0, (bween) -> {
            	FlxG.sound.music.stop();
            	FlxG.sound.music.destroy();
				if (mods[sel] == null) {
					Mod.selectedMod = null;
					Mod.reset();
					FlxG.resetState();
					return;
				}
                Mod.selectedMod = mods[sel];
                Mod.selectedMod.initMod();
                FlxG.resetState();
            });
		});

		add(alphabetGroup);

        buttonGroup = new FlxTypedSpriteGroup<flixel.ui.FlxButton>();
        add(buttonGroup);

		var i:Int = 0;
        for (butt in buttonMeta) {
        	var buttonGraphic = classes.Paths.image('mods/buttons/${butt.name}');
        	var elButt = new flixel.ui.FlxButton(FlxG.width - 50 - (5 * i) - buttonGraphic.width - buttonGroup.width, FlxG.height * 0.75, butt.name, butt.clickCallback);
        	elButt.label.kill();
        	elButt.loadGraphic(buttonGraphic);
        	buttonGroup.add(elButt);
            elButt.scrollFactor.set();
        	i++;
        }
        i = 0;
		for (mod in mods) {
			var modText:AtlasText = new AtlasText(0, (70 * i) + 30, (mod != null ? mod.modName : "No Mod"), AtlasFont.Bold);
            alphabetGroup.add(modText);
		}
	}

	override function update(delta:Float)
	{
		super.update(delta);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

        if (selected) return;

		if (FlxG.keys.justPressed.T)
			openSubState(new PopupSubState(Ok, Regular, Text("This is a substate of a substate!")));

		if (FlxG.keys.justPressed.Y)
			openSubState(new PopupSubState(Ok, Error, Text("Whoops! You have to put your CD in your computer")));

        if (back)
            close();
	}
}
