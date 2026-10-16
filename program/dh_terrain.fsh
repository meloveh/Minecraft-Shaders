#define DH_TERRAIN

#include "/lib/all_the_libs.glsl"


#include "/global/gbuffers.fsh"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    vec3 ScreenPos = vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z);
    vec3 PlayerPos = view_player(ViewPos, true);

    float Dither = dither(gl_FragCoord.xy);
    if (!transition_to_dh(PlayerPos, true, Dither)) {
        discard;
    }

    Color = glcolor;

    #ifdef DH_NOISE
        Color.rgb = dh_noise(PlayerPos, Color.rgb);
    #endif

    Color.rgb = to_linear(Color.rgb);

    mat3 TBN = tbn_decode(Normal, Tangent);
    vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
    Color.xyz = TweakedLM;
    
    #ifdef PUDDLES
        Color.rgb += get_puddles(ScreenPos, ViewPos, PlayerPos, TBN, Dither);
    #endif
}
