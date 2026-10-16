#include "/lib/all_the_libs.glsl"
#include "/global/post/smaa.glsl"

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 Color;

void main() {
    ivec2 Coords = ivec2(gl_FragCoord.xy);
    float L = texelFetch(colortex2, Coords, 0).b;
    float R = texelFetch(colortex2, Coords + ivec2(1, 0), 0).a;
    float U = texelFetch(colortex2, Coords, 0).r;
    float D = texelFetch(colortex2, Coords + ivec2(0, 1), 0).g;

    float Sum = L + U + R + D;
    if(Sum > 0.01) {
        bool h = max(L, R) > max(D, U);
        vec4 Offsets = h ? vec4(-L, 0, R, 0) : vec4(0, -U, 0, D);
        vec2 BlendFactor = h ? vec2(L, R) : vec2(U, D);
        BlendFactor /= dot(BlendFactor, vec2(1));

        Color.rgb = textureLod(colortex0, texcoord + Offsets.xy * resolutionInv, 0).rgb * BlendFactor.x;
        Color.rgb += textureLod(colortex0, texcoord + Offsets.zw * resolutionInv, 0).rgb * BlendFactor.y;

    }
    else {
        Color = textureLod(colortex0, texcoord, 0);
    }

    Color.rgb = to_linear(Color.rgb);
}
