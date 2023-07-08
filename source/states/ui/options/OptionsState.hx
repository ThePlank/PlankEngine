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
		for (category => options in Options.optionData) {
			var group:MenuList = new MenuList(0, 0, VERTICAL(false));
			group.focused = true;
			group.padding = 15;
			setupOptionGroup(cast options, group);
			add(group);
			group.screenCenter(X);
			var categoryOption:AtlasText = new AtlasText(0, 0, category, AtlasFont.Bold);
			categories.set(category, group);
			categoryGroup.add(categoryOption);
		}
		categoryGroup.y = barBottom.y + (barBottom.height / 2 - categoryGroup.height / 2);
		add(categoryGroup);
	}

	function setupOptionGroup(optionArray:Array<OptionEntry>, group:MenuList) {
		for (option in optionArray) {
			var atlasOption:AtlasText = new AtlasText(0, 0, option.displayName, AtlasFont.Bold);
			group.add(atlasOption);
		}
	}
}