// just a video test
// this currently  only supports AV1 MKV files
// ... that have no audio
// yheah this is limited as fuck but if you wanna https://github.com/HeapsIO/hlvideo

#if hlvideo
package display.objects;


import haxe.Timer;
import openfl.display.BitmapData;
import haxe.io.Bytes;
import hl.video.Webm;
import hl.video.Aom;
import flixel.FlxSprite;

typedef Frame =
{
	var data:BitmapData;
	var time:Float;
}

class Video extends FlxSprite
{
	public var playbackRate:Float = 1;
	public var bufferSize:Int = 24;
	public var readPosition:Int;

	var startTime:Float;
	var webm:Webm;
	var codec:AV1;
	var buffer:Bytes;
	var playing:Bool = false;

	public var frameBuffer:Array<Frame> = [];

	public function new()
	{
		super();
	}

	public function loadPath(path:String)
	{
		try
		{
			webm = Webm.fromFile(path);
		}
		play();
	}

	public function play()
	{
		webm.init();
		codec = webm.createCodec();

		
		buffer = Bytes.alloc(webm.width * webm.height);
		pixels = BitmapData.fromBytes(buffer);
        startTime = Timer.stamp();
		playing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playing)
			return;

		while ((frameBuffer.length <= bufferSize)) {
            frameBuffer.push({
                data: new BitmapData(webm.width, webm.height),
                time: 0
            });
        }

        if ((Timer.stamp() - startTime) >= (frameBuffer[0].time / playbackRate)) {
            var frame = frameBuffer.shift();
            var time = webm.readFrame(codec, frame.data.image.data.toBytes());
        
            frame.time = time;
            pixels = frame.data;
            pixels.image.format = RGBA32;
        }
	}
}
#end