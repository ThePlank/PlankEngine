package classes;

import Sys.sleep;
#if discord_rpc
import discord_rpc.DiscordRpc;
#end

#if hldiscord
import discord.Api;
#end

#if hl
import hl.Bytes;
#end

using StringTools;

class DiscordClient
{
	#if hldiscord // hldiscord: Hashlink
	public function new() {
		trace("Discord Client starting...");
		Api.init("814588678700924999", "00000000");
		trace("Discord Client started.");

		while (true)
		{
			sleep(2);
		}

		Api.release();
	}

	public static function shutdown()
		Api.release();

	static function onReady() {
		Api.updatePresence(null, "In the Menus", false);
		Api.updateLargeImageKey("icon");
		Api.updateLargeImageText("Friday Night Funkin'");
	}

	static function onError(_code:Int, _message:String)
		trace('Error! $_code : $_message');

	static function onDisconnected(_code:Int, _message:String)
		trace('Disconnected! $_code : $_message');

	public static function initialize() {
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		Api.updatePresence(state, details, false);
		Api.updateLargeImageKey("icon");
		Api.updateLargeImageText("Friday Night Funkin'");
		Api.updateSmallImageKey(smallImageKey, false);
		Api.updateStartTimestamp(Std.int(startTimestamp / 1000), false);
		Api.updateEndTimestamp(Std.int(endTimestamp / 1000), false);

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
	#else // stub
	public function new() {}
	public static function shutdown() {}
	static function onReady() {}
	static function onError(_code:Int, _message:String) {}
	static function onDisconnected(_code:Int, _message:String) {}
	public static function initialize() {}
	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {}
	#end
}
