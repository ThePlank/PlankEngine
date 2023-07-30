package display.shaders;


import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

// ripped from ColorSwap
class OutlineShader extends FlxShader
{
    @:isVar public var outlineSize(get, set):Float = 3;
	@:glFragmentSource('
        #pragma header

        uniform float funkykong;

        void main()
        {
                vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
                 // Outline bullshit?
                vec2 size = vec2(funkykong, funkykong);

                if (color.a <= 0.5) {
                    float w = size.x / openfl_TextureSize.x;
                    float h = size.y / openfl_TextureSize.y;
                    
                    if (flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0.
                    || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0.
                    || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0.
                    || flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.)
                        color = vec4(1.0, 1.0, 1.0, 1.0);
                }       
            gl_FragColor = color;    
        }
    ')
	public function new()
	{
		super();
	}

     function get_outlineSize():Float
        return funkykong.value[0];

    function set_outlineSize(size:Float):Float
    {
        funkykong.value = [size];
        return size;
    }
}