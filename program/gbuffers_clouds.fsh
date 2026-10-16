#include "/lib/all_the_libs.glsl"

#include "/global/gbuffers.fsh"

#if CLOUD_STYLE != 0
void main() {
	discard;
}
#else

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);

	#ifdef DISTANT_HORIZONS
		float DhDepth = texture(dhDepthTex0, ScreenPos.xy).x;
		if(DhDepth < 1) {
			discard;
			return;
		}
	#endif

	Color = texture(gtexture, texcoord) * glcolor;

	if(Color.a < alphaTestRef) {
        discard;
    }
	
	Color.rgb = to_linear(Color.rgb) * SKY_GROUND * 1.5;

	#ifdef BORDER_FOG
	vec3 ViewPos = screen_view(ScreenPos, false);
	vec3 PlayerPos = view_player(ViewPos, false);

	// No need to do length() here
	float HorizontalDist = len2(PlayerPos.xz);

	// Simplified fog, it doesn't need all of the fogs anyways
	#if MC_VERSION >= 12106
	HorizontalDist /= pow2(VANILLA_CLOUD_DISTANCE * 16);
	#else
	HorizontalDist /= pow2(far);
	#endif
	Color.a *= exp(-3.0 * HorizontalDist);
	Color.a *= 1-max(darknessFactor, blindness);
	#endif
}
#endif
