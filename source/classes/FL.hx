package classes;

import haxe.Exception;
import haxe.io.Bytes;
import Type;
import byteConvert.ByteConvert;

using StringTools;

// haha stolen from sniff https://github.com/PrincessMtH/SNIFF/blob/master/SNIFF/FL.cs
// todo: sniff

typedef FLNote =
{
	var Time:Int;
	var TBD:Int;
	var ChannelNo:Int;
	var Duration:Int;
	var Pitch:Int;
	var FinePitch:Int;
	var Release:Int;
	var Flags:Int;
	var Panning:Int;
	var Velocity:Int;
	var ModX:Int;
	var ModY:Int;
}

enum abstract EventIDs(Int) from Int to Int
{
	var B_CH_EN_DIS = 0x00;
	var B_NOTE_ON;
	var B_CH_VOL;
	var B_CH_PAN;
	var B_MIDI_CH;
	var B_MIDI_NOTE;
	var B_MIDI_PATCH;
	var B_MIDI_BANK;
	var B_PAT_MODE = 0x09;
	var B_SHOW_INF;
	var B_MAIN_SWING;
	var B_MAIN_VOL;
	var B_STRETCH_SNAP;
	var B_PITCHABLE;
	var B_ZIPPED;
	var B_DLY_FLAGS;
	var B_TIMESIG_BAR;
	var B_TIMESIG_BEAT;
	var B_USE_LOOP_PTS;
	var B_LOOP_TYPE;
	var B_CH_TYPE;
	var B_MIXER_CH;
	var B_N_STEPS_SHOWN = 0x18;
	var B_SS_LENGTH;
	var B_SS_LOOP;
	var B_FX_PROPS;
	var B_REG_STATUS;
	var B_APDC;
	var B_PLAY_TRUNC_NOTES;
	var B_EE_AUTO_MODE;
	var B_UNK_FL20 = 0x25;
	var W_GEN_CH_NO = 0x40;
	var W_PAT_START;
	var W_CUR_PAT = 0x43;
	var D_CUR_FTR_GRP = 0x92;
	var D_PROJ_TMP = 0x9C;
	var D_UNK_FL20 = 0x9F;
	var A_GEN_CH_NAME = 0xC0;
	var A_PAT_NAME;
	var A_PROJ_TITLE;
	var A_SAMP_FILE_PATH = 0xC4;
	var A_PROJ_URL;
	var A_PROJ_INF;
	var A_VER_NUM;
	var A_PLUG_NAME = 0xC9;
	var A_EFF_CH_NAME = 0xCB;
	var A_MXR_INS_NAME;
	var A_PROJ_GENRE = 0xCE;
	var A_PROJ_AUTHOR;
	var A_DELAY = 0xD1;
	var A_MXR_PLUG_DATA = 0xD4;
	var A_PLUG_DATA;
	var A_AUTO_DATA = 0xDF;
	var A_NOTE_DATA;
	var A_LYR_FLAGS = 0xE2;
	var A_CH_FTR_GRP_NAME = 0xE7;
	var A_UNK_AUTO_DATA = 0xEA;
	var A_SAVE_TIME = 0xED;
	var A_PLST_TRK_INF;
	var A_PLST_TRK_NAME;
	var B_MAX = 0x3F;
	var W_MAX = 0x7F;
	var D_MAX = 0xBF;
	var A_MAX = 0xFF;
}

class ByteEvent extends Event
{
	public function new(id:Int, value:Int)
	{
		super(id, value);
	}

	public function toBytes():Array<Int>
	{
		return [ID, value];
	}
}

class WordEvent extends Event
{
	public function new(id:Int, value:Int)
	{
		super(id, value);
	}

	public function toBytes():Array<Int>
	{
		var bytes = ByteConvert.fromInt16(value);
		return [ID, bytes[0], bytes[1]];
	}
}

class DwordEvent extends Event
{
	public function new(id:Int, value:Int)
	{
		super(id, value);
	}

	public function toBytes():Array<Int>
	{
		var bytes = ByteConvert.fromInt16(value);
		return [ID, bytes[0], bytes[1], bytes[2], bytes[3]];
	}
}

