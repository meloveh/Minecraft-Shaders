float shadow_fade(vec3 PlayerPos, float Dist) {
    #ifdef DISTANT_HORIZONS
        Dist = min(far, Dist);
    #endif
    return smoothstep(Dist - 32, Dist, len_sq(PlayerPos));
}

float shadow_blur(vec3 SampleCoord, float Radius) {
    vec3 Off1 = vec3(-0.33, 1.0, 0) / shadowMapResolution * Radius;
    vec3 Off2 = vec3(1.0, 0.33, 0) / shadowMapResolution * Radius;
    float Color = texture(shadowtex0, SampleCoord) * 0.25;
    Color += texture(shadowtex0, SampleCoord + Off1) * 0.1875;
    Color += texture(shadowtex0, SampleCoord - Off1) * 0.1875;
    Color += texture(shadowtex0, SampleCoord + Off2) * 0.1875;
    Color += texture(shadowtex0, SampleCoord - Off2) * 0.1875;
    return Color;
}

float pcf(float PenumbraSize, vec3 ShadowPosUndistorted, float Dither) {
    const int SAMPLE_COUNT = 8;
    
    Dither = Dither * TAU;
    vec2 Offset = vec2(cos(Dither), sin(Dither)) / shadowMapResolution;
    mat2 RotationOffset = mat2(
            Offset.x, Offset.y,
            -Offset.y, Offset.x
        );

    float ShadowColorFinal = 0;
    for (int i = 0; i < SAMPLE_COUNT; i++) {
        vec2 OffsetP = RotationOffset * vogel_disk[i] * PenumbraSize;
        vec3 ShadowPosD = ShadowPosUndistorted + vec3(OffsetP, 0);
        ShadowPosD = distort(ShadowPosD);

        ShadowPosD = ShadowPosD * 0.5 + 0.5; //convert from shadow ndc space to shadow screen space.
        ShadowColorFinal += texture(shadowtex0, ShadowPosD);
    }
    return ShadowColorFinal / SAMPLE_COUNT;
}

float get_shadow_static(float Skylight) {
    // This cuts off direct sunlight it semi-occulded areas.
    return smoothstep(0.85, 0.96, Skylight);
}

float get_shadow_dynamic(vec3 ViewPos, vec3 PlayerPos, bool IsDH, vec3 FlatNormal, float NdotL, float Skylight, bool DoSSS, float Dither) {
    #ifdef DIMENSION_NETHER
        return 0.0;
    #endif

    vec3 bias = compute_bias(PlayerPos + gbufferModelViewInverse[3].xyz, view_player(FlatNormal, IsDH), NdotL, Skylight);
    if (DoSSS) {
        bias *= vec3(0.05);
    }

    vec3 ShadowPosUndistorted = player_shadow(PlayerPos + bias);
   
    vec3 ShadowPos = distort(ShadowPosUndistorted);
    ShadowPos = ShadowPos * 0.5 + 0.5;

    float ShadowFinal;
    #if SHADOW_FILTER > 0
        float PenumbraSize = DoSSS ? 5 : 1;
        #if SHADOW_FILTER == 1
            ShadowFinal = shadow_blur(ShadowPos, PenumbraSize);
        #else
            ShadowFinal = pcf(PenumbraSize * 2 * PCF_STRENGTH, ShadowPosUndistorted, Dither);
        #endif
    #else
        ShadowFinal = texture(shadowtex0, ShadowPos);
    #endif

    return ShadowFinal;
}
