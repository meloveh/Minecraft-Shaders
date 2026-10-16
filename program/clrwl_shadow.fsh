#include "/lib/all_the_libs.glsl"
in vec2 texcoord;

/* RENDERTARGETS:0 */
layout(location = 0) out vec4 Color;

void main() {
    vec4 color = vec4(0,0,0,texture(gtexture, texcoord).a);
    vec2 lmcoord;
    float ao;
    vec4 overlayColor;

    clrwl_computeFragment(color, color, lmcoord, ao, overlayColor);
}