class ArrayEvent extends Event
{
	public var finalI:Int = 0;

	private static function gatherBytes(bytes:Array<Int>, i:Int)
	{ // i dont think ref is possible in haxe so stupid >:(
		var arrlen:Int = bytes[i] & 0x7F;
		var shift:Int = 0;

		while ((bytes[i] & 0x80) != 0)
		{
			i++;
			arrlen = arrlen | ((bytes[i] & 0x7F) << (shift += 7));
		}

		i++;
		return {bytes: bytes.slice(i).slice(arrlen), index: i};
	}

	public function new(id:Int, b:Array<Int>, i:Int)
	{
		var funnies = gatherBytes(b, i);
		finalI = funnies.index;
		super(id, funnies.bytes);
	}

	public function toBytes():Array<Int>
	{
		var b:Array<Int> = [];
		b.push(ID);

		var arrlen:Array<Int> = [];
		var len = Lambda.count(value);
		while (len > 0)
		{
			arrlen.push(len & 0x7F);
			len = len >> 7;
			if (len > 0)
				arrlen[arrlen.length - 1] += 0x80;
		}

		for (arrlenRange in arrlen)
			b.push(arrlenRange);

		var arr = Lambda.array(value);
		for (arrRange in arr)
			b.push(arrRange);

		return b;
	}

	override function toString():String
	{
		return '[${getName(ID)}] {${Std.string(value).replace("-", "")}}';
	}
}

abstract class Event
{
	public var ID(default, null):Int;
	public var value:Dynamic;

	public function new(id:Int, value:Dynamic)
	{
		this.ID = id;
		this.value = value;
	}

	abstract public function toBytes():Array<Int>;

	public function toString():String
	{
		return '[$ID] {$value}';
	}

	public function getName(i:Dynamic)
	{
		if (names[i] != "")
			return names[i];

		return '${Std.string(i)}\tunknown ${Type.getClassName(Type.getClass(i))}';
	}

	// pov: fl studio
	private var names(default, null):Array<String> = [
		"00	Channel Enabled/Disabled",
		"01	Note On",
		"02	Channel Volume",
		"03	Channel Pan",
		"04	MIDI Channel",
		"05	MIDI Note",
		"06	MIDI Patch",
		"07	MIDI Bank",
		"",
		"09	Pattern/Song Mode",
		"0A	Show Info",
		"0B	Main Swing",
		"0C	Main Vol",
		"0D	Stretch/Snap",
		"0E	Pitchable",
		"0F	Zipped",
		"10	Delay Flags",
		"11	Time Signature (Bar)",
		"12	Time Signature (Beat)",
		"13	Use Loop Points",
		"14	Loop Type",
		"15	Channel Type",
		"16	Mixer Channel",
		"",
		"18	n Steps Shown",
		"19	SS Length",
		"1A	SS Loop",
		"1B	FX Properties",
		"1C	unknown/registration status",
		"1D	APDC",
		"1E	Play Truncated Notes",
		"1F	EE Auto Mode",
		"",
		"",
		"",
		"",
		"",
		"25	unknown (FL20 specific)",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"40	Generator Channel Number",
		"41	Pattern Start",
		"",
		"43	Current Pattern",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"92	Current Filter Group",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"9C	Project Tempo",
		"",
		"",
		"9F	unknown (FL20 specific)",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"C0	Generator Channel Name",
		"C1	Pattern Name",
		"C2	Project Title",
		"",
		"C4	(Sampler) File Path",
		"C5	Project URL",
		"C6	Project Info (RTF)",
		"C7	Version Number",
		"",
		"C9	Plugin Name",
		"",
		"CB	Effect Channel Name",
		"CC	Mixer Insert Name",
		"",
		"CE	Project Genre",
		"CF	Project Author",
		"",
		"D1	unknown/delay",
		"",
		"",
		"D4	some Plugin Data (Mixer)",
		"D5	Plugin Data",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"DF	Automation Data",
		"E0	Note Data",
		"",
		"E2	Layer Flags",
		"",
		"",
		"",
		"",
		"E7	Channel Filter Group Name",
		"",
		"",
		"EA	unknown/automation data",
		"",
		"",
		"ED	Save Timestamp",
		"EE	Playlist Track Info",
		"EF	Playlist Track Name",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
	];
}

