package states;

import flixel.FlxG;
import classes.Options;
import display.objects.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import states.abstr.UIBaseState;

enum OptionState {
    SECTION;
    OPTION;
}

class OptionsState extends UIBaseState {
    
    var sectionGroup:FlxTypedGroup<Alphabet>;
    var optionGroup:FlxTypedGroup<Alphabet>;
    var curSelection:Int = 0;
    var curSectionSelection:String = "";
    var currentState:OptionState = SECTION;
    
    override function create() {
        backgroundSettings = {
            enabled: true,
            bgColor: 0xFFFFFFFF,
            gradientAngle: 135,
            bgColorGradient: [0xFF5627B8, 0xFF0ED1A6, 0xFFF7C602, 0xFFF7C602] // menu colors from the original plank engine
        }

        super.create();

        sectionGroup = new FlxTypedGroup<Alphabet>();
        add(sectionGroup);

        optionGroup = new FlxTypedGroup<Alphabet>();

        trace(Options.optionsMap);
        var i:Int = 0;
        for (name => _ in Options.optionsMap) {
            trace(name);
            var alpha = new Alphabet(0, 0, name, true, false);
            alpha.y = alpha.getNormalizedPosition().y;
            alpha.screenCenter(X);
            alpha.isMenuItem = true;
            alpha.targetY = i;
            alpha.alignmenrt = MIDDLE;
            
            sectionGroup.add(alpha);
            i++;
        }

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.UP_P)
            changeSelection(-1);

        if (controls.DOWN_P)
            changeSelection(1);

        if (controls.ACCEPT && currentState == SECTION)
            selectSection(sectionGroup.members[curSelection].text);

    }

    function selectSection(sectionName:String) {
        curSectionSelection = sectionName;
        currentState = OPTION;

        for (member in sectionGroup.members) {
            member.alpha = 0.4;
            member.offset.x = 200;
            member.alignmenrt = LEFT;
        }

        var i:Int = 0;
        for (name => optionStuff in Options.optionsMap.get(curSectionSelection)) {
            trace(name);
            var alpha = new Alphabet(0, 0, name, true, false);
            alpha.y = alpha.getNormalizedPosition().y;
            alpha.screenCenter(X);
            alpha.isMenuItem = true;
            alpha.targetY = i;
            alpha.alignmenrt = MIDDLE;
            
            sectionGroup.add(alpha);
            i++;
        }
    }

    function changeSelection(delta:Int) {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelection += delta;

        switch (currentState) {
            case SECTION:
                if (curSelection < 0)
                    curSelection = Lambda.count(Options.optionsMap) - 1;
                if (curSelection >= Lambda.count(Options.optionsMap))
                    curSelection = 0;
        
                var bullShit:Int = 0;
        
                for (item in sectionGroup.members)
                {
                    item.targetY = bullShit - curSelection;
                    bullShit++;
        
                    item.alpha = 0.6;
        
                    if (item.targetY == 0)
                    {
                        item.alpha = 1;
                    }
                }
            case OPTION:
                if (curSelection < 0)
                    curSelection = Lambda.count(Options.optionsMap.get(curSectionSelection)) - 1;
                if (curSelection >= Lambda.count(Options.optionsMap.get(curSectionSelection)))
                    curSelection = 0;
        
                var bullShit:Int = 0;
        
                for (item in optionGroup.members)
                {
                    item.targetY = bullShit - curSelection;
                    bullShit++;
        
                    item.alpha = 0.6;
        
                    if (item.targetY == 0)
                    {
                        item.alpha = 1;
                    }
                }
        }

    }

}