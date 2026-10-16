#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    Color = texture(gtexture, texcoord) * glcolor;

    if(Color.a < alphaTestRef) {
        discard;
    }

    vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
    vec3 PlayerPos = view_player(ViewPos, false);

    float Dither = dither(gl_FragCoord.xy);
    #if (defined DISTANT_HORIZONS) && (!defined VOXY)
        if (transition_to_dh(PlayerPos, false, Dither)) {
            discard;
        }
    #endif
    
    Color.rgb = to_linear(Color.rgb);

    Color.xyz = mix(Color.rgb, entityColor.rgb, entityColor.a);
    mat3 TBN = tbn_decode(Normal, Tangent);
    vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
    Color.xyz = TweakedLM;
}