class FLFile
{
	public var format:Int;
	public var ntracks:Int;
	public var ppqn:Int;

	public var eventList:Array<Event> = []; // haxe, when array access for lists????

	public function new(b:Array<Int>)
	{
		var i = 0;
		// 'FLhd'
		if (b[0] == 0x46 && b[1] == 0x4C && b[2] == 0x68 && b[3] == 0x64)
		{
			i += 4;
			var headLen = ByteConvert.readUInt32(b, i);
			i += 4;
			if (headLen == 6)
			{
				format = ByteConvert.readUInt32(b, i);
				ntracks = ByteConvert.readUInt32(b, i + 2);
				ppqn = ByteConvert.readUInt32(b, i + 4);
			}
			i += headLen;
			// 'FLdt'
			if (b[i] == 0x46 && b[i + 1] == 0x4C && b[i + 2] == 0x64 && b[i + 3] == 0x74)
			{
				// yoo fl data chunk??????
				i += 4;
				var dataLen:Int = ByteConvert.readUInt32(b, i);
				i += 4;
				var dataEnd:Int = i + dataLen;
				// event loop
				while (i < dataEnd && i < b.length)
				{
					var id = b[i++];

					// why do i have to cast it
					if (id <= cast EventIDs.B_MAX) {
						eventList.push(new ByteEvent(id, b[i]));
						i++;
					} else if (id <= cast EventIDs.W_MAX) { 
						eventList.push(new WordEvent(id, ByteConvert.readUInt16(b, i)));
						i += 2;
					} else if (id <= cast EventIDs.D_MAX) { 
						eventList.push(new DwordEvent(id, ByteConvert.readUInt16(b, i)));
						i += 4;
					} else if (id <= cast EventIDs.A_MAX) { 
						var funnyArray = new ArrayEvent(id, b, i);
						eventList.push(funnyArray);
						i = funnyArray.finalI;
						i += funnyArray.value.Length;
					}
				}
			} else
				throw new Exception("Invalid data chunk");
		} else
			throw new Exception("Invalid header chunk");
	}

	public function findFirstEvent(id:EventIDs) {
		for (i in 0...eventList.length) 
			if (eventList[i].ID == cast(id, Int))
				return eventList[i];

		return null;
	}

	public function findNextEvent(id:EventIDs, index:Int) {
		index++;
		for (i in index...eventList.length) 
			if (eventList[i].ID == cast(id, Int))
				return eventList[i];

		return null;
	}

	public function findLastEvent(id:EventIDs) {
		for (i in eventList.length...0) 
			if (eventList[i - 1].ID == cast(id, Int))
				return eventList[i - 1];

		return null;
	}

	public function findPrevEvent(id:EventIDs, index:Int) {
		for (i in eventList.length...index) 
			if (eventList[i - 1].ID == cast(id, Int))
				return eventList[i - 1];

		return null;
	}

	public function findNoteDataByPatternNum(n:Int):Array<Int> {
		for (i in 0...eventList.length) {
			if (eventList[i].ID == cast(EventIDs.W_PAT_START, Int) && eventList[i].value == n)
				if (eventList[i + 1].ID == EventIDs.A_NOTE_DATA)
					return cast eventList[i + 1].value;
		}
		return null;
	}

	public function findPatternNumByName(name:String) {
		name += "\u0000"; // stupid. why not \0?

		for (i in 0...eventList.length) 
			if (eventList[i].ID == cast EventIDs.W_PAT_START)
				if (eventList[i + 1].ID == cast EventIDs.A_PAT_NAME) {
					var patName:Array<Int> = eventList[i + 1].value;
					var patNameBytes:Bytes = Bytes.alloc(patName.length);

					for (ia in 0...patName.length)
						patNameBytes.set(ia, patName[ia]);

					// i have no idea ldslaj'g;sfjogjfpjgop[wfdi [pąa]]AAAAAAAAAAAAAAAAAAAAAAAAAAAAAaaaa...

					if (patNameBytes.toString().toLowerCase().trim() == name)
						return eventList[i].value;
				}

		return 0;
	}
}
