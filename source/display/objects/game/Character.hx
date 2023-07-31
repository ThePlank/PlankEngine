package display.objects.game;

import flixel.math.FlxPoint;
import flixel.animation.FlxAnimation;
import util.CoolUtil;
import classes.Conductor;
import states.game.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;

using StringTools;

typedef CharacterData = {
	var assetName:String;
	var offsets:Dynamic<Array<Int>>;
	var animationNames:Dynamic<AnimationData>;
	var swapLR:Bool;
	var charPosition:Array<Int>;
	var scale:Array<Int>;
	var antialias:Bool;
	var singTimer:Float;
	var flipX:Bool;
	var flipY:Bool;
}

typedef AnimationData = {
	var name:String;
	var fps:Int;
	var loop:Bool;
	var ?indecies:Array<Int>;
	var ?postfix:String;
}

@:access(flixel.animation.FlxAnimationController)
class Character extends FlxSprite
{
	public static final DEF_CHAR:String = 'bf';

	public var baseAnimOffsets:Map<String, FlxPoint> = [];
	public var animOffsets:Map<String, FlxPoint> = [];
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var assetName:String = '';

	public var holdTimer:Float = 0;
	public var singTime:Float = 0;
	public var data:CharacterData;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, FlxPoint>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		try {
			loadChar();
		} catch(err) {
			curCharacter = DEF_CHAR;
			loadChar();
		}
	}

	private function loadChar() {
		data = cast Json.parse(Paths.getTextFromFile('characters/$curCharacter/data.json'));

		assetName = data.assetName;
		var image = Paths.image(Paths.getPath('characters/$curCharacter/$assetName.png'));
		var exemel = Paths.getTextFromFile('characters/$curCharacter/$assetName.xml');
		var tex:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(image, exemel);
		
		frames = tex;

		var animData:Array<AnimationData> = []; 
		var anims = Reflect.fields(data.animationNames);

		for (i in 0...anims.length) {
			var daThing:AnimationData = cast Reflect.getProperty(data.animationNames, anims[i]);
			animData.push(daThing);
		}
	
		for (i in 0...animData.length) {
			
			if (animData[i].indecies != null) {
				// trace("ADDED \"" + anims[i] + "\" USING INDECIES");
				// @:privateAccess trace(animation._animations.toString(), curCharacter);
				animation.addByIndices(anims[i], animData[i].name, animData[i].indecies, animData[i].postfix, animData[i].fps, animData[i].loop);
			}
			else {
				// trace("ADDED \"" + anims[i] + "\" USING prefix");
				// @:privateAccess trace(animation._animations.toString(), curCharacter);
				animation.addByPrefix(anims[i], animData[i].name, animData[i].fps, animData[i].loop);
			}
		}

		var parsedOffsets = CoolUtil.DynamicToIntArrayMap(data.offsets);
	
		for (animName => offsets in parsedOffsets) {
			addOffset(animName, offsets[0], offsets[1]);
		}

		flipX = data.flipX;
		flipY = data.flipY;

		scale.set(data.scale[0], data.scale[1]);
		updateHitbox();

		antialiasing = data.antialias;

		singTime = data.singTimer;

		doGFDanceShit = (animation._animations.exists('danceLeft') && animation._animations.exists('danceRight'));

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				swapAnimation('singRIGHT', 'singLEFT');

				if (animation._animations.exists('singRIGHTmiss'))
					return;
				swapAnimation('singRIGHTmiss', 'singLEFTmiss');
			}
		}
	}


	public function swapAnimation(animation:String, with:String) {
		var anim:FlxAnimation = this.animation.getByName(animation);
		var swapAnimation:FlxAnimation = this.animation.getByName(with);
		var swapFrames:Array<Int> = anim.frames;
		anim.frames = swapAnimation.frames;
		swapAnimation.frames = swapFrames;
	}

	override function update(delta:Float)
	{
		if (animation.curAnim.name.startsWith('sing'))
			holdTimer += delta;
		else if (isPlayer)
			holdTimer = 0;

		if (!isPlayer && holdTimer >= Conductor.stepCrochet * singTime * 0.001)
		{
			dance();
			holdTimer = 0;
		}

		if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			playAnim('idle', true, false, 10);

		if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			playAnim('deathLoop');

		if (doGFDanceShit) 
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');

		super.update(delta);
	}
	
	private var danced:Bool = false;
	private var doGFDanceShit:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			if (doGFDanceShit) {
				if (animation.curAnim != null && animation.curAnim.name.startsWith('hair'))
					return;
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			} else
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset.x, daOffset.y);
		}
		else
			offset.set(0, 0);

		if (doGFDanceShit)
		{
			switch (AnimName) {
				case 'singLEFT':
					danced = true;
				case 'singRIGHT':
					danced = false;
				case 'singUP' | 'singDOWN':
					danced = !danced;
			}
		}
	}

	override function destroy():Void {
		// flixel.util.FlxDestroyUtil.putArray();
		return super.destroy();
	}

	override function set_angle(angle:Float) {
		// account for rotation
		super.set_angle(angle);
		// updateAnimationOffsets();
		return this.angle;
	}

	// imma make this later kthxbye
	function updateAnimationOffsets() {
		// var doFlipX:Bool = (data.flipX && flipX);
		// var doFlipY:Bool = (data.flipY && flipY);
		for (anim => offsets in baseAnimOffsets) {
			// offsets.x *= (scale.x / data.scale[0]);
			// offsets.y *= (scale.y / data.scale[1]);
			// offsets.x *= (doFlipX ? -1 : 1);
			// offsets.y *= (doFlipY ? -1 : 1);
			// offsets.rotateByDegrees(angle);
			animOffsets[anim] = offsets;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		baseAnimOffsets[name] = FlxPoint.get(x, y);
		updateAnimationOffsets();
	}

	public static function getCharData(char:String) {
		var charData:CharacterData = cast Json.parse(Paths.getTextFromFile('characters/$char/data.json'));
		return charData;
	}

	/*
	public function toCharacterData():CharacterData {
		var realOffsets: Dynamic<Array<Int>> = {};

		for (key => point in baseAnimOffsets)
			realOffsets[key] = [point.x, point.y];

		var dadVar:Float = 4;

		if (curCharacter == 'dad')
			dadVar = 6.1;

		var daAnimationNames:Dynamic<AnimationData> = {};

		for (key => anim in animation._animations)
			realOffsets[key] = [point.x, point.y];

		return {
			assetName: assetName,
			swapLR: false, // no really a way to get if the lr get swapped (this function is meant to be for converting source characters to the system)
			flipX: flipX,
			flipY: flipY,
			scale: [scale.x, scale.y],
			offsets: realOffsets,
			angle: this.angle,
			charPosition: [0, 0],
			antialias: antialiasing,
			singTimer: dadVar,
		}
	}
	*/
}
