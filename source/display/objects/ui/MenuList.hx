package display.objects.ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.math.FlxMath;
import classes.PlayerSettings;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;

enum ListDirection {
	VERTICAL(curved:Bool);
	HORIZONTAL;
}

class MenuList extends FlxTypedSpriteGroup<FlxSprite> {
	public var direction:ListDirection;
	public var curSelection:Int;

	public var focused:Bool = false;
	public var canSelect:Bool;

	public var onMove:FlxTypedSignal<(Int)->Void>;
	public var onSelect:FlxTypedSignal<(Int)->Void>;

	public var padding:Int;
	public function new(x:Int, y:Int, direction:ListDirection) {
		super(x, y);
		this.direction = direction;
		onMove = new FlxTypedSignal<(Int)->Void>();
		onSelect = new FlxTypedSignal<(Int)->Void>();
	}

	override public function update(delta:Float) {
		super.update(delta);
		var curPos:FlxPoint = FlxPoint.get();
		forEach((spr) -> {
			var index:Int = members.indexOf(spr);
			switch (direction) {
				case VERTICAL(false):
					spr.y = curPos.y;

				case VERTICAL(true):
					
				case HORIZONTAL:
					spr.x = curPos.x;
			}
			curPos.x += spr.width + padding;
			curPos.y += spr.height + padding;
		});
		curPos.put();

		if (!focused)
			return;

		switch (direction) {
			case VERTICAL(true) | VERTICAL(false):
				if (PlayerSettings.player1.controls.UI_UP_P)
					changeSelection(-1);
				if (PlayerSettings.player1.controls.UI_DOWN_P)
					changeSelection(1);
			case HORIZONTAL:
				if (PlayerSettings.player1.controls.UI_LEFT_P)
					changeSelection(-1);
				if (PlayerSettings.player1.controls.UI_RIGHT_P)
					changeSelection(1);
		}
	}

	function changeSelection(sel:Int) {
		curSelection += sel;
		curSelection = Std.int(FlxMath.bound(curSelection, 0, members.length));
		onMove.dispatch(curSelection);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
}