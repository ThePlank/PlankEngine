package states.ui;

import states.abstr.MusicBeatState;
import states.abstr.UIBaseState;
import flixel.addons.ui.FlxInputText;
import flixel.FlxG;
import classes.Paths;
import classes.Mod;
import openfl.display.BitmapData;
import flixel.group.FlxGroup.FlxTypedGroup;
import display.objects.ui.Alphabet;

enum ModEditorStateState { // i dotn kno what to naenm this
	CREATING;
	EDITING(mod:Mod);
}

class ModEditorState extends UIBaseState { 
	var state:ModEditorStateState;
	var mod:Mod;

	var alphabetGroup:MenuList;
	var curSelected:Int = 0;

	private static var editors:Array<{name:String, ?state:flixel.FlxState}> = [
		{
			name: "character editor"
		},
		{
			name: "boobs"
		},
		{
			name: "boobs"
		},
		{
			name: "boobs"
		},
		{
			name: "boobs"
		},
		{
			name: "boobs"
		},
	];

	public function new(state:ModEditorStateState) {
		this.state = state;
		super();	
	}

	override function create() {
		backgroundSettings = {
			enabled: true,
			bgColor: 0xFFFFFFFF,
			bgColorGradient: [0xFF190423, 0xFF190311],
			gradientMix: 0.75,
			gradientChunks: 100,
			sizeMultiplier: 1.25,
			position: [-80, -80],
			imageFile: "menuDesat",
		}
		super.create();

		canOpenModMenu = false;
		Mod.selectedMod = null;

		FlxG.sound.playMusic(Paths.music('modEditor'));

		switch (state) {
			case CREATING:
				createCreateUI();
			case EDITING(mod):
				this.mod = mod;
				createEditorUI();
			default:
				// die
		}
	}

	function createEditorUI():Void {
		var logo:flixel.system.FlxAssets.FlxGraphicAsset = (mod.hasFile('images/logo.png') ? mod.getImage('logo.png') : Paths.image('noModLogo'));
		var myass:flixel.FlxSprite = flixel.util.FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 0.25), FlxG.height, [0xFF000000, 0x0], 1, 180, true);
		myass.alpha = 0.25;
		myass.x = FlxG.width - myass.width;
		add(myass);
		var logoSprite = new flixel.FlxSprite(0, 0, logo);
		logoSprite.x = FlxG.width - logoSprite.width - 25;
		logoSprite.screenCenter(Y);
		add(logoSprite);

		var modName:flixel.text.FlxText = new flixel.text.FlxText(-25, 50,  FlxG.width,  mod.modName, 24);
		modName.setFormat(Paths.font('vcr.ttf'), 32, flixel.util.FlxColor.WHITE, RIGHT);
		add(modName);

		var editMetadata:flixel.ui.FlxButton = new flixel.ui.FlxButton(0, FlxG.height * 0.85, "Edit Metadata", () -> {});
		editMetadata.x = FlxG.width - editMetadata.width - 25;
		add(editMetadata);

		var openLocationButton:flixel.ui.FlxButton = new flixel.ui.FlxButton(0, FlxG.height * 0.95, "Open Location", () -> {
			lime.system.System.openFile(mod.getPath('')); // dont ask
		});
		openLocationButton.x = FlxG.width - openLocationButton.width - 25;
		add(openLocationButton);

		alphabetGroup = new MenuList(50, 0, VERTICAL(true));
		alphabetGroup.focused = true;
		alphabetGroup.padding = 100;
		alphabetGroup.moveWithCurSelection = true;
		alphabetGroup.screenCenter(Y);
		add(alphabetGroup);

		for (editor in editors) {
			var modText:AtlasText = new AtlasText(0, ((70 * alphabetGroup.length) + 30), editor.name, AtlasFont.Bold);
            modText.scrollFactor.set();
            alphabetGroup.add(modText);
		}
	}

	function createCreateUI():Void {
		var group:flixel.group.FlxSpriteGroup = new flixel.group.FlxSpriteGroup();

		var title:flixel.text.FlxText = new flixel.text.FlxText(0, 0,  150 * 2,  'Mod Creation', 24);
		title.setFormat(Paths.font('vcr.ttf'), 24, flixel.util.FlxColor.WHITE, CENTER);
		group.add(title);

		var modName:flixel.text.FlxText = new flixel.text.FlxText(0, 100,  150,  'Mod Name:', 12);
		modName.setFormat(Paths.font('vcr.ttf'), 12, flixel.util.FlxColor.WHITE, LEFT);
		group.add(modName);

		var modNameInput:FlxInputText = new FlxInputText(150, 100, 150,  "my ass", 12);
		group.add(modNameInput);

		var modDescription:flixel.text.FlxText = new flixel.text.FlxText(0, 150,  150,  'Mod Description:', 12);
		modDescription.setFormat(Paths.font('vcr.ttf'), 12, flixel.util.FlxColor.WHITE, LEFT);
		group.add(modDescription);

		var modDescriptionInput:FlxInputText = new FlxInputText(150, 150, 150,  "my ass", 12);
		group.add(modDescriptionInput);

		var createButton:flixel.ui.FlxButton = new flixel.ui.FlxButton(0, 200, "Create", () -> {
			classes.Mod.createMod(Paths.formatToSongPath(modDescriptionInput.text), {
				name: modDescriptionInput.text,
				description: modDescriptionInput.text,
			});
			UIBaseState.switchState(ModEditorState, [EDITING(new Mod(Paths.formatToSongPath(modDescriptionInput.text)))]);
		});

		createButton.x = group.width / 2 - createButton.width / 2;

		group.add(createButton);

		var bg = new flixel.FlxSprite(-10, -10);
		bg.makeGraphic(Std.int(group.width + 20), Std.int(group.height + 20), flixel.util.FlxColor.BLACK);
		bg.alpha = 0.75;
		group.insert(0, bg);

		group.screenCenter();

		add(group);
	}

	override public function update(delta:Float) {
		super.update(delta);
		bg.offset.x = flixel.math.FlxMath.lerp(bg.offset.x, -(FlxG.mouse.screenX -  FlxG.width / 2) * 0.05, 0.12);
		bg.offset.y = flixel.math.FlxMath.lerp(bg.offset.y, -(FlxG.mouse.screenY - FlxG.height / 2) * 0.05, 0.12);

		var back = controls.BACK;

		if (back && state != CREATING)
			UIBaseState.switchState(TitleState);
	}
}