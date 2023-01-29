package display.objects.ui.options;

enum ButtonStyle {
    Ok;
    Yes_No;
    Custom(yes:String, ?no:String);
    None;
}