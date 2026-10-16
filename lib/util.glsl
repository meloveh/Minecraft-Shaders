float random(vec2 coords) {
    return fract(sin(dot(coords.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float random3D(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.543))) * 43758.5453);
}

float linearize_depth(float D) {
    return near / (1 - D);
}

float ld_exact(float depth, float near, float far) {
    return (near * far) / (depth * (near - far) + far);
}

// Creates a TBN matrix from a normal and a tangent
mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    // For DirectX normal mapping you want to switch the order of these
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

// Creates a TBN matrix from just a normal
// The tangent version is needed for normal mapping because
//   of face rotation
mat3 tbnNormal(vec3 normal) {
    // This could be
    // normalize(vec3(normal.y - normal.z, -normal.x, normal.x))
    vec3 tangent = normalize(cross(normal, vec3(0, 1, 1)));
    return tbnNormalTangent(normal, tangent);
}

float get_luminance(vec3 Color) {
    return 0.299 * Color.r + 0.587 * Color.g + 0.114 * Color.b;
}

vec2 rotate(vec2 P, float Ang) {
    float cosT = cos(Ang);
    float sinT = sin(Ang);
    return vec2(
        P.x * cosT - P.y * sinT,
        P.y * cosT + P.x * sinT
    );
}

float len2(vec2 v) {
    return dot(v, v);
}

float len2(vec3 v) {
    return dot(v, v);
}

float pow2(float x) {
    return x * x;
}

float pow4(float x) {
    return pow2(pow2(x));
}

vec2 pow2(vec2 x) {
    return x * x;
}

vec2 pow4(vec2 x) {
    return pow2(pow2(x));
}

vec3 pow2(vec3 x) {
    return x * x;
}

vec3 pow4(vec3 x) {
    return pow2(pow2(x));
}

vec4 pow2(vec4 x) {
    return x * x;
}

vec4 pow4(vec4 x) {
    return pow2(pow2(x));
}

float min_component(vec2 a) {
    return min(a.x, a.y);
}
float min_component(vec3 a) {
    return min(a.x, min(a.y, a.z));
}
float min_component(vec4 a) {
    return min(a.x, min(a.y, min(a.z, a.w)));
}

float max_component(vec2 a) {
    return max(a.x, a.y);
}
float max_component(vec3 a) {
    return max(a.x, max(a.y, a.z));
}
float max_component(vec4 a) {
    return max(a.x, max(a.y, max(a.z, a.w)));
}

float xlf_phase(float angle, const float g)
{
	float g2 = g * g;
	const float k = 3.0/2.0;
	float denom = (1 + g2 - 2 * g * angle);
	float result = k * ((1-g2)/(2+g2)) * ((1 + angle*angle) / denom) + g*angle;
	return 1.0/(4.0*PI) * result;
}

float len_sq(vec3 x) {
    return max_component(abs(x));
}

const vec2 vogel_disk[32] = vec2[](
	vec2(0.12064426510477419, 0.015554431411765695),
	vec2(-0.16400077998918963, 0.16180237012184204),
	vec2(0.020080498035937415, -0.2628838391620438),
	vec2(0.19686650437195816, 0.27801320993574674),
	vec2(-0.37362329188851157, -0.049763799980476156),
	vec2(0.34544673107582735, -0.20696126421568928),
	vec2(-0.12135781397691386, 0.4507963336805642),
	vec2(-0.22749138875333694, -0.41407969197383454),
	vec2(0.4797593802468298, 0.19235249500691445),
	vec2(-0.5079968434096749, 0.22345015963708734),
	vec2(0.23843255951864029, -0.5032700515259672),
	vec2(0.17505863904522073, 0.587555727235086),
	vec2(-0.5451127409909945, -0.2978253068585009),
	vec2(0.6300137885218894, -0.12390992876509886),
	vec2(-0.391501580064061, 0.5662295575692019),
	vec2(-0.09379538975841809, -0.6746452122696498),
	vec2(0.5447160222309757, 0.47831268960533435),
	vec2(-0.7432342062047558, 0.046109375942755174),
	vec2(0.5345993903170301, -0.520777903066999),
	vec2(-0.0404139208253129, 0.7953459466435174),
	vec2(-0.517173266802963, -0.5989723613060595),
	vec2(0.8080038585189984, 0.12485626574164435),
	vec2(-0.6926663754026566, 0.494463047083117),
	vec2(0.183730322451809, -0.8205069509230769),
	vec2(0.43067753069940745, 0.7747454863024757),
	vec2(-0.8548041452377114, -0.25576180722119723),
	vec2(0.8217466662308877, -0.3661258311820314),
	vec2(-0.36224393661662146, 0.87070999332353),
	vec2(-0.32376306917956177, -0.8724793262829371),
	vec2(0.8455529005007657, 0.4622425905108438),
	vec2(-0.9483903811252437, 0.2643989345002705),
	vec2(0.5322400733549763, -0.818975339518135)
);

