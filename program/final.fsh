#include "/lib/all_the_libs.glsl"

in vec2 texcoord;

#include "/global/post/taa.glsl"
#include "/global/post/cas.glsl"

// CAS, vignette, color grading

vec3 film_grain(vec3 Color, vec2 Pos) {
    Pos.x += fract(float(frameCounter) / 4.14159) * 234;
    Pos.y -= fract(float(frameCounter) / 5.49382) * 567;
    Color += (texture(noisetex, Pos.xy / 255).rgb - 0.5) * FILM_GRAIN_STRENGTH;
    return Color;
}

vec3 apply_vignette(vec3 Color, vec2 Pos) {
    Pos = Pos - 0.5;
    Pos *= VIGNETTE_OPACITY;
    float Strength = len2(Pos);
    Strength = pow(Strength, 2 - VIGNETTE_FALLOFF);
    Color *= 1 - min(Strength, 1);
    return Color;
}

vec3 channel_mixer(vec3 Color) {
    vec3 NewColor = vec3(0);
    NewColor += Color.r * vec3(CM_R_IN_R, CM_G_IN_R, CM_B_IN_R);
    NewColor += Color.g * vec3(CM_R_IN_G, CM_G_IN_G, CM_B_IN_G);
    NewColor += Color.b * vec3(CM_R_IN_B, CM_G_IN_B, CM_B_IN_B);
    return clamp(NewColor, 0, 1);
}

vec3 color_balance(vec3 Color) {
    vec3 Shadows = clamp(Color + vec3(SHADOWS_CYAN_TO_RED, SHADOWS_MAGENTA_TO_GREEN, SHADOWS_YELLOW_TO_BLUE), 0, 1);
    vec3 Mids = clamp(Color + vec3(MIDS_CYAN_TO_RED, MIDS_MAGENTA_TO_GREEN, MIDS_YELLOW_TO_BLUE), 0, 1);
    vec3 Highs = clamp(Color + vec3(HIGHS_CYAN_TO_RED, HIGHS_MAGENTA_TO_GREEN, HIGHS_YELLOW_TO_BLUE), 0, 1);

    float OldL = get_luminance(Color);
    vec3 NewColor = OldL < 0.5 ? mix(Shadows, Mids, OldL * 2) : mix(Mids, Highs, OldL * 2 - 1);
    float NewL = get_luminance(NewColor);

    NewColor *= OldL / NewL;
    return NewColor;
}

layout(location = 0) out vec4 Color;

void main() {
    #ifdef IMAGE_SHARPENING
        Color = vec4(CAS(colortex0), 1);
    #else
        Color = texture(colortex0, texcoord);
    #endif

    Color.rgb = pow(Color.rgb, vec3(1/2.2));

    Color.rgb = apply_vibrance(Color.rgb, VIBRANCE);
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);

    #ifdef COLOR_BALANCING
        Color.rgb = color_balance(Color.rgb);
    #endif

    #ifdef CHANNEL_MIXER
        Color.rgb = channel_mixer(Color.rgb);
    #endif

    #ifdef FILM_GRAIN
    Color.rgb = film_grain(Color.rgb, gl_FragCoord.xy);
    #endif

    Color.rgb = apply_vignette(Color.rgb, texcoord);

    Color.xyz += (ign(gl_FragCoord.xy, false) - 0.5) / 128; 
}
