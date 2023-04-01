package classes;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	@:optional var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}