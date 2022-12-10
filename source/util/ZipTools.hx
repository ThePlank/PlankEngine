package util;

import sys.thread.Thread;
import haxe.PosInfos;
import haxe.Exception;
import sys.FileSystem;
import haxe.io.Bytes;
import haxe.zip.*;

using StringTools;

/// GOODLORD THANK YOU YOSHICRAFTER29
// anyways, i *sort of* know how this works

class ZipTools
{
	public static function unZip(zip:Reader, destination:String, ?prefix:String, ?progress:ZipProgress):ZipProgress
	{
		FileSystem.createDirectory(destination);

		var fields:List<Entry> = zip.read();

		try
		{
			trace("Processing zip...");
			if (prefix != null)
			{
				var fieldCopy = fields;
				fields = new List<Entry>();

				for (field in fieldCopy)
				{
					if (field.fileName.startsWith(prefix))
						fields.push(field);
				}
			}

			if (progress == null)
				progress = new ZipProgress();
			progress.fileCount = fields.length;

			for (file => field in fields)
			{
				progress.curFile = file;
				var isFolder:Bool = field.fileName.endsWith("/") && field.fileSize == 0;
				if (isFolder)
					FileSystem.createDirectory('${destination}/${field.fileName}');
				else
				{
					var split:Array<String> = [for (e in field.fileName.split("/")) e.trim()];
					split.pop();
					FileSystem.createDirectory('${destination}/${split.join("/")}');

					//
					//
				}
			}

            progress.curFile = fields.length;
            progress.done = true;
		} catch(e:ZipErrorExeption) {
            progress.done = true;
            progress.error = e;
        }
        return progress;
	}

    public static function uncompressZipThreaded(zip:Reader, destination:String, ?prefix:String, ?progress:ZipProgress):ZipProgress {
        if (progress == null)
            progress = new ZipProgress();

        Thread.create(() -> {
            unZip(zip, destination, prefix, progress);
        });

        return progress;
    }
}

class ZipProgress
{
	public var error:ZipErrorExeption = null;

	public var curFile:Int = 0;
	public var fileCount:Int = 0;
	public var done:Bool = false;
	public var percentage(get, null):Float;

	private function get_percentage()
	{
		return fileCount <= 0 ? 0 : curFile / fileCount;
	}

	public function new()
	{
	}
}

class ZipReader extends Reader {
    public var files:List<Entry>;

    public override function read():haxe.ds.List<Entry> {
        if (files != null) return files;
        try {
            var files = super.read();
            return this.files = files;
        }
        return new List<Entry>();
    }
}

class ZipWriter extends Writer {
    public function flush() {
        o.flush();
    }

    public function writeFile(entry:Entry) {
        writeEntryHeader(entry);
        o.writeFullBytes(entry.data, 0, entry.data.length);
    }

    public function close() {
        o.close();
    }
}

class ZipErrorExeption extends Exception
{
	public function new(message:String = "Error while processing ZIP file", ?previous:Exception, ?native:Any)
	{
		super(message, previous, native);
	}
}
