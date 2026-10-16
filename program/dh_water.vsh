#define DH_TERRAIN

#include "/lib/all_the_libs.glsl"
#include "/global/gbuffers.vsh"

void main() {
    init_generic();

    if(dhMaterialId == DH_BLOCK_WATER) {
        material = 10001;
    }
    #if WATER_TEXTURE_MODE == 1 || WATER_TEXTURE_MODE == 2
    // transfer water color through glcolor. should be faster
    if(material == 10001) {
        const vec4 BaseColor = vec4(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE, f_WATER_ALPHA);
        glcolor.rgb = mix_preserve_c1lum(BaseColor.rgb, glcolor.rgb, f_BIOME_WATER_CONTRIBUTION);
        glcolor.rgb = to_linear(glcolor.rgb);
        glcolor.a = BaseColor.a;
    }
    #else
    glcolor.rgb = to_linear(glcolor.rgb);
    #endif

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
