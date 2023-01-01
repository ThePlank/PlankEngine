package states;

import flixel.group.FlxSpriteGroup;
import states.abstr.UIBaseState;


class OptionsState extends UIBaseState {
    
    var SectionGroup:FlxSpriteGroup;
    var OptionGroup:FlxSpriteGroup;
    
    override function create() {
        backgroundSettings = {
            enabled: true,
            bgColor: 0xFFFFFFFF,
            gradientAngle: 135,
            bgColorGradient: [0xFF5627B8, 0xFF0ED1A6, 0xFFF7C602, 0xFFF7C602] // menu colors from the original plank engine
        }


        super.create();
    }

}