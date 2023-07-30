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
	public var moveDirection:FlxPoint;
	public var direction:ListDirection;
	public var curSelection:Int;
	public var groupOffset:FlxPoint = FlxPoint.get();

	public var moveWithCurSelection:Bool = false;
	public var focused:Bool = false;
	public var canSelect:Bool = true;

	public var onMove:FlxTypedSignal<(Int)->Void>;
	public var onSelect:FlxTypedSignal<(Int)->Void>;

	public var padding:Int;
	public function new(x:Int, y:Int, direction:ListDirection) {
		super(x, y);
		this.direction = direction;
		this.moveDirection = FlxPoint.get();
		switch (direction) {
			case VERTICAL(false):
				moveDirection.x = 0;
				moveDirection.y = 1;
			case VERTICAL(true):
				moveDirection.x = 0.05;
				moveDirection.y = 1;
			case HORIZONTAL:
				moveDirection.x = 1;
				moveDirection.y = 0;
		}
		onMove = new FlxTypedSignal<(Int)->Void>();
		onSelect = new FlxTypedSignal<(Int)->Void>();
	}

	override public function update(delta:Float) {
		super.update(delta);
		var curPos:FlxPoint = FlxPoint.get();
		forEach((spr) -> {
			var index:Int = members.indexOf(spr);
			spr.x = x + curPos.x;
			spr.y = y + curPos.y;
			if (index == curSelection && moveWithCurSelection) 
				groupOffset.set(curPos.x, curPos.y);
			curPos.x += (spr.width + padding) * moveDirection.x;
			curPos.y += (spr.height + padding) * moveDirection.y;
		});
		curPos.put();
		offset.x = FlxMath.lerp(offset.x, groupOffset.x,  0.16);
		offset.y = FlxMath.lerp(offset.y, groupOffset.y, 0.16);

		if (!focused)
			return;

		var isHorizontal = (moveDirection.x == 1);

		if (isHorizontal) {
			if (PlayerSettings.player1.controls.UI_LEFT_P)
				changeSelection(-1);
			if (PlayerSettings.player1.controls.UI_RIGHT_P)
				changeSelection(1);
		} else {
			if (PlayerSettings.player1.controls.UI_UP_P)
				changeSelection(-1);
			if (PlayerSettings.player1.controls.UI_DOWN_P)
				changeSelection(1);
		}

		if (PlayerSettings.player1.controls.ACCEPT && canSelect)
			onSelect.dispatch(curSelection);
	}

	function changeSelection(sel:Int) {
		curSelection += sel;
		curSelection = Std.int(FlxMath.wrap(curSelection, 0, members.length - 1));
		onMove.dispatch(curSelection);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		forEach((spr) -> {
			var index:Int = members.indexOf(spr);
			if (index == curSelection)
				spr.alpha = 1;
			else
				spr.alpha = 0.6;
		});
	}
}