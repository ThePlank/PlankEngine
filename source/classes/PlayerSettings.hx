package classes;

import classes.Controls.KeyboardScheme;
import haxe.Json;
import lime.tools.Keystore;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings
{
	static public var numPlayers(default, null) = 0;
	static public var numAvatars(default, null) = 0;
	static public var player1(default, null):PlayerSettings;
	static public var player2(default, null):PlayerSettings;

	#if (haxe >= "4.0.0")
	static public final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	static public final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	#else
	static public var onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	static public var onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	#end

	public var id(default, null):Int;

	#if (haxe >= "4.0.0")
	public final controls:Controls;
	#else
	public var controls:Controls;
	#end

	// public var avatar:Player;
	// public var camera(get, never):PlayCamera;

	function new(id:Int, scheme:KeyboardScheme)
	{
		this.id = id;
		this.controls = new Controls('player$id', None);

		var useDefault:Bool = true;
		var controlSave = FlxG.save.data.controls;
		
		if (controlSave != null) {
			var keysToUse = null;
			if (id == 0 && controlSave.p1 != null && controlSave.p1.keys != null)
				keysToUse = controlSave.p1.keys;
			else if (id == 1 && controlSave.p2 != null && controlSave.p2.keys != null)
				keysToUse = controlSave.p2.keys;
			if (keysToUse != null) 
				useDefault = false;
			trace("loaded key data: " + Json.stringify(keysToUse));
			trace("Use default?: " + useDefault);

			controls.fromSaveData(keysToUse, Keys);	
		}

		if (useDefault)
			setKeyboardScheme(Solo);
	}

	public function setKeyboardScheme(scheme)
	{
		controls.setKeyboardScheme(scheme);
	}

	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0, Solo);
			++numPlayers;
		}

		FlxG.gamepads.deviceConnected.add(onGamepadAdded);
	}

	static function onGamepadAdded(gpad) {
		player1.addGamepad(gpad);
	}

	public function addGamepad(pad) {
		var useDefault:Bool = true;
		var controlSave = FlxG.save.data.controls;
		
		if (controlSave != null) {
			var keysToUse = null;
			if (id == 0 && controlSave.p1 != null && controlSave.p1.pad != null)
				keysToUse = controlSave.p1.pad;
			else if (id == 1 && controlSave.p2 != null && controlSave.p2.pad != null)
				keysToUse = controlSave.p2.pad;
			if (keysToUse != null) 
				useDefault = true;
			trace("loaded pad data: " + Json.stringify(keysToUse));

			controls.addGamepadWithSaveData(pad.id, keysToUse);	
		}

		if (useDefault)
			controls.addDefaultGamepad(pad.id);
	}

	public function saveControls() {
		var playerOneControls = null;
		if (FlxG.save.data.controls == null)
			FlxG.save.data.controls = {};

		if (id == 0) {
			if (FlxG.save.data.controls.p1 == null)
				FlxG.save.data.controls.p1 = {};
			playerOneControls = FlxG.save.data.controls.p1;
		} else {
			if (FlxG.save.data.controls.p2 == null)
				FlxG.save.data.controls.p2 = {};
		}

		var controlsSaveKeys = controls.createSaveData(Keys);
		if (controlsSaveKeys != null) {
			playerOneControls.keys = controlsSaveKeys;
			FlxG.save.data.controls.p1 = playerOneControls;
			trace("saving key data: " + Json.stringify(controlsSaveKeys));
		}

		if (controls.gamepadsAdded.length > 0) {
			controlsSaveKeys = controls.createSaveData(Gamepad(controls.gamepadsAdded[0]));
			if (controlsSaveKeys != null) {
				trace("saving pad data: " + Json.stringify(controlsSaveKeys));
				playerOneControls.pad = controlsSaveKeys;
				FlxG.save.data.controls.pad = controlsSaveKeys;
			}
		}
		FlxG.save.flush();
	}

	static public function reset()
	{
		player1 = null;
		player2 = null;
		numPlayers = 0;
	}
}