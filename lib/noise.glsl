// https://github.com/Experience-Monks/glsl-fast-gaussian-blur
float noise(vec2 Coords) {
    float color = texture(noisetex, (Coords)/noiseTextureResolution*0.75).x;
	float Detail = texture(noisetex, (Coords)/noiseTextureResolution*5).x * 0.1;
    return max(color - Detail,0);
}

vec2 noise_water(vec2 Coords) {
	Coords /= WATER_NORMAL_SIZE;
    vec2 color = (texture(noisetex, (Coords+frameTimeCounter*0.2*WATER_NORMAL_SPEED)/24).yz * 2 - 1) * 0.05;
	color += (texture(noisetex,(Coords-frameTimeCounter*0.8*WATER_NORMAL_SPEED)/64).yz * 2 - 1) * 0.1;
    return color * WATER_NORMAL_STRENGTH;
}

float fbm_fast(vec2 x, int detail) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < detail; ++i) {
		v += a * texture(noisetex, x/noiseTextureResolution).x;
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}



float ign(vec2 Pos, const bool Animate) {
	if(Animate) {
    	float FrameMod = frameCounter % 64;
    	Pos += 5.588238f * FrameMod;
	}

    return fract(52.9829189 * fract(0.06711056 * Pos.x + 0.00583715 * Pos.y));
}

float dither(vec2 Pos) {
	// Interleaved gradient noise
    #if TAA_MODE != 0

    return ign(Pos, true);
	#endif
	// Use bayer dither when TAA is disabled because it's more visually pleasing
	return ign(Pos, false);
}
