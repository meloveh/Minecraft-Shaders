#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.vsh"
#include "/global/seasons.glsl"

void main() {
    init_generic();

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
