#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.vsh"

void main() {
	gl_Position = ftransform();
	texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);
	glcolor = gl_Color;
	#if TAA_MODE >= 2
	gl_Position.xy += taaJitter * gl_Position.w;
	#endif
}
