package states.ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;
import openfl.filters.ShaderFilter;
import display.shaders.ShutterEffect;
import display.objects.ui.ScrollableSprite;
import states.abstr.UIBaseState;

import classes.Song;
import util.CoolUtil;
import display.objects.ui.HealthIcon;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import display.objects.ui.Alphabet;
import classes.Highscore;
import states.game.PlayState;
import flixel.group.FlxSpriteGroup;

using StringTools;

class FreeplayState extends UIBaseState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var ballTimer:Float = 0;

	private var grpSongs:MenuList;
	private var curPlaying:Bool = false;
	private var curPlayingSong:String;

	override function create()
	{		
		backgroundSettings = {
			enabled: true,
			bgColor: 0xFF9270fd,
			scrollFactor: [1, 1],
		}
		super.create();

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		addWeek(['Test'], -1, ['bf']);
		#end

		// if (PlayState.SONG == null) Paths.clearUnusedMemory();
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			songs.push(new SongMetadata(initSonglist[i], 1, 'gf'));
		}

		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky']);

		if (StoryMenuState.weekUnlocked[3] || isDebug)
			addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		if (StoryMenuState.weekUnlocked[4] || isDebug)
			addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);

		if (StoryMenuState.weekUnlocked[5] || isDebug)
			addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		if (StoryMenuState.weekUnlocked[6] || isDebug)
			addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		grpSongs = new MenuList(0, 0, VERTICAL(true));
		grpSongs.onSelect.add((sel) -> {
			var poop:String = Highscore.formatSong(curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[sel].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[sel].week;
			LoadingState.loadAndSwitchState(new PlayState());
		});
		grpSongs.onMove.add(changeSelection);

		grpSongs.focused = true;
		grpSongs.padding = 20;
		grpSongs.moveWithCurSelection = true;
		grpSongs.x = 50;
		grpSongs.screenCenter(Y);
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var grp:FlxSpriteGroup = new FlxSpriteGroup(0, 0);
			var songText:AtlasText = new AtlasText(0, 0, songs[i].songName, AtlasFont.Bold);
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.y -= 30;
			songText.x = icon.width + 15;

			grp.add(songText);
			grp.add(icon);
			grpSongs.add(grp);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeDiff();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(delta:Float)
	{
		super.update(delta);

		ballTimer += delta;

		if (ballTimer > 1000 && curPlayingSong != songs[curSelected].songName) {
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			curPlayingSong = songs[curSelected].songName;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FPSLerp.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			UIBaseState.switchState(MainMenuState);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(sel:Int)
	{
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		ballTimer = 0;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
