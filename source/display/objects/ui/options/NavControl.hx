package display.objects.ui.options;

enum NavControl {
    Horizontal;
    Vertical;
    Both;
    Columns(length:Int);
    Rows(length:Int);
}

enum WrapMode {
    Horizontal;
    Vertical;
    Both;
    None;
}