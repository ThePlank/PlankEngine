package states.options;

import states.substates.ui.options.PreferencesMenu;
import states.substates.ui.options.ControlsMenu;
import states.substates.ui.options.OptionsMenu;
import display.objects.ui.options.Page;
import display.objects.ui.options.PageName;
import states.abstr.MusicBeatState;
import flixel.util.FlxTimer;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.Map;

class OptionsState extends MusicBeatState {

    static public var pages:Map<PageName, Page> = new Map<PageName, Page>();
    var currentName:PageName = Options;
    // var currentName(get, default):PageName = Options;


    function get_currentPage() {
        return pages.get(currentName);
    }

    override function create() {
        var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = -1412611;
        menuBG.setGraphicSize(Std.int(1.1 * menuBG.width));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.scrollFactor.set();
        add(menuBG);
        var optionPageCrap:OptionsMenu = cast(addPage(Options, new OptionsMenu()), OptionsMenu);
        var coolPrefMenu = addPage(Preferences, new PreferencesMenu());
        var coolContMenu = addPage(Controls, new ControlsMenu());
        if (optionPageCrap.hasMultipleOptions()) {
            optionPageCrap.onExit.add(exitToMainMenu);

            coolPrefMenu.onExit.add(function() {
                setPage(Options);
            });

            coolContMenu.onExit.add(function() {
                setPage(Options);
            });

        }

    }

    function exitToMainMenu() {
        pages.get(this.currentName).enabled = false;
        switchTo(new MainMenuState());
    }

    function setPage(page:PageName) {
        if (pages.exists(currentName)) {
            pages.get(currentName).exists = false;
            pages.get(currentName).enabled = false;
        }
        currentName = page;
        if (pages.exists(this.currentName)) {
            pages.get(currentName).exists = true;
            pages.get(currentName).enabled = true;
        }
    }

    function addPage(pageName:PageName, instance:Page) {
        instance.onSwitch.add(setPage);
        pages.set(pageName, instance);
        add(instance);
        instance.exists = currentName == pageName;
        instance.enabled = currentName == pageName;
        return instance;
    }
}