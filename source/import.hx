#if (haxe < "4.3.0")
#error "Haxe versions 4.2.5 and lower are no longer supported. In other words, GO FUCK YOURSELF"
#end

#if (!macro)
import classes.Paths;

#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

import display.objects.ui.AtlasText;
import display.objects.ui.AtlasText.AtlasFont;
import states.abstr.*;
import util.*;
import	 flixel.math.FlxMath;
import	 classes.Conductor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

#end