const float ISOTROPIC_PHASE = 1. / (4 * PI);

float rescale(float l, float L, float x) {
    return (x - l) / (L - l);
}
vec2 rescale(float l, float L, vec2 x) {
    return (x - l) / (L - l);
}

float linstep(float l, float L, float x) {
    return clamp(rescale(l, L, x), 0, 1);
}

vec2 get_texcoord(mat4 TextureMat, vec4 MultiTexCoord) {
    #if (FAST_TEXCOORD == 1) && !(defined ENCHANTMENT_GLINT)
        return MultiTexCoord.xy;
    #else
        return (TextureMat * MultiTexCoord).xy;
    #endif
}

vec2 get_lightmap(mat4 TextureMat, vec4 MultiTexCoord) {
    #if (FAST_LIGHTMAP == 1) && !(defined DH_TERRAIN)
        return MultiTexCoord.xy * 0.00390625 + 0.03125;
    #else
        return (TextureMat * MultiTexCoord).xy;
    #endif
}


vec2 encodeUnitVector(vec3 vector) {
	// Scale down to octahedron, project onto XY plane
	vector.xy /= abs(vector.x) + abs(vector.y) + abs(vector.z);
	// Reflect -Z hemisphere folds over the diagonals
	return vector.z <= 0.0 ? (1.0 - abs(vector.yx)) * vec2(vector.x >= 0.0 ? 1.0 : -1.0, vector.y >= 0.0 ? 1.0 : -1.0) : vector.xy;
}

vec3 decodeUnitVector(vec2 encoded) {
	// Exctract Z component
	vec3 vector = vec3(encoded, 1.0 - abs(encoded.x) - abs(encoded.y));
	// Reflect -Z hemisphere folds over the diagonals
	float t = max(-vector.z, 0.0);
	vector.xy += vec2(vector.x >= 0.0 ? -t : t, vector.y >= 0.0 ? -t : t);
	// Normalize and return
	return normalize(vector);
}

mat3 tbn_decode(vec3 Normal, vec4 Tangent) {
    mat3 TBN;
    TBN[2] = Normal;
    #ifdef DH_TERRAIN
        TBN[0] = normalize(gbufferModelView[0].xyz);
        TBN[1] = normalize(gbufferModelView[2].xyz);
    #else
        TBN[0] = Tangent.xyz;
        TBN[1] = cross(TBN[0], TBN[2]) * sign(Tangent.w);
    #endif
    return TBN;
}

vec3 blur_variable(vec2 texcoord, float CoC, sampler2D Sampler) {
    vec3 Sum = vec3(0);
	CoC *= gbufferProjection[1][1] / 1.37; // Scale according to fov
	vec2 Radius = resolutionInv * CoC;

    for(int i = 0; i < DOF_BLUR_QUALITY; i++) {
        vec2 Offset = vogel_disk[i] * Radius;
		float lod = log2(CoC * 0.5);
        Sum += textureLod(Sampler, texcoord + Offset, lod).rgb;
    }

    return Sum / DOF_BLUR_QUALITY;
}