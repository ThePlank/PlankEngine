package display.shaders;

import flixel.system.FlxAssets.FlxShader;

class OverlayShader extends FlxShader { // wtf this shader was so fucked up
	@:glFragmentSource('
		#pragma header
		uniform vec4 uBlendColor;

		vec3 blendLighten(vec3 base, vec3 blend) {
			return mix(
				1.0 - 2.0 * (1.0 - base) * (1.0 - blend),
				2.0 * base * blend,
				step( base, vec3(0.5) )
			);
		}

		vec4 blendBighten(vec4 base, vec4 blend, float opacity) {
			return vec4(blendLighten(base.rgb, blend.rgb) * opacity + base.rgb * (1.0 - opacity), opacity);
		}

		void main()
		{
			vec4 base = flixel_texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = blendBighten(base, uBlendColor, uBlendColor.a);
		}')
	public function new()
	{
		super();
	}
}
