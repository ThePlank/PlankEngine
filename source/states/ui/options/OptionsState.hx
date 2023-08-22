package states.ui.options;

import classes.PlayerSettings;
import classes.Controls;
import states.abstr.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal;
import flixel.util.FlxColor;
import classes.Options;
import flixel.group.FlxSpriteGroup;
import display.objects.ui.AtlasText;
import display.objects.ui.MenuList;
import display.objects.ui.options.Checkbox;
import states.abstr.UIBaseState;

// "make me a comment 👿" - Unholywanderer04 on July 8th, 2023 at 8:59

class OptionsState extends UIBaseState {
	
	private var categories:Map<String, FlxSpriteGroup> = [];

	override public function create() {
		backgroundSettings = {
			enabled: true,
			imageFile: "menuDesat",
			bgColor: 0xFFFD719B,
			scrollFactor: [0.5, 0.5]
		}
		super.create();
		trace('cumming');

		var barTop:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		barTop.alpha = (35 / 255);
		add(barTop);
		var barBottom:FlxSprite = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		barBottom.alpha = (35 / 255);
		add(barBottom);

		var descriptionText:FlxText = new FlxText(0, 0, FlxG.width, 'balls', 18);
		descriptionText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
		descriptionText.y = barTop.y + (barTop.height / 2 - descriptionText.height / 2);

		var categoryGroup:MenuList = new MenuList(0, 0, HORIZONTAL);
		categoryGroup.focused = true;
		categoryGroup.padding = 150;
		categoryGroup.canSelect = false;
		categoryGroup.moveWithCurSelection = true;
		for (category => options in Options.optionData) {
			var group:MenuList = new MenuList(0, 0, VERTICAL(false));
			group.focused = true;
			group.padding = 25;
			group.moveWithCurSelection = true;
			group.canSelect = true;
			group.onMove.add((sel) -> {
				var option:OptionEntry = (cast options)[sel];
				descriptionText.text = option.description;
			});
			group.onSelect.add((sel) -> {
				FlxG.sound.play(Paths.sound('confirmMenu'), 1);
				var option:OptionEntry = (cast options)[sel];
				switch(option.type) {
					case Bool:
						Options.setValue(option.entryName, !Options.getValue(option.entryName));
					default:
				}
			});
			setupOptionGroup(cast options, group);
			group.screenCenter();
			add(group);

			var categoryOption:AtlasText = new AtlasText(0, 0, category, AtlasFont.Bold);
			categories.set(category, group);
			categoryGroup.add(categoryOption);
		}
		
		categoryGroup.screenCenter(X);
		categoryGroup.y = barBottom.y + (barBottom.height / 2 - categoryGroup.height / 2);
		add(categoryGroup);

		add(descriptionText);
	}

	override public function update(delta:Float) {
		super.update(delta);

		if (controls.BACK)
			UIBaseState.switchState(MainMenuState);
	}

	function setupOptionGroup(optionArray:Array<OptionEntry>, group:MenuList) {
		for (option in optionArray) {
			var optionGroup:FlxSpriteGroup = new FlxSpriteGroup();
			var atlasOption:AtlasText = new AtlasText(0, 0, option.displayName, AtlasFont.Bold);
			optionGroup.add(atlasOption);
			switch (option.type) {
				case Bool:
					var check:Checkbox = new Checkbox(Std.int(atlasOption.width + 15), 0, option.entryName);
					check.y = atlasOption.height / 2 - check.height / 2;
					optionGroup.add(check);
				case Int | Float:
					var amenbreak:AtlasText = new AtlasText(Std.int(atlasOption.width + 15), 0, Std.string(Options.getValue(option.entryName)));
					amenbreak.y = atlasOption.height / 2 - amenbreak.height / 2;
					trace(amenbreak.text);
					optionGroup.add(amenbreak);
				default:
			}
			group.add(optionGroup);
		}
	}
}