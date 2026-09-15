#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    // Glitch specific uniforms appended to the block:
    float seed;
    vec2 surface_size;
    vec2 resolution;
} ubuf;

layout(binding = 1) uniform sampler2D sourceImage;

// Glitch hash function
float gh(float n) {
    return fract(sin(n) * 43758.5453);
}

void main() {
    float p = ubuf.progress;
    vec2 uv = qt_TexCoord0;

    float intensity = p * p;

    float tick = floor(p * 60.0) + ubuf.seed * 1000.0;
    float r1 = gh(tick * 1.13);
    float r2 = gh(tick * 2.37);
    float r3 = gh(tick * 3.71);
    float r4 = gh(tick * 4.19);
    float r5 = gh(tick * 5.53);
    float r6 = gh(tick * 6.91);

    vec2 off_r = vec2(r1 - 0.5, r2 - 0.5) * intensity * 0.15;
    vec2 off_g = vec2(r3 - 0.5, r4 - 0.5) * intensity * 0.15;
    vec2 off_b = vec2(r5 - 0.5, r6 - 0.5) * intensity * 0.15;

    float slice = floor(uv.y * 20.0);
    float slice_offset = (gh(slice + tick) - 0.5) * intensity * 0.12;

    vec2 uv_r = uv + off_r + vec2(slice_offset * 0.7, 0.0);
    vec2 uv_g = uv + off_g + vec2(slice_offset * -0.5, 0.0);
    vec2 uv_b = uv + off_b + vec2(slice_offset * 0.3, 0.0);

    vec4 color;
    color.r = texture(sourceImage, uv_r).r;
    color.g = texture(sourceImage, uv_g).g;
    color.b = texture(sourceImage, uv_b).b;
    color.a = max(max(
        texture(sourceImage, uv_r).a,
        texture(sourceImage, uv_g).a),
        texture(sourceImage, uv_b).a);

    float big_glitch = step(0.8 - p * 0.3, gh(tick * 0.77));
    vec2 shift = vec2((gh(tick * 1.5) - 0.5) * 0.08 * big_glitch * intensity, 0.0);
    vec2 tc_shift = uv + shift;
    vec4 shifted = texture(sourceImage, tc_shift);
    color = mix(color, shifted, big_glitch * intensity * 0.5);

    float scanline = 1.0 - sin(uv.y * ubuf.surface_size.y * 3.14159) * 0.08 * intensity;
    color.rgb *= scanline;

    // Fade out logic combined with the overall UI opacity
    float alpha = smoothstep(1.0, 0.6, p);
    fragColor = color * alpha * ubuf.qt_Opacity;
}
