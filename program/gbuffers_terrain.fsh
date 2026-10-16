#define GBUFFERS_TERRAIN

#include "/lib/all_the_libs.glsl"


#include "/global/gbuffers.fsh"
#include "/global/fog.glsl"

flat in vec2 AtlasScale;
flat in vec2 AtlasOffset;
in vec3 TangentPos;
in vec3 TangentLightPos;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

vec3 end_portal_shader(vec3 WorldPos, vec3 PlayerPosN, vec3 WorldNormal) {
    vec2 Pos, Dir;
    if(abs(WorldNormal.y) < 0.01) {
        if(abs(WorldNormal.x) < 0.5) {
            Pos = WorldPos.xy * sign(-WorldNormal.z);
            Dir = PlayerPosN.xy  / PlayerPosN.z;
        } else {
            Pos = WorldPos.yz * sign(-WorldNormal.x);
            Dir = PlayerPosN.yz / PlayerPosN.x;
        }
    } else {
        Pos = WorldPos.xz;
        Dir = PlayerPosN.xz / PlayerPosN.y * sign(-WorldNormal.y);
    }

    vec3 StarColor = to_linear(vec3(0.5, 0.7, 0.5) * 2.);
    vec3 StarColorChange = to_linear(vec3(0.6, 0.55, 0.8));
    vec2 Wind = vec2(1, 1);

    Dir *= 0.2;
    for(int i = 1; i <= 6; i++) {
        Dir *= 1.75;
        Pos += Dir;
        StarColor *= StarColorChange;
        vec2 StarPos = floor(Pos * 15 + Wind * (frameTimeCounter + 100)) / 10000;
        float Noise = random(StarPos);
        if(Noise > 0.97) {
            return StarColor;
        }
        Wind.y *= Wind.x;
        Wind.x *= -1;
        
    }
    return vec3(0);
}

#if (defined PBR_POM) && (defined PBR_NORMAL)
    vec2 to_local_pos(vec2 texcoord) {
        return (texcoord - AtlasOffset) / AtlasScale; 
    }

    vec2 from_local_pos(vec2 LocalPos) {
        return fract(LocalPos) * AtlasScale + AtlasOffset;
    }

    vec2 pom(inout float Shadow) {
        // Distance fade
        float Dist = len2(ViewPos);
        if(Dist > pow2(12)) return texcoord;

        float Height = 1-textureGrad(normals, texcoord, dCoordx, dCoordy).a;
        if(Height < 1/255.0) {
            return texcoord;
        }

        int StepCount = PBR_POM_STEPS;

        vec3 TangentPos = normalize(TangentPos);
        vec3 Offset = vec3(TangentPos.xy / -TangentPos.z * PBR_POM_MAX_DEPTH, 1) / StepCount;
        float Dither = dither(gl_FragCoord.xy);
        vec3 CurrentPos = vec3(to_local_pos(texcoord) + Offset.xy * Dither, 0); 
        
        for(int i = 0; i < StepCount && Height - CurrentPos.z > 1./255.0; i++) {
            vec2 NewPos = from_local_pos(CurrentPos.xy);            
            Height = 1 - textureGrad(normals, NewPos, dCoordx, dCoordy).a;
            CurrentPos += Offset;
        }
        
        // Need to move back one here
        CurrentPos -= Offset;

        #ifdef POM_SHADOWING
            vec3 OffsetL = normalize(TangentLightPos) * length(Offset) * 2;
            vec3 LightPos = vec3(CurrentPos.xy + OffsetL.xy * max(0.01, Dither), CurrentPos.z);
            float HeightL = 1 - textureGrad(normals, from_local_pos(LightPos.xy), dCoordx, dCoordy).a;
            Shadow = float(LightPos.z - HeightL < 1/255.0);
            Shadow = mix(Shadow, 1, linstep(100, 144, Dist));
        #endif


        return from_local_pos(CurrentPos.xy);
    }
#endif

void main() {
    float _PomShadow = 1;
    #if (defined PBR_POM) && (defined PBR_NORMAL)
        vec2 Texcoord = pom(_PomShadow);
        Color = textureGrad(gtexture, Texcoord, dCoordx, dCoordy);   
    #else
        vec2 Texcoord = texcoord;
        Color = texture(gtexture, Texcoord);   
    #endif

    #ifndef GBUFFERS_TERRAIN_SOLID
        if(Color.a < alphaTestRef) {
            discard;
        }
    #endif

    Color.rgb *= glcolor.rgb * glcolor.a;

    vec3 ScreenPos = vec3(gl_FragCoord.xy*resolutionInv, gl_FragCoord.z);
    vec3 PlayerPos = view_player(ViewPos, false);

    float Dither = dither(gl_FragCoord.xy);
    #if (defined DISTANT_HORIZONS) && (!defined VOXY)
        if (transition_to_dh(PlayerPos, false, Dither)) {
            discard;
        }
    #endif

    mat3 TBN = tbn_decode(Normal, Tangent);
    // End portal effect
    if(material == 10007) {
        Color.rgb = end_portal_shader(PlayerPos + cameraPosition, normalize(PlayerPos), view_player(TBN[2], false));
    } else {
        Color.rgb = to_linear(Color.rgb);

        vec3 TweakedLM = tweak_lightmap(Color.rgb, PlayerPos, LightmapCoords, Texcoord, ScreenPos, TBN, Dither, _PomShadow);
        Color.xyz = TweakedLM;

        #ifdef PUDDLES
            Color.rgb += get_puddles(ScreenPos, ViewPos, PlayerPos, TBN, Dither);
        #endif

    }
}
