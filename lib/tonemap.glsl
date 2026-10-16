vec3 apply_tonemap(vec3 X) {
    #if TONEMAP_OPERATOR == 1
    return ACESFilm(X);
    #elif TONEMAP_OPERATOR == 2
    return reinhard_jodie(X);
    #elif TONEMAP_OPERATOR == 3
    return ACES_slow(X);
    #elif TONEMAP_OPERATOR == 4
    return Hejl2015(X);
    #elif TONEMAP_OPERATOR == 5
    return Lottes(X);
    #elif TONEMAP_OPERATOR == 6
    return Uchimura(X);
    #elif TONEMAP_OPERATOR == 7
    return agxPunchy(X);
    #elif TONEMAP_OPERATOR == 8
    return PBRNeutralToneMapping(X);
    #endif
}

vec3 apply_saturation(vec3 Color, float Sat) {
    float luminance = get_luminance(Color);
    return mix(vec3(luminance), Color, Sat);
}

vec3 apply_vibrance(vec3 color, float intensity) {
    float mn = min(color.r, min(color.g, color.b));
    float mx = max(color.r, max(color.g, color.b));
    float sat = (1.0 - clamp(mx - mn, 0, 1)) * clamp(1.0 - mx, 0, 1) * get_luminance(color) * 5.0;
    vec3 lightness = vec3((mn + mx) * 0.5);

    return mix(color, mix(lightness, color, intensity), sat);
}

vec3 apply_contrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

// Mix colors, preserving the luminance of c1
vec3 mix_preserve_c1lum(vec3 C1, vec3 C2, float Weight) {
    float L1 = get_luminance(C1);

    vec3 CMixed = mix(C1, C2, Weight);
    float L = get_luminance(CMixed) + 1e-6;

    float Scale = L1 / L;

    return CMixed * Scale;
}

vec3 tint_underwater(vec3 FinalColor) {
    if (isEyeInWater == 1) {
        vec3 WaterColor = to_linear(vec3(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE));
        WaterColor = mix_preserve_c1lum(WaterColor, fogColor, f_BIOME_WATER_CONTRIBUTION);
        return mix_preserve_c1lum(FinalColor, WaterColor, 1) * 0.25;
    }
    return FinalColor;
}

vec3 rgb_to_hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)), // Hue
        d / (q.x + e),                          // Saturation
        q.x                                     // Value
    );
}

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 get_min_light() {
    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * 0.1 - 0.1, 0.0, 0.5);
    MinLight = to_linear(MinLight);
    MinLight += nightVision / 3;
    return vec3(MinLight);
}

vec3 oklab_srgb(vec3 c) {
    const mat3 M1 = mat3(1.0, 0.3963377774, 0.2158037573,
        1.0, 0.1055613458, 0.0638541728,
        1.0, 0.0894841775, 1.2914855480
    );
    const mat3 M2 = mat3(4.0767416621, -3.3077115913, 0.2309699292,
        -1.2684380046, 2.6097574011, -0.3413193965,
        -0.0041960863, -0.7034186147, 1.7076147010
    );
    
    vec3 lms_ = c * M1;

    vec3 lms = lms_*lms_*lms_;

    return lms * M2;
}

vec3 oklch_oklab(vec3 oklch) {
    float t = oklch.z*TAU;
    return vec3(
        oklch.x,
        oklch.y * cos(t),
        oklch.y * sin(t)
    );
}

vec3 oklch_srgb(vec3 c) {
    return oklab_srgb(oklch_oklab(c));
}