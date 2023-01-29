package states.substates.ui.options;

import util.CoolUtil;
import classes.Options;
import display.objects.ui.options.Checkbox;
import display.objects.ui.options.AtlasText;
import display.objects.ui.options.TextMenuList;
import display.objects.ui.options.Page;
import flixel.util.FlxColor;
import openfl.Lib;
import Type.ValueType;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxObject;
import haxe.ds.Map;

class PreferencesMenu extends Page
{
	var checkboxes:Array<Checkbox> = [];
	var textBoxes:Array<AtlasText> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	public function new()
	{
		super();
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor.alpha = 0;
		camera = menuCamera;
		items = new TextMenuList();
		items.camera = menuCamera;
		add(items);
		createPrefItem("Downscroll", "downscroll");
		createPrefItem("Ghost Tapping", "ghostTapping");
		createPrefItem("flashing menu", "flashingMenu");
		createPrefItem("Camera Zooming on Beat", "camZoom");
		createPrefItem("Auto Pause", "autoPause");
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.members[items.selectedIndex].y;
		menuCamera.follow(camFollow, LOCKON, 0.06);
		menuCamera.deadzone.x = -100;
		menuCamera.deadzone.y = 160;
		menuCamera.deadzone.width = menuCamera.width;
		menuCamera.deadzone.height = 40;
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item)
		{
			camFollow.y = item.y;
			// trace(camFollow.y);
		});
		onExit.add(() -> {
			Options.save();
		});
	}

	static public function preferenceCheck(name:String)
	{
		if (Options.initSetting(name))
		{
			trace("set preference! " + Std.string(Options.getValue(name)));
		}
	}

	function createPrefItem(name:String, internalName:String)
	{
        preferenceCheck(internalName);
		var type:ValueType = Type.typeof(Options.getValue(internalName));
		items.createItem(130, 120 * items.length + 30, name, Bold, function()
		{
			switch (type.getName())
			{
				case "TBool":
					prefToggle(internalName);
				case "TInt":
				// FlxG.state.openSubState();
				default:
					trace("swag");
			}
		}, true);

		switch (type.getName())
		{
			case "TBool":
				createCheckbox(internalName);
			case "TInt":
				createTextbox(internalName);
			default:
				trace("swag");
		}

		trace(type.getName());
	}

	// function openValueChanger(value:)

	function prefToggle(name:String)
	{
		if (!Type.typeof(Options.getValue(name)).equals(TBool))
			return;

		menuCamera.zoom += 0.15;

		// how to evade typechecking:
		var daBool:Bool = cast Options.getValue(name);

		Options.setValue(name, !daBool);
		checkboxes[items.selectedIndex].daValue = daBool;
		trace("toggled? " + Std.string(daBool));

		switch (name)
		{
			case "autoPause":
				FlxG.autoPause = Options.getValue("autoPause");
			case "fps-counter":
				// Main.instance.fpsCounter.visible = getPref("fps-counter");
		}
	}

	function createCheckbox(name:String)
	{
		var check = new Checkbox(10, 120 * (this.items.length - 1), Options.getValue(name));
		checkboxes.push(check);
		check.camera = menuCamera;
		add(check);
	}

	function createTextbox(name:String)
	{
		var text = new AtlasText(20, 125 * (this.items.length - 1), Std.string(Options.getValue(name)), Default);
		textBoxes.push(text);
		text.camera = menuCamera;
		add(text);
	}

	static public function getPref(name:String):Any
	{
		return Options.getValue(name);
	}

	static public function setPref(name:String, value:Any)
	{
		return Options.setValue(name, value);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.1);

		menuCamera.zoom = CoolUtil.coolLerp(menuCamera.zoom, 1, 0.055);
		items.forEach(function(item)
		{
			items.members[items.selectedIndex] == item ? item.x = 150 : item.x = 130;
		});
	}
}
