package states.ui;
import display.objects.game.StrumLine;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import	flixel.text.FlxText;
import	flixel.util.FlxTimer;

class OffsetState extends MusicBeatState {
	public var strum:StrumLine;
	public var noteBackdrop:FlxBackdrop;
	public var otherBackdrop:FlxBackdrop;
	public var milisecondText:FlxText;
	public var started:Bool = false;
	public var chart:{bpm:Int, speed:Float, notes:Array<Array<Float>>};
	public var offset:Float = 0;
	public var noteHits:Array<Float> = [];

	override public function create() {
		super.create();
		while (FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		Conductor.songPosition = -2500;

		noteBackdrop = new FlxBackdrop(null, XY, 15, 15);
		noteBackdrop.frames = Paths.getSparrowAtlas('NOTE_assets');
		noteBackdrop.animation.addByPrefix('static', 'arrowLEFT');
		noteBackdrop.animation.play('static');
		noteBackdrop.scale.set(0.25, 0.25);
		noteBackdrop.alpha = 0.25;
		noteBackdrop.velocity.set(15, 15);
		noteBackdrop.antialiasing = true;

		otherBackdrop = new FlxBackdrop(null, XY, 15, 15);
		otherBackdrop.frames = Paths.getSparrowAtlas('NOTE_assets');
		otherBackdrop.animation.addByPrefix('0', 'purple0');
		otherBackdrop.animation.addByPrefix('1', 'blue0');
		otherBackdrop.animation.addByPrefix('2', 'green0');
		otherBackdrop.animation.addByPrefix('3', 'red0');
		otherBackdrop.scale.set(0.5, 0.5);
		otherBackdrop.alpha = 0.15;
		otherBackdrop.velocity.set(15, -15);
		otherBackdrop.antialiasing = true;
		add(otherBackdrop);
		add(noteBackdrop);

		milisecondText = new FlxText(0, 0, FlxG.width	, "0ms", 256);
		milisecondText.screenCenter();
		milisecondText.alpha = 0.25;
		milisecondText.alignment = CENTER;
		add(milisecondText);

		add(strum = new StrumLine(0, 50, CPU, null, true));
		strum.screenCenter(X);

		strum.noteHit.add((data) -> {
			noteHits.push(data.noteDiff);
			otherBackdrop.animation.play(Std.string(data.note.noteData));
			var avgn:Float = 0;
			for (hit in noteHits)
				avgn += hit;
			offset = Math.floor(avgn / noteHits.length);
			milisecondText.text = '${offset}ms';
		});

		var shutter:display.shaders.ShutterEffect = new display.shaders.ShutterEffect();
		shutter.shutterTargetMode = display.shaders.ShutterEffect.SHUTTER_TARGET_FLXCAMERA;
		FlxG.camera.setFilters([new openfl.filters.ShaderFilter(shutter.shader)]);
		FlxTween.tween(shutter, {radius: FlxG.width + 500}, 1.5, {ease: FlxEase.expoOut});

		chart = cast haxe.Json.parse(Paths.getTextFromFile('data/offset.json'));
		strum.scrollSpeed = chart.speed;
		Conductor.bpm = chart.bpm;
		for (note in chart.notes)
			strum.addNote(new display.objects.game.Note(note[0], Std.int(note[1])));

		var snd = Paths.music('offset');
		new FlxTimer().start(2.5, (tmr) -> {
			FlxG.sound.playMusic(snd, 1, false);
			FlxG.sound.music.onComplete = onSongComplete;
			started = true;
		});
	}

	function onSongComplete() {
		FlxTween.tween(noteBackdrop, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.sineOut});
		FlxTween.tween(milisecondText, {alpha: 1}, Conductor.crochet / 1000, {ease: FlxEase.sineOut});
		FlxTween.tween(milisecondText.scale, {x: 1.1, y: 1.1}, Conductor.crochet / 1000, {ease: FlxEase.expoOut});
		FlxTween.tween(strum, {y: FlxG.height}, Conductor.crochet / 1000, {ease: FlxEase.expoIn});
		new FlxTimer().start((Conductor.crochet / 1000) * 4, (tmr) -> states.abstr.UIBaseState.switchState(states.ui.options.OptionsState));
	}

	override	public function beatHit() {
		super.beatHit();
		FlxG.camera.zoom += 0.05;
		if (curBeat % 16 == 0) FlxTween.tween(noteBackdrop, {angle: noteBackdrop.angle + 90}, Conductor.crochet / 1000, {ease: FlxEase.backInOut});
	}

	override	public function update(deltaTime:Float) {
		super.update(deltaTime);
		if (!started) Conductor.songPosition += FlxG.elapsed * 1000 else Conductor.songPosition = FlxG.sound.music.time;
		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 1, 0.15);
	}

	override public function stepHit() {
		super.stepHit();
	}
}