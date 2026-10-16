// Very simple and inaccurate, but it's better than nothing.
float water_fog(vec3 ScreenPos) {
    float TerrainDepth = texture(depthtex1, ScreenPos.xy).x;
    TerrainDepth = linearize_depth(TerrainDepth);
    float ScreenDepth = linearize_depth(ScreenPos.z);
    return smoothstep(0, 48, TerrainDepth - ScreenDepth) * WATER_FOG_STRENGTH;
}

vec3 get_water_normal(vec2 Coords, vec3 WorldNormal) {
    if (abs(WorldNormal.y) < 0.99) {
        Coords -= frameTimeCounter * normalize(WorldNormal.xz) * 3;
    }
    vec2 N = noise_water(Coords);
    return normalize(vec3(N.x, N.y, 1 - (N.x * N.x + N.y * N.y)));
}

vec3 sky_reflection(vec3 ReflectedVec, float WNy, float Dist, const bool ReflectSun) {
    #ifdef DIMENSION_OVERWORLD
            vec3 SunGlare = get_sun_glare(Dist);
            vec3 Reflection = get_sky(ReflectedVec, SunGlare);
        #if (defined REFLECT_SUN)
            if (WNy > 0.01 && ReflectSun) { // Prevent sun from being reflected on sides of blocks
                Reflection.rgb += round_sun(Dist) * 4 * isOutdoorsSmooth;
            }
        #endif
        return Reflection;
    #else
        return to_linear(fogColor.rgb);
    #endif
}

float flipped_image_ref(vec3 RVec, vec3 ViewPos, bool IsDH, out vec3 SamplePos) {
    #ifdef DISTANT_HORIZONS
    float Offset = min(1000, 50 + dhRenderDistance / 4);
    #else
    float Offset = 50 + far / 4;
    #endif

    SamplePos = view_screen(ViewPos + RVec * Offset, IsDH);
    if(SamplePos.xy == vec2(clamp(SamplePos.x, -0.2, 1.2), clamp(SamplePos.y, 0, 1))) {
        bool IsDHReal;
        float RealDepth = get_depth_solid_lq(SamplePos.xy, IsDHReal);
        #ifdef DISTANT_HORIZONS
            if(SamplePos.z >= 1) {
                SamplePos = view_screen(ViewPos + RVec * Offset, true);
            }
        #endif
        if(SamplePos.z < 1 && SamplePos.z > 0.56 && RealDepth < 1) {
            SamplePos.z = RealDepth;
            vec3 ViewPosReal = screen_view(SamplePos, IsDHReal);
            if(len2(ViewPosReal) + 25 > len2(ViewPos)) {
                return 1 - linstep(0.5, 0.7, abs(SamplePos.x - 0.5));
            }
        }
    }
    return 0.0;
}

float ssr(vec3 RVec, vec3 ScreenPos, vec3 ViewPos, float Fresnel, float Dither, bool IsDH, out vec3 ExpectedPos) {
    // Convert RVec to screenspace
    vec3 Offset = normalize(view_screen(ViewPos + RVec, IsDH) - ScreenPos);
    vec3 Len = (step(0, Offset) - ScreenPos) / Offset;
    float MinLen = min(Len.y, Len.z) / SSR_STEPS;
    Offset *= MinLen;

    ExpectedPos = ScreenPos + Offset * Dither;
    for (int i = 1; i <= SSR_STEPS; i++) {
        float RealDepth = get_depth_solid_lq(ExpectedPos.xy, IsDH);
        if (RealDepth < 0.56) {
            break;
        }

        if (ExpectedPos.z > RealDepth) {
            // Depth based rejection
            if (ExpectedPos.z - RealDepth > abs(Offset.z * (0.5 * SSR_STEPS))) {
                break;
            }

            // Binary refinement
            for (int j = 1; j <= int(round(Fresnel * 3)); j++) {
                Offset /= 2;
                vec3 EPos1 = ExpectedPos - Offset;
                float RDepth1 = get_depth_solid_lq(EPos1.xy, IsDH);
                if (EPos1.z > RDepth1) {
                    ExpectedPos = EPos1;
                }
            }
            return 1.0 - linstep(0.5, 0.7, abs(0.5 - ExpectedPos.x));
        }
        ExpectedPos += Offset;
    }
    return 0.0;
}

vec3 get_reflection(vec3 ScreenPos, vec3 ViewPos, vec3 ViewPosN, vec3 WaterNormal, float Dither, float Fresnel, float Smoothness, float WNy, const bool ReflectSun, bool IsDH) {
    vec3 ReflectedVec = reflect(ViewPosN, WaterNormal);

    float Hit = 0;
    vec3 RayPos;
    #if REFLECTIONS == 2
        Hit = ssr(ReflectedVec, ScreenPos, ViewPos, Fresnel, Dither, IsDH, RayPos);
        #ifdef DISTANT_HORIZONS
            if(Hit == 0)
                Hit = flipped_image_ref(ReflectedVec, ViewPos, IsDH, RayPos);
        #endif
    #elif REFLECTIONS == 3
        Hit = flipped_image_ref(ReflectedVec, ViewPos, IsDH, RayPos);
    #endif

    vec3 FinalColor = vec3(0);
    if(Hit > 0) {
        #ifdef ROUGH_REFLECTIONS
            if(Smoothness < 1) {
                float BlurSize = 500 * distance(ViewPos, screen_view(RayPos, IsDH)) * smoothness_to_roughness(Smoothness);
                return blur_variable(RayPos.xy, BlurSize, gaux1);
            } else 
        #endif
            FinalColor = texture(gaux1, RayPos.xy).rgb * Hit;  
    } 
    if(Hit < 1) {
        float Dist = dot(ReflectedVec, sunPosN);
        FinalColor += (1 - Hit) * sky_reflection(ReflectedVec, WNy, Dist, ReflectSun);
    }
    return FinalColor;
}

vec4 get_fancy_water(vec3 ScreenPos, vec3 ViewPos, vec3 ViewPosN, vec3 PlayerPos, vec4 BaseColor, float SkyBrightness, mat3 TBN, float Dither, bool IsDH) {
    #ifndef DISTANT_HORIZONS
        if (isEyeInWater == 0) {
            BaseColor.a = min(BaseColor.a + water_fog(ScreenPos), 1);
        }
    #endif

    #if REFLECTIONS != 0
        vec3 WorldNormal = view_player(TBN[2], IsDH);
        #ifdef WATER_NORMALS
            vec3 NormalMap = get_water_normal(PlayerPos.xz + cameraPosition.xz, WorldNormal);
            vec3 WaterNormal = TBN * NormalMap;
        #else
            vec3 WaterNormal = TBN[2];
        #endif

        float Fresnel = schlick(-ViewPosN, WaterNormal, 0.02) * SkyBrightness;

        if (WorldNormal.y > -0.01) { // Prevent reflections underwater and other weird scenarios
            vec3 Reflection = get_reflection(ScreenPos, ViewPos, ViewPosN, WaterNormal, Dither, Fresnel, 1, WorldNormal.y, true, IsDH);
            BaseColor.rgb += Reflection * Fresnel;
        }
    #endif

    return BaseColor;
}
