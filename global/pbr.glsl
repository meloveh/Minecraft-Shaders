void decode_normal(vec2 Texcoord, out vec3 Normal, out float Ao) {
    #if (defined PBR_POM) && (defined GBUFFERS_TERRAIN)
        vec4 Data = textureGrad(normals, Texcoord.xy, dCoordx, dCoordy);
    #else
        vec4 Data = texture(normals, Texcoord.xy);
    #endif
    Normal.xy = Data.xy * 2 - 1;
    Normal.z = sqrt(max(0, 1 - dot(Normal.xy, Normal.xy)));
    Ao = Data.z;
}

float smoothness_to_roughness(float Smoothness) {
    return pow2(1 - Smoothness);
}

void decode_specular(vec2 Texcoord, out float Smoothness, out float F0, out float SSS, out float Porosity, out float Emissiveness) {
    #if (defined PBR_POM) && (defined GBUFFERS_TERRAIN)
        vec4 Data = textureGrad(specular, Texcoord.xy, dCoordx, dCoordy);
    #else
        vec4 Data = texture(specular, Texcoord.xy);
    #endif
    Smoothness = Data.r;
    F0 = Data.g;
    if(Data.b > 64.0/255.0) {
        SSS = Data.b;
        Porosity = 0;
    }
    else {
        SSS = 0;
        Porosity = Data.b * 255.0 / 64.0;
    }
    Emissiveness = Data.a == 1 ? 0 : Data.a;
}

float schlick(vec3 N, vec3 V, float F0) {
    float cosTheta = clamp(dot(N, V), 0, 1);
    return F0 + (1 - F0) * pow(1 - cosTheta, 5);
}

float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;

    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return num / denom;
}
float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float num = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return num / denom;
}
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
float cook_torrance(vec3 V, vec3 LightDir, vec3 Normal, float Roughness, vec3 H, float F) {
    float D = DistributionGGX(Normal, H, Roughness);
    float G = GeometrySmith(Normal, V, LightDir, Roughness);
    float Final = (D * F * G) / (4 * max(dot(V, Normal), 0) * max(dot(Normal, LightDir), 0) + 0.001);
    return min(Final, 10);
}
