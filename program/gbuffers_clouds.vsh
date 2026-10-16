#include "/lib/all_the_libs.glsl"
#include "/global/light_colors.vsh"

out vec2 texcoord;
out vec4 glcolor;

void main() {
	#if CLOUD_STYLE != 0
		gl_Position = vec4(-1);
	#else
		gl_Position = ftransform();
		init_colors();
		texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);
		glcolor = gl_Color;
		#if TAA_MODE >= 2
		gl_Position.xy += taaJitter * gl_Position.w;
		#endif
	#endif
}
