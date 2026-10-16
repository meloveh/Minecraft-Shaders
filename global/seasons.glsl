vec4 get_seasons_color(vec4 glcolor) {
    if(glcolor.rgb != vec3(1)) {
            glcolor.rgb = rgb_to_hsv(glcolor.rgb);

            const vec3 Spring = vec3(SPRING_HUE, SPRING_SAT, SPRING_VAL);
            const vec3 Summer = vec3(SUMMER_HUE, SUMMER_SAT, SUMMER_VAL);
            const vec3 Autumn = vec3(AUTUMN_HUE, AUTUMN_SAT, AUTUMN_VAL);
            const vec3 Winter = vec3(WINTER_HUE, WINTER_SAT, WINTER_VAL);

            // Blend between seasons
            float TimeOfYear = worldDay % 120;
            float SpringS = clamp(TimeOfYear,0,30) / 30;
            float SummerS = clamp(TimeOfYear-30,0,30) / 30;
            float AutumnS = clamp(TimeOfYear-60,0,30) / 30;
            float WinterS = clamp(TimeOfYear-90,0,30) / 30;
            vec3 TintMixed = mix(mix(mix(mix(Spring, Summer, SpringS), Autumn, SummerS), Winter, AutumnS), Spring, WinterS);

            #ifdef SEASONS_TEMPERATE_BIOME_CHECK
                float IsBiomeTemperate = glcolor.r < 0.3 ? smoothstep(0.15, 0.3, glcolor.r) : 1-smoothstep(0.3, 0.35, glcolor.r);
                TintMixed *= IsBiomeTemperate;
            #endif

            glcolor.rgb += TintMixed;
                
            glcolor.rgb = hsv_to_rgb(glcolor.rgb);
        }
    return glcolor;
}