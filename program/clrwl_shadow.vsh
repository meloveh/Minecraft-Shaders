#include "/lib/all_the_libs.glsl"

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

out vec2 texcoord;


void main() {
	texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);

    gl_Position = ftransform();
    

    gl_Position.xyz = distort(gl_Position.xyz);
}
