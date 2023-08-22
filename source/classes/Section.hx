package classes;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	@:optional var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}