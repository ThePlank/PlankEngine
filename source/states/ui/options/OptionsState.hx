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

// "make me a comment 👿" - Unholywanderer04 on July 8th, 2023 at 8:59

class OptionsState extends states.abstr.UIBaseState {
	
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

		var categoryGroup:MenuList = new MenuList(0, 0, HORIZONTAL);
		categoryGroup.focused = true;
		categoryGroup.padding = 150;
		categoryGroup.canSelect = false;
		for (category => options in Options.optionData) {
			var group:MenuList = new MenuList(0, 0, VERTICAL(false));
			group.focused = true;
			group.padding = 25;
			setupOptionGroup(cast options, group);
			add(group);
			group.screenCenter();
			group.moveWithCurSelection = true;
			group.canSelect = true;
			var categoryOption:AtlasText = new AtlasText(0, 0, category, AtlasFont.Bold);
			categories.set(category, group);
			categoryGroup.add(categoryOption);
		}
		var categoryOption:AtlasText = new AtlasText(0, 0, 'my balls', AtlasFont.Bold);
		categoryGroup.add(categoryOption);
		categoryGroup.screenCenter(X);
		categoryGroup.y = barBottom.y + (barBottom.height / 2 - categoryGroup.height / 2);
		categoryGroup.moveWithCurSelection = true;
		add(categoryGroup);
	}

	function setupOptionGroup(optionArray:Array<OptionEntry>, group:MenuList) {
		for (option in optionArray) {
			var atlasOption:AtlasText = new AtlasText(0, 0, option.displayName, AtlasFont.Bold);
			group.add(atlasOption);
		}
	}
}