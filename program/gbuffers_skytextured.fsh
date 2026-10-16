#include "/lib/all_the_libs.glsl"
in vec2 texcoord;
in vec4 glcolor;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	#ifndef CUSTOM_SKYBOXES
		#ifdef ROUND_SUN
		discard; return;
		#endif
	#endif	
	Color = texture(gtexture, texcoord) * glcolor;


	Color.rgb = to_linear(Color.rgb);

	#ifdef CUSTOM_SKYBOXES
		Color.rgb *= CUSTOM_SKYBOX_BRIGHTNESS;
	#endif
}
