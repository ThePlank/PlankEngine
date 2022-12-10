package classes.hscript;

import states.abstr.MusicBeatState;

// TODO: also make this class
class PlankState extends MusicBeatState {
    var mainScript:PlankScript;

    public function new(script:PlankScript) {
        mainScript = script;
        super();
    }
}