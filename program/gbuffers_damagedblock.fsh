#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    Color = glcolor * texture(gtexture, texcoord);
    if(Color.a < 0.1) {
        discard;
    }
    Color.rgb = to_linear(Color.rgb);
}
