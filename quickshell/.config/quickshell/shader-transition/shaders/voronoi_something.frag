#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    // Extra uniforms needed for the voronoi shatter
    float seed;
    vec2 surface_size;
    vec2 resolution;
} ubuf;

layout(binding = 1) uniform sampler2D sourceImage;

// Ported from skwd-wall voronoi-shatter transition
vec2 vs_hash2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                           dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void main() {
    // Progress goes from 0.0 to 1.0, so p goes from 1.0 down to 0.0 for a transition out
    float p = 1.0 - ubuf.progress;
    vec2 uv = qt_TexCoord0;
    vec4 win = texture(sourceImage, uv);

    float scale = 60.0;
    vec2 q = uv * scale;
    vec2 g = floor(q);
    vec2 f = fract(q);
    float min_d = 100.0;
    vec2 cell = g;
    
    // Find the closest Voronoi cell center
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 nb = vec2(float(x), float(y));
            vec2 r = nb + vs_hash2(g + nb) - f;
            float d = dot(r, r);
            if (d < min_d) { 
                min_d = d; 
                cell = g + nb; 
            }
        }
    }
    
    // Each cell gets a random seed to shatter at a slightly different time
    float seed_local = vs_hash2(cell).x;
    float shard_p = smoothstep(seed_local * 0.5, seed_local * 0.5 + 0.5, p);
    float reveal = smoothstep(0.0, 0.5, shard_p);

    // Output original color combined with the reveal mask and Qt's global opacity
    fragColor = win * reveal * ubuf.qt_Opacity;
}
