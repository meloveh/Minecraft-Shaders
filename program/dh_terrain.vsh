#define DH_TERRAIN

#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.vsh"
#include "/global/seasons.glsl"

void main() {
    init_generic();

    #ifdef SEASONS
        if(dhMaterialId == DH_BLOCK_LEAVES || dhMaterialId == DH_BLOCK_GRASS)
            glcolor = get_seasons_color(glcolor);
    #endif


    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
