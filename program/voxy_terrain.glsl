#define VOXY_TERRAIN

#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"
#include "/global/seasons.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void voxy_emitFragment(VoxyFragmentParameters param) {
    init_colors();
    map_voxy_param_to_varying(param);

    #ifdef SEASONS
        glcolor = get_seasons_color(glcolor);
    #endif

    Color = glcolor * param.sampledColour;

    if(Color.a < alphaTestRef) {
        discard;
    }

    Color.rgb *= glcolor.a;

    vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
    vec3 PlayerPos = view_player(screen_view(ScreenPos, true), true);

    Color.rgb = to_linear(Color.rgb);

    float Dither = dither(gl_FragCoord.xy);
    vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
    Color.xyz = TweakedLM;

    #ifdef PUDDLES
        Color.rgb += get_puddles(ScreenPos, ViewPos, PlayerPos, TBN, Dither);
    #endif
}