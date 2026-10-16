#include "/lib/all_the_libs.glsl"

in vec2 texcoord;

vec3 chromatic_aberration(vec2 texcoord) {
    vec2 Offset = (vec2(0.5) - texcoord) * CA_STRENGTH * 0.005;
    vec3 Color;
    Color.r = textureLod(colortex0, texcoord - Offset, 0).r;
    Color.g = textureLod(colortex0, texcoord, 0).g;
    Color.b = textureLod(colortex0, texcoord + Offset, 0).b;
    return Color;
}

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    Color = vec4(chromatic_aberration(texcoord), 1);
}
