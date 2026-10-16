#include "/lib/all_the_libs.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

in vec4 starData;

void main() {
	#ifdef CUSTOM_SKYBOXES
	if (starData.a > 0.5) {
		Color = vec4(starData.rgb * 0.25 * CUSTOM_SKYBOX_BRIGHTNESS, 1);
	}
	else
	#endif
	Color = vec4(0, 0, 0, 0);
}
