#include "/lib/all_the_libs.glsl"

in vec2 texcoord;
in vec4 glcolor;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = texture(gtexture, texcoord) * glcolor;
    Color *= ENCHANT_GLINT_OPACITY;
}
