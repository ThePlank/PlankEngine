package states;
import lime.media.openal.AL;
import lime.media.openal.ALFilter;
import flixel.FlxState;
import flixel.FlxG;
import flixel.addons.ui.FlxSlider;
import flixel.sound.FlxSound.FlxFilter;
import flixel.sound.FlxSound.FlxFilterType;

@:access(flixel.sound.FlxSound)
@:access(openfl.media.Sound)
@:access(lime.media.AudioBuffer)
@:access(flixel.sound.FlxSound.FlxFilter)
class AudioFilterTestState extends FlxState {
	override function create() {
		super.create();
		FlxG.sound.playMusic(Paths.music('updating'), 0.75);

		var filter = new flixel.sound.FlxSound.FlxFilter(FlxFilterType.LOWPASS);
		filter.gain = 1;

		FlxG.sound.music.filter = filter;

		FlxG.camera.zoom = 1.5;
		var slide:FlxSlider = new FlxSlider(filter, 'filterGain', 0, 0, 0, 1);
		add(slide);
		slide.screenCenter();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		trace(AL.getSourcei(FlxG.sound.music._sound.__buffer.__srcBuffer, AL.DIRECT_FILTER) == FlxG.sound.music.filter.filter);
	}
}