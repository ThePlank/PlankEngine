package util;

import sys.thread.Thread;
import lime.app.Promise;
import sys.FileSystem as FS;
import haxe.io.Bytes;
import haxe.zip.*;

using StringTools;

// thanks raf
class ZipTools
{
	/**
		Zips a directory of your choice with a name. 
		@param dir The filepath to your directory.
		@param name The name of the zip. `output` by default.
	**/
	static public function zipDir(dir:String, name:String = "output")
	{
		function getEntries(dir:String, entries:List<Entry> = null, inDir:Null<String> = null)
		{
			if (entries == null)
				entries = new List<Entry>();
			if (inDir == null)
				inDir = dir;
			for (file in FS.readDirectory(dir))
			{
				var path = haxe.io.Path.join([dir, file]);
				if (FS.isDirectory(path))
				{
					getEntries(path, entries, inDir);
				}
				else
				{
					var bytes:haxe.io.Bytes = haxe.io.Bytes.ofData(sys.io.File.getBytes(path).getData());
					var entry:Entry = {
						fileName: StringTools.replace(path, inDir, ""),
						fileSize: bytes.length,
						fileTime: Date.now(),
						compressed: false,
						dataSize: FS.stat(path).size,
						data: bytes,
						crc32: haxe.crypto.Crc32.make(bytes)
					};
					entries.push(entry);
				}
			}
			return entries;
		}
		// create the output file
		var out = sys.io.File.write(name + ".zip", true);
		// write the zip file
		var zip = new Writer(out);
		zip.write(getEntries(dir));
	}

	/**
		Unzips the file path and places it relative to the program's dir, and can be moved via whereTo.
		Names it after zipFile.
		@param zipFile The name of the zip you want to extract.
		@param whereTo To place else where inside the relative dir.
		@return Promise with the path of the unzipped directory
	**/
	static function unzip(zipFile:String, whereTo:String = ""):Promise<String>
	{
		var zipfileBytes = sys.io.File.getBytes(Sys.getCwd() + zipFile);
		var bytesInput = new haxe.io.BytesInput(zipfileBytes);
		var reader = new Reader(bytesInput);
		var entries:List<Entry> = reader.read();
		var promise:Promise<String> = new Promise<String>();
		Thread.create(() ->
		{
			for (_entryIndex => _entry in entries.keyValueIterator())
			{
				var data = Reader.unzip(_entry);
				if (_entry.fileName.substring(_entry.fileName.lastIndexOf('/') + 1) == '' && _entry.data.toString() == '')
				{
					FS.createDirectory(Sys.getCwd() + whereTo + _entry.fileName);
				}
				else
				{
					var f = sys.io.File.write(Sys.getCwd + whereTo + _entry.fileName, true);
					f.write(data);
					f.close();
				}
				promise.progress(_entryIndex, entries.length);
			}
			promise.complete(Sys.getCwd() + whereTo);
		});
		return promise;
	}
}
