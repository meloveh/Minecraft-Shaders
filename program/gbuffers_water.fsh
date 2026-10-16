#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"
#include "/global/fog.glsl"

vec4 get_translucent_basic(vec3 ScreenPos, vec3 PlayerPos, mat3 TBN, float Dither) {
	vec4 Color = glcolor * texture(gtexture, texcoord);
	if (Color.a < alphaTestRef) {
		discard;
	}
	Color.rgb = to_linear(Color.rgb);

	vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
	Color.rgb = TweakedLM;
	
	return Color;
}

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
	vec3 ViewPos = screen_view(ScreenPos, false);
	vec3 PlayerPos = view_player(ViewPos, false);

	float Dither = dither(gl_FragCoord.xy);
	#if (defined DISTANT_HORIZONS) && (!defined VOXY)

	// this pass now comes AFTER dh_water for some reason???????????????????????
	// i give up
    if (transition_to_dh(PlayerPos, false, Dither)) {
		discard;
    }
    #endif


	vec3 ViewPosN = normalize(ViewPos);

	mat3 TBN = tbn_decode(Normal, Tangent);
	if(material == 10001) {
		// glcolor gets set to water color in vsh
		#if WATER_TEXTURE_MODE == 2
			vec4 BaseColor = vec4(glcolor.rgb, glcolor.a);
		#else
			Color = texture(gtexture, texcoord);
			Color.rgb = to_linear(Color.rgb);
			#if WATER_TEXTURE_MODE == 1
				Color.rgb += 0.5;
				Color.a = 1; 
			#endif
			vec4 BaseColor = Color * glcolor;
		#endif
		vec3 TweakedLM = tweak_lightmap(BaseColor.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, Dither, 1);
		BaseColor.rgb = TweakedLM;
		Color = get_fancy_water(ScreenPos, ViewPos, ViewPosN, PlayerPos, BaseColor, LightmapCoords.y, TBN, Dither, false);
	}
	else {
		Color = get_translucent_basic(ScreenPos, PlayerPos, TBN, Dither);
	}

	float VdotL = dot(ViewPosN, sunPosN);
	vec3 SkyColor = get_sky_main(ViewPosN, normalize(PlayerPos), get_sun_glare(VdotL));
    Color.rgb = get_fog_main(ScreenPos, PlayerPos, Color.rgb, gl_FragCoord.z, SkyColor, VdotL, Dither, false);
}
