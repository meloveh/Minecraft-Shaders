#include "/lib/all_the_libs.glsl"


#include "/global/gbuffers.fsh"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = texture(gtexture, texcoord) * glcolor;
	if (Color.a < alphaTestRef) {
		discard; 
	}
}
