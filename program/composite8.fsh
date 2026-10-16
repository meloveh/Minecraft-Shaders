#include "/lib/all_the_libs.glsl"

in vec2 texcoord;

#include "/global/post/taa.glsl"

#if TAA_MODE != 0 || REFLECTIONS >= 2
/* DRAWBUFFERS:04 */
layout(location = 1) out vec4 TaaData;
#else
/* DRAWBUFFERS:0 */
#endif
layout(location = 0) out vec4 Color;

// Color grading, Bloom final, TAA final

vec3 motion_blur(vec3 Color, vec2 PrevCoord, vec2 CurrentCoord) {
    vec2 Velocity = PrevCoord - CurrentCoord;
    vec2 Offset = Velocity / 4 * MOTION_BLUR_STRENGTH;
    Offset *= 0.01666 / frameTime; // Adjust based on framerate. 60 fps is the baseline
    vec3 Blur = Color;

    float Noise = dither(gl_FragCoord.xy);
    CurrentCoord += Offset * Noise;

    for (int i = 1; i < 4; i++) {
        Blur += texture(colortex0, CurrentCoord).rgb;
        CurrentCoord += Offset;
    }
    return Blur / 4;
}

void main() {
    Color = texture(colortex0, texcoord);

    #if TAA_MODE != 0 || defined MOTION_BLUR
    bool IsDH;
    float Depth = get_depth_solid(texcoord, IsDH);
    vec2 PrevCoord = toPrevScreenPos(texcoord, Depth, IsDH);
    #endif

    #ifdef MOTION_BLUR
    if (Depth >= 0.56) {
        Color.rgb = motion_blur(Color.rgb, PrevCoord, texcoord);
    }
    #endif

    #if TAA_MODE == 4
        TaaData = Color;
        TAA(Color.rgb, vec3(texcoord, Depth), PrevCoord, IsDH);
    #elif TAA_MODE != 0
        TaaData.rgb = TAA(Color.rgb, vec3(texcoord, Depth), PrevCoord, IsDH);
    #elif REFLECTIONS >= 2
        TaaData = Color;
    #endif

    Color.rgb *= EXPOSURE;
    Color.rgb = apply_tonemap(Color.rgb);

    #ifdef SMAA
        Color.rgb = pow(Color.rgb, vec3(1 / 2.2)); // Gamma correction
    #endif

    #if DEBUG_SHOW_BUFFER == 0
        Color = Color;
    #elif DEBUG_SHOW_BUFFER == 1
        Color = texelFetch(colortex1, ivec2(gl_FragCoord.xy), 0);
    #elif DEBUG_SHOW_BUFFER == 2
        Color = texelFetch(noisetex, ivec2(gl_FragCoord.xy), 0);
    #elif DEBUG_SHOW_BUFFER == 3
        Color = texelFetch(depthtex0, ivec2(gl_FragCoord.xy), 0);
    #else
        Color = texelFetch(gaux1, ivec2(gl_FragCoord.xy), 0);
    #endif
}