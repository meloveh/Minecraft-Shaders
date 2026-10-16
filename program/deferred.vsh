#include "/lib/all_the_libs.glsl"

out vec2 texcoord;

void main() {
    gl_Position = ftransform();
	texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);
}
