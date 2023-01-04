package classes;

import haxe.ds.Option;
import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end


	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(diff, song);


		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{


		var daWeek:String = formatSong(diff, 'week' + week);

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		Options.saveData.data.songScores = songScores;
		Options.save();
	}

	public static function formatSong(diff:Int, ?song:String):String
	{
		var daSong:String = 'normal';

		if (diff == 0)
			daSong = 'easy';
		else if (diff == 2)
			daSong = 'hard';

		if (song != null)
			daSong = '${song}-${daSong}';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(diff, song)))
			setScore(formatSong(diff, song), 0);

		return songScores.get(formatSong(diff, song));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSong(diff, 'week' + week)))
			setScore(formatSong(diff, 'week' + week), 0);

		return songScores.get(formatSong(diff, 'week' + week));
	}

	public static function load():Void
	{
		if (Options.saveData.data.songScores != null)
		{
			songScores = Options.saveData.data.songScores;
		}
	}
}
