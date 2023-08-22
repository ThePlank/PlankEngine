package display.shaders;

import flixel.system.FlxAssets.FlxShader;

// based on https://www.shadertoy.com/view/4sBBDK :3
class HalftoneShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		#define rotate2d(a) mat2(cos(angle), -sin(angle), sin(angle),cos(angle))

		uniform float angle;
		uniform float scale;
		uniform bool palleteEnabled;

		float dotScreen(vec2 uv, float angle, float scale) {
			float s = sin( angle ), c = cos( angle );
			vec2 p = (uv - vec2(0.5)) * openfl_TextureSize.xy;
			vec2 q = rotate2d(angle) * p * scale;
			return ( sin( q.x ) * sin( q.y ) ) * 4.0;
		}

		void main() {
			vec2 uv = openfl_TextureCoordv.xy;
			gl_FragColor = flixel_texture2D(bitmap, uv);
			if (palleteEnabled) {
				gl_FragColor.b = 0.333333 * round(gl_FragColor.b / 0.333333);
				gl_FragColor.rg = 0.142857 * round(gl_FragColor.rg / 0.142857);
			}
			gl_FragColor.rgb = gl_FragColor.a * (vec3(gl_FragColor.rgb * 10.0 - 5.0 + dotScreen(uv, angle, scale)));
		}
	')

	public function new() { super(); }
}

@:keep
class BisexualShader extends FlxShader {
	@:glFragmentSource('
		#pragma header

		vec3 palette[3] = vec3[] (
			vec3(0.8392156862745098, 0.007843137254902, 0.4392156862745098), // bi
			vec3(0.607843137254902, 0.3098039215686275, 0.5882352941176471), // sex
			vec3(0, 0.2196078431372549, 0.6588235294117647) // ual
		);

		float colorDistance(vec3 color1, vec3 color2) {
			return sqrt(
			pow(color2.r - color1.r, 2.0) +
			pow(color2.g - color1.g, 2.0) +
			pow(color2.b - color1.b, 2.0));
		}

		vec3 conformColor(vec3 color) {
			vec3 closestColor = palette[0];
			float currentDistance = 255.0;

			for(int i = 0; i < palette.length(); i++) {
				float dist = colorDistance(palette[i], color);
				if(dist < currentDistance) {
					currentDistance = dist;
					closestColor = palette[i];
				}
			}

			return closestColor;
		}

		void main() {
			vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
			col.rgb = conformColor(col.rgb);
			gl_FragColor = col;
		}
	')

	public function new() { super(); }
}