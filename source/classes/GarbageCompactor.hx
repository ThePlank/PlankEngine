package classes;

import haxe.EnumFlags;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

class GarbageCompactor {
	public static var disableCount:Int = 0;

	public static function askDisable() {
		disableCount++;
		if (disableCount > 0)
			disable();
		else
			enable();
	}
	public static function askEnable() {
		disableCount--;
		if (disableCount > 0)
			disable();
		else
			enable();
	}

	public static function init() {
		#if hl
		var flags:EnumFlags<GcFlag> = Gc.flags;
		flags.unset(NoThreads);
		// flags.set(ForceMajor); tip: do not flag this
		Gc.flags = flags;
		#end
	}
	
	public static function clearMinor() {
		#if (cpp || java || neko)
		Gc.run(false);
		#end
	}

	public static function clearMajor() {
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
	}

	public static function enable() {
		#if (cpp || hl)
		Gc.enable(true);
		#end
	}

	public static function disable() {
		#if (cpp || hl)
		Gc.enable(false);
		#end
	}

	public static inline function currentMemUsage() {
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif hl
		return Gc.stats().currentMemory;
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}