#ifndef VOXY_TERRAIN
    flat in float material;
    in vec2 LightmapCoords;
    in vec2 texcoord;
    in vec4 glcolor;
    in vec3 ViewPos;
    in vec3 Normal;
    in vec4 Tangent;

    flat in vec3 SUN_DIRECT;
    flat in vec3 SUN_AMBIENT;
    flat in vec3 SKY_TOP;
    flat in vec3 SKY_GROUND;
    
    vec2 dCoordx = dFdx(texcoord), dCoordy = dFdy(texcoord);
#else
    float material;
    vec2 LightmapCoords;
    vec2 texcoord;
    vec4 glcolor;
    vec3 ViewPos;
    mat3 TBN;
    #include "/global/light_colors.vsh"

    void map_voxy_param_to_varying(VoxyFragmentParameters param) {
        texcoord = param.uv;
        LightmapCoords = param.lightMap;
        material = param.customId;
        glcolor = param.tinting;
        ViewPos = screen_view(vec3(gl_FragCoord.xy * resolutionInv, gl_FragCoord.z), true);
        // from Cortex
        vec3 normal = vec3(
                        uint((param.face >> 1) == 2),
                        uint((param.face >> 1) == 0),
                        uint((param.face >> 1) == 1)
                    ) *
            (float(int(param.face) & 1) * 2.0 - 1.0);
        if(material >= 10003 && material <= 10006) {
            normal = vxModelView[1].xyz;
        }
        TBN = tbnNormal(player_view(normal, true));
    }
#endif


#include "/global/sky.glsl"
#include "/global/pbr.glsl"
#include "/global/shadows.glsl"
#include "/global/water.glsl"
#include "/global/lighting.glsl"

vec3 get_puddles(vec3 ScreenPos, vec3 ViewPos, vec3 PlayerPos, mat3 TBN, float Dither) {
    float PuddleStrength = wetness; // Only after it's raining
    if(PuddleStrength < 0.01) return vec3(0);

    vec3 WorldPos = PlayerPos + cameraPosition;
    PuddleStrength *= texture(noisetex, WorldPos.xz / 50).r;
    PuddleStrength *= linstep(0.9, 0.95, LightmapCoords.y); // Not in the shade
    PuddleStrength *= step(material, 10002); // Not on grass
    PuddleStrength *= step(0.99, dot(gbufferModelView[1].xyz, TBN[2]));
    PuddleStrength = smoothstep(1 - PUDDLE_COVERAGE, 1 - PUDDLE_COVERAGE + 0.03, PuddleStrength);
    if(PuddleStrength < 0.01) return vec3(0);

    vec4 WaterColor = get_fancy_water(ScreenPos, ViewPos, normalize(ViewPos), PlayerPos, vec4(0), LightmapCoords.y, TBN, Dither, false);
    return WaterColor.rgb * PuddleStrength;
}
