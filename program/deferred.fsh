#include "/lib/all_the_libs.glsl"

// Quarter-resolution depth buffer

/* DRAWBUFFERS:5 */
layout(location = 0) out vec4 Color;

in vec2 texcoord;

void main() {
    Color.r = textureOffset(depthtex0, texcoord, ivec2(-1, -1)).r;
    Color.r = max(Color.r, textureOffset(depthtex0, texcoord, ivec2(-1, 1)).r);
    Color.r = max(Color.r, textureOffset(depthtex0, texcoord, ivec2(1, -1)).r);
    Color.r = max(Color.r, textureOffset(depthtex0, texcoord, ivec2(1, 1)).r);

    #ifdef DISTANT_HORIZONS
    Color.g = textureOffset(dhDepthTex0, texcoord, ivec2(-1, -1)).r;
    Color.g = max(Color.g, textureOffset(dhDepthTex0, texcoord, ivec2(-1, 1)).r);
    Color.g = max(Color.g, textureOffset(dhDepthTex0, texcoord, ivec2(1, -1)).r);
    Color.g = max(Color.g, textureOffset(dhDepthTex0, texcoord, ivec2(1, 1)).r);
    #endif
}