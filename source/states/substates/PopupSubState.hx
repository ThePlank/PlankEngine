package states.substates;

// someone remind me to finnish and customise this
// this is from a unfinnished project

import util.ImageUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSignal;

enum PopupButtons
{
	YesNo;
	OkCancel;
	Ok;
	Custom(left:String, right:String);
}

enum ImagePositions
{
	TopTop;
	TopLeft;
	TopRight;
	Bottom;
	BottomLeft;
	BottomRight;
	Left;
	Right;
	Custom(x:Int, y:Int);
}

enum PopupContentTypes
{
	Text(text:String);
	TextWithImage(text:String, image:String, imagePosition:ImagePositions);
}

enum ButtonPressed
{
	Left; // by the way, the middle button is the left button because adding a middle enum whoud be complicated
	Right;
}

enum PopupType
{
	Error;
	Regular;
}

class PopupSubState extends FlxSubState
{
	// public static var closedSignal:FlxSignal = new FlxSignal(); what was the point of this?

	public static var popupWidth:Int = 800;
	public static var popupHeight:Int = 300;
	public static var infoBarHeight:Int = 100;

	var popupButtons:PopupButtons;
	var popupContentType:PopupContentTypes;
	var popupType:PopupType;
	var callback:Void->ButtonPressed;

	var popupGroup:FlxSpriteGroup;

	public function new(popupButtons:PopupButtons, PopupType:PopupType, PopupContentType:PopupContentTypes, ?callback:Void->ButtonPressed)
	{
		super(0xBB000000);
		this.popupButtons = popupButtons;
		this.popupType = PopupType;
		this.popupContentType = PopupContentType;
		this.callback = callback;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		popupGroup = new FlxSpriteGroup();
		add(popupGroup);

		var color:FlxColor = 0xFF9900FF;
		var sound:String = 	"popup";
		if (popupType == Error) {
			color = 0xFFEB614F;
			sound = "error";
			FlxG.camera.shake(0.015, 0.25, null, false, X);
		}

		FlxG.sound.play(Paths.sound(sound), 1);

		var outline = new FlxSprite(-10, 0).makeGraphic(popupWidth + 20, popupHeight + infoBarHeight + 20, color);
		popupGroup.add(outline);

		var infoBar = new FlxSprite(0, 10).makeGraphic(popupWidth, infoBarHeight, 0xFF1F1F21);
		popupGroup.add(infoBar);

		var popupBackground = new FlxSprite(0, infoBarHeight + 20).makeGraphic(popupWidth, popupHeight - 10, 0xFF2B2B2F);
		popupBackground.pixels = ImageUtils.drawInsideBorder(popupBackground.pixels, 10, 0xFF1F1F21);
		popupGroup.add(popupBackground);

		switch (popupContentType)
		{
			case Text(text):
				var daText = new FlxText(popupBackground.x + 5, popupBackground.y + 5, popupBackground.width - 5, text, 16);
				daText.setFormat(Paths.font("defaultSans.ttf"), 64, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
				daText.borderSize = 4;
				popupGroup.add(daText);
			default:
		}

		switch (popupButtons)
		{
			case Ok:
				var okButt = new FlxButton(popupBackground.x, popupBackground.y + popupBackground.height - 100, "Ok", () -> {
					// FlxG.mouse.visible = false;
					close();
					if (callback != null)
						callback();
				});
				okButt.makeGraphic(Std.int(popupBackground.width), 100, 0xFF2B2B2F);
				okButt.pixels = ImageUtils.drawInsideBorder(okButt.pixels, 10, 0xFF1F1F21);
				okButt.label.setFormat(Paths.font("defaultSans.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
				okButt.label.y = 1000;
				okButt.labelAlphas = [1, 1, 1];
				var stupid = new FlxPoint(0, okButt.height / 2);
				okButt.labelOffsets = [stupid, stupid, stupid];

				popupGroup.add(okButt);
			default:
		}

		popupGroup.screenCenter();

		popupGroup.alpha = 0;

		FlxTween.tween(popupGroup, {alpha: 1}, 1, {ease: FlxEase.expoOut});
		popupGroup.scrollFactor.set();

		super.create();
	}

	override function close()
	{
		super.close();
	}
}
