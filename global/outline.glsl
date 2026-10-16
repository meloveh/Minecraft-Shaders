vec3 get_outline(vec3 Color, vec3 ScreenPos) {
    const ivec2[4] Offsets = ivec2[4](
        ivec2(-1,-1) * OUTLINE_THICKNESS,
        ivec2(-1, 1) * OUTLINE_THICKNESS,
        ivec2(1, -1) * OUTLINE_THICKNESS,
        ivec2(1, 1) * OUTLINE_THICKNESS
    );
    vec4 DepthSamples = textureGatherOffsets(depthtex0, texcoord, Offsets);
    #ifdef DISTANT_HORIZONS
        float m = dot(step(vec4(1), DepthSamples), vec4(1));
        if(m > 0) {
            if(m < 4) return Color;
            DepthSamples = textureGatherOffsets(dhDepthTex0, texcoord, Offsets);
        }
    #endif
    float DepthAvgL = linearize_depth(dot(DepthSamples, vec4(0.25)));
    float DepthL = linearize_depth(ScreenPos.z);

    float Diff = DepthAvgL - DepthL;
    if(Diff > pow2(DepthL * 0.03) * OUTLINE_THRESHOLD) {
        Color *= OUTLINE_BRIGHTNESS;
    }
    return Color;
}