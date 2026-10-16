#define VOXY_TERRAIN

#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"
#include "/global/fog.glsl"

vec4 get_translucent_basic(VoxyFragmentParameters param, vec3 ScreenPos, vec3 PlayerPos, float Dither) {
	vec4 Color = vec4(glcolor.rgb, 1) * param.sampledColour;
	Color.rgb *= glcolor.a;
	Color.rgb = to_linear(Color.rgb);

	vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
	Color.rgb = TweakedLM;
	return Color;
}

/* RENDERTARGETS:16 */
layout(location = 0) out vec4 Color;

void voxy_emitFragment(VoxyFragmentParameters param) {
    init_colors();
    map_voxy_param_to_varying(param);
	vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
	vec3 ViewPos = screen_view(ScreenPos, true);
	vec3 ViewPosN = normalize(ViewPos);
	vec3 PlayerPos = view_player(ViewPos, true);

    float Dither = dither(gl_FragCoord.xy);

	if(material == 10001) {
        #if WATER_TEXTURE_MODE == 1 || WATER_TEXTURE_MODE == 2
        if(material == 10001) {
            const vec4 BaseColor = vec4(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE, f_WATER_ALPHA);
            glcolor.rgb = mix_preserve_c1lum(BaseColor.rgb, glcolor.rgb, f_BIOME_WATER_CONTRIBUTION);
            glcolor.rgb = to_linear(glcolor.rgb);
            glcolor.a = BaseColor.a;
        }
        #else
        glcolor.rgb = to_linear(glcolor.rgb);
        #endif
        
		#if WATER_TEXTURE_MODE == 2
			vec4 BaseColor = vec4(glcolor.rgb*TweakedLM, glcolor.a);
		#else
			Color = param.sampledColour;
			Color.rgb = to_linear(Color.rgb);
			#if WATER_TEXTURE_MODE == 1
				Color.rgb += 0.5;
				Color.a = 1; 
			#endif
			vec4 BaseColor = Color * glcolor;
		#endif
		BaseColor.rgb = tweak_lightmap(BaseColor.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
		Color = get_fancy_water(ScreenPos, ViewPos, ViewPosN, PlayerPos, BaseColor, LightmapCoords.y, TBN, Dither, true);
	}
	else {
		Color = get_translucent_basic(param, ScreenPos, PlayerPos, Dither);
	}

	float VdotL = dot(ViewPosN, sunPosN);
	vec3 SkyColor = get_sky_main(ViewPosN, normalize(PlayerPos), get_sun_glare(VdotL));
    Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, gl_FragCoord.z, SkyColor, VdotL, Dither, true);
}
