package classes.macros;

class Version {
  macro static function buildDate() {
    var ret = Date.now().toString();
    return macro $v{ret};
  }

  static function getLine(cmd: String, args: Array<String>):String {
    var process:sys.io.Process = new sys.io.Process(cmd, args);
    var line:String = process.stdout.readLine();
    process.close();
    return StringTools.trim(line);
  }

  macro static function getGitVersion() {
    var name = getLine("git", ["rev-parse", "--abbrev-ref", "HEAD"]);
    var ver = getLine("git", ["describe", "--always"]);
    var ret = ver + "/" + name;
    return macro $v{ret};
  }

  static public function version():String {
    return '${getGitVersion()} built on ${buildDate()}';
  }
}