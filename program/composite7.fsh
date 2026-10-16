#include "/lib/all_the_libs.glsl"
in vec2 texcoord;
in vec2 BloomTilePos;
#include "/global/post/bloom.glsl"

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    Color = texture(colortex0, texcoord);
    
    #ifdef BLOOM
    float Offset = 0;
    vec3 FinalBloom = blur3x3(colortex1, BloomTilePos).rgb;
    FinalBloom /= 3;

    float BloomFactor = get_luminance(FinalBloom) * BLOOM_CURVE + (1 - BLOOM_CURVE);
    BloomFactor += 0.2 * rainStrength * isOutdoorsSmooth;

    BloomFactor /= 1.667; // Reminder: remove this next major version

    Color.rgb = mix(Color.rgb, FinalBloom, BloomFactor * BLOOM_STRENGTH);
    #endif
}
