package states;

import flixel.math.FlxRect;
import states.substates.PauseSubState;
import flixel.FlxSubState;
import flixel.util.FlxSort;
import classes.Section.SwagSection;
import openfl.ui.Keyboard;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.events.KeyboardEvent;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import objects.DialogueBox;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxPoint;
import flixel.addons.effects.chainable.FlxWaveEffect;
import openfl.Lib;
import objects.BackgroundGirls;
import classes.TimingStruct;
import classes.Conductor;
import classes.Song.Event;
import classes.Song;
import util.HelperFunctions;
import util.Ratings;
import util.CoolUtil;
import classes.PlayStateChangeables;
import flixel.FlxG;
import flixel.FlxBasic;
import objects.BackgroundDancer;
import flixel.FlxCamera;
import objects.HealthIcon;
import objects.Character;
import classes.Song.SwagSong;
import objects.Boyfriend;
import objects.NoteSplash;
import flixel.text.FlxText;
import objects.NoteSplash;
import flixel.FlxObject;
import objects.Note;
import classes.Replay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import classes.shaders.WiggleEffect;
import classes.Replay.Analysis;
import classes.KeyBinds;
import states.substates.ResultsScreen;
import flixel.addons.transition.FlxTransitionableState;
import classes.Highscore;
import util.ConvertScore;
import util.EtternaFunctions;

class MoveTanks extends FlxSprite
{
public static var curStage:String = '';
var tankGround:BGSprite;

var tankX:Float = 400;
var tankSpeed:Float = FlxG.random.float(5, 7);
var tankAngle:Float = FlxG.random.int(-90, 45);

function moveTank(?elapsed:Float = 0):Void
	{

			tankAngle += elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));

            switch (curStage)
            {
                case 'tank':
                    moveTank(elapsed);
            }
	}
}