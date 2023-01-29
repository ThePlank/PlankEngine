package states.substates.ui.options;

import display.objects.ui.options.ButtonStyle;
import display.objects.ui.options.ButtonStyle;
import display.objects.ui.options.TextMenuList;
import display.objects.ui.options.AtlasText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxAxes;

class Prompt extends FlxSubState {
    var buttons:TextMenuList;
    var field:AtlasText;
    var style:ButtonStyle;
    public var back:FlxSprite;
    public var onYes:Void->Void;
    public var onNo:Void->Void;

    public function new(text:String = "balls", style:ButtonStyle = Ok) {
        this.style = style;
        super(-2147483648);
        buttons = new TextMenuList(Horizontal);
        field = new AtlasText(0,0,text,Bold);
        field.scrollFactor.set();
    }

    override function create() {
        super.create();
        field.y = 100;
        field.screenCenter(X);
        add(field);
        add(buttons);
        createButtons();
    }

    function createButtons() {
        for (i in 0...buttons.members.length)
            buttons.remove(buttons.members[0], true).destroy();

        switch(style) {
            case Ok:
                createButtonsHelper("ok");
            case Yes_No:
                createButtonsHelper("yes", "no");
            case Custom(yes, no):
                createButtonsHelper(yes, no);
            case None:
                buttons.exists = false;
        }
         
    }

    public function createBg(width:Int = 1, height:Int = 1, color:FlxColor = -8355712) { // yelo :)
        back = new FlxSprite();
        back.makeGraphic(width, height, color, false, "prompt-bg");
        back.screenCenter();
        add(back);
        members.unshift(members.pop());
    }

    public function createBgFromMargin(margin:Int = 100, color:FlxColor = -8355712) {
        createBg(FlxG.width - 2 * margin | 0, FlxG.height - 2 * margin | 0, color);
    }

    function createButtonsHelper(y:String = "ok", ?n:String) {
        buttons.exists = true;
        var coolYesButton = buttons.createItem(0,0, y, Bold, function() {
            onYes();
            close();
        });
        coolYesButton.screenCenter(X);
        coolYesButton.y = FlxG.height - coolYesButton.height - 100;
        coolYesButton.scrollFactor.set();
        if (n != null) {
            coolYesButton.x = FlxG.width - coolYesButton.width - 100;
            var coolNoButton = buttons.createItem(0,0, n, Bold, function() {
                onNo();
                close();
            });
            coolNoButton.screenCenter(X);
            coolNoButton.y = FlxG.height - coolNoButton.height - 100;
        }
    }

    public function setText(tegggggzt:String) {
        field.text = tegggggzt;
        field.screenCenter(X);
    }
}