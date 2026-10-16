vec3 get_lava_fog(float dist, vec3 color) {
    const vec3 LAVA_FOG_COLOR = to_linear(vec3(0.65, 0.35, 0.125));
    const vec3 PSNOW_FOG_COLOR = to_linear(vec3(0.5, 0.6, 0.8));

    if (isEyeInWater == 2) {
        dist = clamp(dist / 2, 0, 1);
        return mix(color, LAVA_FOG_COLOR, dist);
    }
    else if (isEyeInWater == 3) {
        dist = clamp(dist / 2, 0, 1);
        return mix(color, PSNOW_FOG_COLOR, dist);
    }
    return color;
}

vec3 get_border_fog(float Dist, vec3 Color, vec3 SkyColor) {
    #ifdef DIMENSION_NETHER
        const int Falloff = max(0, BORDER_FOG_FALLOFF - 2);
    #else
        const int Falloff = BORDER_FOG_FALLOFF;
    #endif

    float Strength = Dist / furthest;
    for(int i = 1; i <= Falloff; i++)
        Strength *= Strength;

    Strength = min(1, (1-smoothstep(furthest - 32, furthest - 16, Dist)) * exp(-3 * BORDER_FOG_STRENGTH * Strength));

    return mix(SkyColor, Color, Strength);
}

vec3 get_blindness_fog(float Dist, vec3 Color) {
    Dist = clamp(1.0 - exp(-3.0 * Dist / 10), 0, 1) * max(darknessFactor, blindness);
    return Color * (1 - Dist);
}

vec3 get_end_fog(float Dist, vec3 Color, float Depth, vec3 PlayerPos) {
    if(Dist >= furthest) {
        PlayerPos = normalize(PlayerPos) * furthest;
    }
    Dist = min(Dist / 32, 1);
    Dist = 1.0 - exp(-3.0 * Dist) + 0.0497;

    float WorldHeight = PlayerPos.y + cameraPosition.y;
    float HeightLower = END_FOG_START_HEIGHT + max(0, -WorldHeight);
    float HeightFalloff = 1 - smoothstep(HeightLower, HeightLower + 10, WorldHeight);

    float Factor = Dist * HeightFalloff;
    return Color * (1 - Factor);
}

float get_shadowing(vec3 ScreenPos, vec3 LightPos, float Dither, bool IsDH) {
    if(LightPos.z > 0) return 0.5;

    vec3 LightPosScreen = view_screen(LightPos, IsDH);
    if(LightPosScreen.xy != clamp(LightPosScreen.xy, 0, 1)) return 0.5;

    // Trace
    float LightFactor = 0;
    vec3 Step = (LightPosScreen - ScreenPos) / GODRAYS_QUALITY;
    vec3 ExpectedPos = ScreenPos + Step * Dither;
    for (int i = 1; i <= GODRAYS_QUALITY; i++) {
        float RealDepth = get_depth(ExpectedPos.xy, IsDH);
        LightFactor += 1 - step(1, RealDepth);
        
        ExpectedPos += Step;
    }

    float Falloff = min_component(abs(step(0.5, LightPosScreen.xy) - LightPosScreen.xy));
    Falloff = smoothstep(0., 0.25, Falloff);

    return mix(0.5, 1 - LightFactor / GODRAYS_QUALITY, Falloff);
}

const float FOG_ABSORBTION = 0.0025;
const float FOG_SCATTERING = 0.02;

const float FOG_EXTINCTION = FOG_ABSORBTION + FOG_SCATTERING;

float trace_godrays(vec3 ScreenPos, float VdotL, vec3 LightPos, float Dither, float Density, float Depth, bool IsDH) {
    #if (defined GODRAYS) && (defined DEFERRED)
        float Shadowing = get_shadowing(ScreenPos, LightPos, Dither, IsDH);
    #else
        float Shadowing = 0.5;
    #endif


    float Phase = xlf_phase(VdotL, isEyeInWater == 1 ? 0.8 : 0.6);

    float fms = FOG_SCATTERING * (1 - exp(-100 * Density * FOG_EXTINCTION)) / FOG_EXTINCTION;
    float MS = ISOTROPIC_PHASE * fms / (1 - fms) * float(isEyeInWater == 0);

    return Shadowing * (Phase + MS);
}

vec3 get_atm_fog(vec3 Color, vec3 ScreenPos, vec3 PlayerPos, float Dist, float VdotL, float Dither, float Depth, bool IsDH) {
    if(fogAmount < 1e-5) return Color;
    vec3 Scattering = vec3(0);

    // Make sure it doesn't extend forever (it would look ugly);
    float Height = Depth >= 1 ? (PlayerPos.y / Dist + 1.7) * 50 : PlayerPos.y * min(furthest, Dist) / Dist + cameraPosition.y;
    float HeightFalloff = isEyeInWater == 1 ? 1 : 1 - linstep(60, 100, Height);
    float Density = 0.12 + HeightFalloff * 0.15;

    Density *= fogAmount * ATM_FOG_STRENGTH;

    #ifdef DIMENSION_OVERWORLD
        // Sun
        if(nightStrength < 0.99) {
            const vec3 SUN_GLARE = to_linear(vec3(0.7, 0.45, 0.0));
            vec3 SunColor = (SUN_DIRECT * dayStrength + SUN_GLARE * (sunsetStrength + sunriseStrength) * (1 - 0.33 * (rainStrength + thunderStrength)) * 4);
            Scattering += tint_underwater(SunColor) * trace_godrays(ScreenPos, VdotL, sunPosN, Dither, Density, Depth, IsDH);
        }

        // Moon
        if(dayStrength < 0.01) {
            vec3 MoonColor = (SUN_DIRECT * nightStrength);
            Scattering += tint_underwater(MoonColor) * trace_godrays(ScreenPos, -VdotL, -sunPosN, Dither, Density, Depth, IsDH);
        }
    #endif

    // Ambient
    Scattering += tint_underwater(SKY_GROUND / PI);

    float Transmittance = exp(-FOG_EXTINCTION * min(Dist, 128) * Density);

    // TODO: Make border fog work properly with this
    Color *= Transmittance;

    return Color + Scattering * (1 - Transmittance) * FOG_SCATTERING / FOG_EXTINCTION;
}

vec3 get_fog_main(vec3 ScreenPos, vec3 PlayerPos, vec3 Color, float Depth, vec3 SkyColor, float VdotL, float Dither, bool IsDH) {
    float Dist = length(PlayerPos);

    if (Depth < 1) {
        #if defined BORDER_FOG && !defined CUSTOM_SKYBOXES
            Color.rgb = get_border_fog(Dist, Color.rgb, SkyColor);
        #endif
    }

    #if !(defined DIMENSION_OVERWORLD && defined ATMOSPHERIC_FOG)
        if(isEyeInWater == 1)
    #endif
        Color.rgb = get_atm_fog(Color.rgb, ScreenPos, PlayerPos, Dist, VdotL, Dither, Depth, IsDH);
    
    #ifdef DIMENSION_END
        #ifdef END_FOG
            Color.rgb = get_end_fog(Dist, Color.rgb, Depth, PlayerPos);
        #endif
    #endif
    Color.rgb = get_lava_fog(Dist, Color.rgb);
    Color.rgb = get_blindness_fog(Dist, Color.rgb);
    return Color;
}
