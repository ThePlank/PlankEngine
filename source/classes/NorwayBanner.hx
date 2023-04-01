package classes;

/*
    HOW TO USE:
    - call NorwayBanner.check()
    - ????
    - profit
*/

import sys.thread.Thread;
import util.CoolUtil;

typedef IPReturn =
{
	var ip:String;
	var country:String;
	var cc:String;
}

class Web
{
	/**
		Returns the player's IP for web APIs. (Can't bypass VPN)
	**/
	static public function getIP(callback:IPReturn->Void)
	{
		Thread.create(() -> {
			var ip = new haxe.Http("https://api.myip.com");
			ip.onData = function ret(data:String)
			{
				callback(cast haxe.Json.parse(data));
			}
			ip.onError = function err(err:String)
			{
				trace(err);
				callback({ip: "Unknown", country: "Unknown", cc: "Unknown"});
			}
			ip.request();
		});
	}
}

class NorwayBanner
{
	public static function check()
	{
		Web.getIP((ip) ->
		{
			if (ip.cc == "NO")
			{
                CoolUtil.getMainWindow().alert("fuck you");
				Sys.exit(0);
			}
		});
	}
}
