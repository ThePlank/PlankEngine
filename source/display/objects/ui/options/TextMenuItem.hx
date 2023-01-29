package display.objects.ui.options;

import display.objects.ui.options.AtlasText.AtlasFont;

class TextMenuItem extends TextTypedMenuItem {
    public function new(x:Int = 0, y:Int = 0, text:String = "i forgor :skull:", bold:AtlasFont = Bold, ?callback:Dynamic) {
        super(x, y, new AtlasText(0,0, text, bold), text, callback);
        setEmptyBackground();
    }
}