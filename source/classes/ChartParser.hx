package classes;

import byteConvert.ByteConvert;
import classes.FL.ArrayEvent;
import classes.FL.EventIDs;
import classes.FL.Event;
import classes.FL.FLFile;
import classes.Section.SwagSection;
import classes.Song.SwagSong;
import classes.FL.FLNote;
import haxe.io.Bytes;

/**
 * Processor for FSC and MIDI files
 * Originally from SNIFF from MtH
 * You can put this into your stuff but please credit me.
 * @author MtH
 * @author PlankDev
 */
class ChartParser
{
	/**
	 * Map of MIDI notes to note data
	 */
	public static final noteMap:Map<Int, Int> = [
		// bf (MHS true)
		81 => 0,
		82 => 1,
		83 => 2,
		84 => 3,
		// dad (MHS true)
		93 => 4,
		94 => 5,
		95 => 6,
		96 => 7,
	];

	/**
	 * MIDI note for changing mustHitSection to `true`
	 */
	public static final bfCamNote:Int = 86;

	/**
	 * MIDI note for changing mustHitSection to `false`
	 */
	public static final dadCamNote:Int = 87;

	public static function getDeafultSection():SwagSection
	{
		return {
			lengthInSteps: 16,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			altAnim: false
		}
	}

	public static function getDeafultConfig():ParseConfig
	{
		return {
			bpm: 120,
			ppqn: 96,
			noteSize: 24,
		}
	}

	public static function MIDITimeToMS(config:ParseConfig):Float
	{
		return 1000 * 60 / config.bpm / config.ppqn;
	}

	public static function flipNoteActor(section:SwagSection)
	{
		for (i in 0...section.sectionNotes.length)
		{
			var goverment:Int = section.sectionNotes[i][1];
			if (goverment > 3)
				goverment -= 4;
			else
				goverment += 4;
			section.sectionNotes[i][1] = goverment;
		}
	}

	public static function bytesToNotes(b:Array<Int>)
	{
		var notes:Array<FLNote> = [];
        var i:Int = 0;
		while (i < b.length)
		{
			// notes loop
			var n:FLNote = {
				Time: ByteConvert.readInt32(b, i),
				TBD: ByteConvert.readInt16(b, i + 4),
				ChannelNo: ByteConvert.readInt16(b, i + 6),
				Duration: ByteConvert.readInt16(b, i + 8),
				Pitch: ByteConvert.readInt32(b, i + 12),
				FinePitch: ByteConvert.readInt16(b, i + 16),
				Release: b[i + 18],
				Flags: b[i + 19],
				Panning: b[i + 20],
				Velocity: b[i + 21],
				ModX: b[i + 22],
				ModY: b[i + 23]
			};
			notes.push(n);
			i += getDeafultConfig().noteSize;
		}
		return notes;
	}

	public static function fscToNotes(notes:FLFile):Array<FLNote>
	{
		var assBreasts:Array<FLNote> = [];
		var noteData:Event = notes.findFirstEvent(EventIDs.A_NOTE_DATA);
		if (noteData != null)
			assBreasts = bytesToNotes(noteData.value);
		else
			return null;

		return assBreasts;
	}

	public static function fromFSC(notes:Array<FLNote>)
	{
		var config:ParseConfig = getDeafultConfig();

		var song:SwagSong = {
			song: "Test",
			bpm: 120,
			speed: 2,
			needsVoices: true,
			notes: [],
			validScore: true,
			player1: "bf",
			player2: "bf-pixel",
		}

		var sections:Array<SwagSection> = [];

		var mustHitSection:Bool = true;
		while (notes.length > 0)
		{
			while (sections.length * config.ppqn * 4 <= notes[0].Time)
			{
				sections.push(getDeafultSection());
				sections[0].mustHitSection = mustHitSection;
			}
			var note:Array<Dynamic> = [];
			var time:Float = MIDITimeToMS(config) * notes[0].Time;
			var sus:Float = 0;
			if (notes[0].Duration >= config.ppqn / 2 || notes[0].Velocity < 0x40)
				sus = MIDITimeToMS(config) * notes[0].Duration;
			if (notes[0].Pitch == bfCamNote)
			{
				mustHitSection = true;
				if (sections[0].mustHitSection != mustHitSection && sections[0].sectionNotes.length > 0)
					flipNoteActor(sections[0]);
				sections[0].mustHitSection = mustHitSection;
			}
			if (notes[0].Pitch == dadCamNote)
			{
				mustHitSection = false;
				if (sections[0].mustHitSection != mustHitSection && sections[0].sectionNotes.length > 0)
					flipNoteActor(sections[0]);
				sections[0].mustHitSection = mustHitSection;
			}
			note = [time, noteMap.get(notes[0].Pitch), sus];
			if (note != null)
			{
				var sectionList:Array<Dynamic> = sections[0].sectionNotes;
				if ((notes[0].Flags & 0x10) == 0x10)
					note.push(true);
				sectionList.push(notes);
				sections[0].sectionNotes = sectionList;
			}
			notes.shift();
		}

		song.notes = sections;
		return song;
	}
}

typedef ParseConfig =
{
	var bpm:Int;
	var ppqn:Int;
	var noteSize:Int;
}
