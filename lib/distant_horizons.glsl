vec3 dh_noise(vec3 PlayerPos, vec3 Color) {
    vec3 WorldPos = PlayerPos + cameraPosition + gbufferModelViewInverse[3].xyz;
    vec3 NoisePos = floor(WorldPos * DH_NOISE_SIZE + 0.001) / DH_NOISE_SIZE;
    Color *= exp(-random3D(NoisePos) / 4) + 0.104;
    return Color;
}

bool transition_to_dh(vec3 PlayerPos, const bool IsDHPass, float Dither) {
    float Bias = float(IsDHPass) * far / 32; // Needed because of depth imprecision i think
    float Fade = Dither * 8;
    return length(PlayerPos) > far - DH_CUTOFF - Bias + Fade;
}

float ld_exact(float depth, bool IsDH) {
    if (!IsDH)
        return (near * far) / (depth * (near - far) + far);
    else
        return (near * dhRenderDistance) / (depth * (near - dhRenderDistance) + dhRenderDistance);
}

float get_depth_solid(vec2 ScreenPos, out bool IsDH) {
    float Depth = texture(depthtex1, ScreenPos).x;
    IsDH = false;
    // Fix for AMD's electriic boogaloo (from Eldeston)
    #ifdef MC_GL_RENDERER_RADEON
        if(Depth <= 0) Depth = 1.0;
    #endif
    #ifdef DISTANT_HORIZONS
        if (Depth >= 1) {
            Depth = texture(dhDepthTex1, ScreenPos).x;
            IsDH = true;
            #ifdef MC_GL_RENDERER_RADEON
                if(Depth <= 0) Depth = 1.0;
            #endif
        }
    #endif
    return Depth;
}

float get_depth(vec2 ScreenPos, out bool IsDH) {
    #if (defined DEFERRED) && (defined VOXY)
        return get_depth_solid(ScreenPos, IsDH);
    #endif
    float Depth = texture(depthtex0, ScreenPos).x;
    IsDH = false;
    // Fix for AMD's electriic boogaloo (from Eldeston)
    #ifdef MC_GL_RENDERER_RADEON
        if(Depth <= 0) Depth = 1.0;
    #endif
    #ifdef DISTANT_HORIZONS
        if (Depth >= 1) {
            Depth = texture(dhDepthTex0, ScreenPos).x;
            IsDH = true;
            #ifdef MC_GL_RENDERER_RADEON
                if(Depth <= 0) Depth = 1.0;
            #endif
        }
    #endif
    return Depth;
}

float get_depth_solid_lq(vec2 ScreenPos, out bool IsDH) {
    #ifdef USE_LQ_DEPTH
        float Depth = texture(colortex5, ScreenPos).x;
    #else
        float Depth = texture(depthtex1, ScreenPos).x;
    #endif
    IsDH = false;
    // Fix for AMD's electriic boogaloo (from Eldeston)
    #ifdef MC_GL_RENDERER_RADEON
        if(Depth <= 0) Depth = 1.0;
    #endif
    #ifdef DISTANT_HORIZONS
        if (Depth >= 1) {
            #ifdef USE_LQ_DEPTH
                Depth = texture(colortex5, ScreenPos).y;
            #else
                Depth = texture(dhDepthTex1, ScreenPos).x;
            #endif
            IsDH = true;
            #ifdef MC_GL_RENDERER_RADEON
                if(Depth <= 0) Depth = 1.0;
            #endif
        }
    #endif
    return Depth;
}

float get_depth_lq(vec2 ScreenPos, out bool IsDH) {
    #if (defined DEFERRED) && (defined VOXY)
        return get_depth_solid_lq(ScreenPos, IsDH);
    #endif
    #ifdef USE_LQ_DEPTH
        float Depth = texture(colortex5, ScreenPos).x;
    #else
        float Depth = texture(depthtex0, ScreenPos).x;
    #endif
    IsDH = false;
    // Fix for AMD's electriic boogaloo (from Eldeston)
    #ifdef MC_GL_RENDERER_RADEON
        if(Depth <= 0) Depth = 1.0;
    #endif
    #ifdef DISTANT_HORIZONS
        if (Depth >= 1) {
            #ifdef USE_LQ_DEPTH
                Depth = texture(colortex5, ScreenPos).y;
            #else
                Depth = texture(dhDepthTex0, ScreenPos).x;
            #endif
            IsDH = true;
            #ifdef MC_GL_RENDERER_RADEON
                if(Depth <= 0) Depth = 1.0;
            #endif
        }
    #endif
    return Depth;
}

#ifdef DISTANT_HORIZONS
    #define furthest dhRenderDistance
#else
    #define furthest far
#endif