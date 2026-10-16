#include "/lib/all_the_libs.glsl"

out vec2 texcoord;
void main() {
    gl_Position = ftransform();
    texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);
    gl_Position = gl_Position * 0.5 + 0.5;

    const float TileSize = 128;
    vec2 TileSizeClamped = vec2(aspectRatio, 1) * vec2(TileSize);
    float Scale = max(1, min_component(TileSizeClamped) / min_component(resolution * 0.5));
    gl_Position.xy *= TileSizeClamped / Scale * resolutionInv;

    gl_Position = gl_Position * 2 - 1;
}
