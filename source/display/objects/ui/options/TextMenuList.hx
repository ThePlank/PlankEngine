package display.objects.ui.options;

import display.objects.ui.options.AtlasText.AtlasFont;

class TextMenuList extends MenuTypedList<TextMenuItem> {

    public function createItem(x:Int = 0, y:Int = 0, name:String = "h", bold:AtlasFont = Bold, callback:Dynamic, fireInstant:Bool = false) {
        var item = new TextMenuItem(x,y,name,bold,callback);
        item.fireInstantly = fireInstant;
        return addItem(name, item);
    }
    
}