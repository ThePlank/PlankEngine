package display.objects.game;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

// thank yoy cherry :pray: kthxbye
class Sustain extends FlxSprite {
    public var parent:Note = null;
    public var length:Int = 0;
	public var singleSustainHeight(default, set):Float;

    public var onSustainDraw:(sustain:Sustain, sustainNumber:Int)->Void;
    public var canBeHit:Bool;

	public var sustainHeight(get, never):Float;
	public var increaseHeight(default, null):Float = 0;
    private var oldFrameHeight:Float;

    public function new(parent:Note, length:Int = 0) {
        this.parent = parent;
        this.length = length;

        super();
        antialiasing = true;
        
		frames = Paths.getSparrowAtlas('notes/notes');
		for (direction in 0...4) {
			var color:String = Note.getColorFromDirection(direction);
			animation.addByPrefix('$color PIECE', '${color}Hold0');
			animation.addByPrefix('$color END', '${color}HoldEnd');
		}
		animation.play('${Note.getColorFromDirection(parent.noteData)} PIECE');
		oldFrameHeight = frameHeight;
    }

    override public function draw() {
		// y = parent.y + parent.height / 2;
        offset.y = 0;
        for (sustain in 0...length + 1){
            // alpha = (sustain / length);

            var color:String = Note.getColorFromDirection(parent.noteData);
			var oS:Float = scale.y;
            if (sustain == length) {
                animation.play('$color END');
                scale.y = 1;
                offset.y = increaseHeight * sustain;
                updateHitbox();
            } else
                animation.play('$color PIECE');

            super.draw();
			if (onSustainDraw != null)
				onSustainDraw(this, sustain);

            scale.y = oS;
            updateHitbox();
            if (sustain != length)
				offset.y += increaseHeight;
            // else
                // offset.y += increaseHeight * sustain;
        }
        shader = null;
		// y = parent.y + (parent.height - frameHeight) / 2;
    }

    override public function update(delta:Float) {
        super.update(delta);
        if (parent.strumTime > Conductor.songPosition - Conductor.safeZoneOffset
            && parent.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
            canBeHit = true;
        else
            canBeHit = false;
    } 

    private function get_sustainHeight():Float {
        return singleSustainHeight * length;
    }
	private function set_singleSustainHeight(H:Float):Float {
		increaseHeight = (H - (oldFrameHeight / H)) - (H / length);
		scale.y = H;
        updateHitbox();
        
		return singleSustainHeight = H;
    }
}