#include "/lib/all_the_libs.glsl"

#include "/global/post/bloom.glsl"

out vec2 texcoord;
out vec2 BloomTilePos;

void main() {
	gl_Position = ftransform();

	texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);

    BloomTilePos = adjust_vertex_position(128, 0.5, 0, texcoord);
}
