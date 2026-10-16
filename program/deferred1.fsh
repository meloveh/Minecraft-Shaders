#define DEFERRED

#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"
#include "/global/fog.glsl"
#include "/global/post/ssao.glsl"
#include "/global/outline.glsl"

// Sky, Clouds, etc

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    Color = texture(colortex0, texcoord);
    bool IsDH;
    float Depth = get_depth(texcoord, IsDH);
    vec3 ScreenPos = vec3(texcoord, Depth);
    vec3 ViewPos = screen_view(ScreenPos, IsDH);

    vec3 PlayerPos = mat3(gbufferModelViewInverse) * ViewPos;

    vec3 ViewPosN = normalize(ViewPos);
    vec3 PlayerPosN = normalize(PlayerPos);

    float VdotL = dot(ViewPosN, sunPosN);
    vec3 SunGlare = get_sun_glare(VdotL);

    vec3 SkyColor = get_sky_main(ViewPosN, PlayerPosN, SunGlare);
    SkyColor += (ign(gl_FragCoord.xy, false) - 0.5) / 255;

    float Dither = dither(gl_FragCoord.xy);

    if (Depth >= 1) {
        #ifndef CUSTOM_SKYBOXES
            #ifndef DIMENSION_OVERWORLD
            Color = vec4(0, 0, 0, 1);
            #elif defined ROUND_SUN
            SkyColor += round_sun(VdotL);
            #endif

            #ifdef DEBUG_OVERRIDE_SKY
            Color.rgb = SkyColor;
            #else
            Color.rgb += SkyColor;
            #endif

            if (PlayerPos.y > 0) {
                #if defined DIMENSION_OVERWORLD || defined DIMENSION_END
                Color.rgb += get_stars(PlayerPos);
                #endif

                #ifdef DIMENSION_OVERWORLD
                    Color.rgb = get_clouds(ViewPosN, PlayerPos, PlayerPosN, SunGlare, Color.rgb, Dither);

                    #ifdef AURORA_BOREALIS
                        Color.rgb += get_aurora(PlayerPosN, Dither);
                    #endif
                #endif
            }
        #endif
    }
    
    else if (Depth >= 0.56) { // Skip hand & sky
        #ifdef SSAO
            Color.rgb = ssao(Color.rgb, ViewPos, Dither, IsDH);
        #elif (defined DISTANT_HORIZONS) && (defined SSAO_ON_LODS)
            if(IsDH)
                Color.rgb = ssao(Color.rgb, ViewPos, Dither, IsDH);
        #endif
        #ifdef OUTLINE
            Color.rgb = get_outline(Color.rgb, ScreenPos);
        #endif
    }

    if (Depth >= 0.56) { // Skip JUST the hand
        Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, Depth, SkyColor, VdotL, Dither, IsDH);
        #if RAINBOWS > 0
            Color.rgb += get_rainbow(PlayerPos, PlayerPosN);
        #endif
    }

    #ifdef VOXY
        if(texture(depthtex1, texcoord).r >= 1) {
            vec4 VxData = texture(colortex16, texcoord);
            Color.rgb = mix(Color.rgb, VxData.rgb, VxData.a);
        }
    #endif 
}
