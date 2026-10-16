#include "/lib/all_the_libs.glsl"

#undef PBR_NORMAL
#undef PBR_SPECULAR

#include "/global/gbuffers.fsh"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = texture(gtexture, texcoord) * glcolor;
	if (Color.a < 0.1) {
		discard;
	}
	Color.rgb = to_linear(Color.rgb);

	vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
	vec3 PlayerPos = view_player(ViewPos, false);
	mat3 TBN = tbn_decode(Normal, Tangent);
	vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, texcoord, ScreenPos, TBN, 0, 1);
	Color.xyz = TweakedLM;
	

	Color = vec4(apply_saturation(Color.rgb, 0.2), 0.15);
}
