#include "/lib/all_the_libs.glsl"

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

out vec2 texcoord;

void main() {
	texcoord = get_texcoord(gl_TextureMatrix[0], gl_MultiTexCoord0);
	vec4 glcolor = gl_Color;
    float material = mc_Entity.x;

	vec3 ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

	#ifdef WAVY_PLANTS
    if (ViewPos.z > -64 && material >= 10002 && material <= 10006 && material != 10003) {
        vec3 WorldPos = view_player(ViewPos, false);
        WorldPos += cameraPosition;
        vec3 WavePos = WorldPos / WAVE_SIZE + frameTimeCounter * WAVE_SPEED + linstep(100, 150, WorldPos.y) * 0.1;
        WavePos = sin(WavePos);
        float Noise = WavePos.x * WavePos.y * WavePos.z;
        Noise *= WAVE_AMPLITUDE + rainStrength * 0.1;
        #ifdef WAVE_LEAVES
        if (material == 10002) {
            WorldPos.x += Noise / 2;
            WorldPos.zy -= Noise / 2;
        }
        else
        #endif
        if (material == 10004) {
            if (gl_MultiTexCoord0.t < mc_midTexCoord.t)
                WorldPos += Noise;
        }
        else if (material == 10005) {
            if (gl_MultiTexCoord0.t < mc_midTexCoord.t)
                WorldPos += Noise / 2;
        }
        else if (material == 10006) {
            if (gl_MultiTexCoord0.t > mc_midTexCoord.t)
                WorldPos += Noise / 2;
            else
                WorldPos += Noise;
        } 
        else if(material == 10001) {
            if(fract(WorldPos.y + 0.005) > 0.15) {
                WorldPos.y += Noise;
            }
        }

        WorldPos -= cameraPosition;
        WorldPos = mat3(gbufferModelView) * WorldPos;
        gl_Position = gl_ProjectionMatrix * vec4(WorldPos, 1);
    } else 
    #endif
        gl_Position = ftransform();
    
    

    gl_Position.xyz = distort(gl_Position.xyz);
}
