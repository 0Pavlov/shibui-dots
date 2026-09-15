#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    float seed;
    vec2 surface_size;
    vec2 resolution;
} ubuf;

layout(binding = 1) uniform sampler2D sourceImage;

/*
    'Electric Wave / CineShader' by nasana (Created: 2020-01-30)
    Twitter/X: https://twitter.com/nasana_x
    Adapted for Hyprland window transitions.
*/
void qt_original_main() {
    float p = ubuf.progress;
    vec2 uv = qt_TexCoord0;
    float seed_local = ubuf.seed * 10.0;
    vec2 res = ubuf.surface_size.x > 1.0 ? ubuf.surface_size : (ubuf.resolution.x > 1.0 ? ubuf.resolution : vec2(1920.0, 1080.0));

    float time = p * 2.5 + seed_local;

    vec2 p_uv = (uv - 0.5) * 2.0;
    p_uv.x *= res.x / res.y;

    vec2 wave_uv = p_uv;
    for (float i = 1.0; i < 10.0; i += 1.0) {
        wave_uv.x += (0.6 / i) * cos(i * 2.5 * wave_uv.y + time);
        wave_uv.y += (0.6 / i) * cos(i * 1.5 * wave_uv.x + time);
    }

    float glow = 0.1 / max(abs(sin(time - wave_uv.y - wave_uv.x)), 0.02);
    vec3 glow_col = clamp(vec3(glow * 0.8, glow * 0.9, glow * 1.1), 0.0, 3.0);
    float energy = clamp(glow * 0.25, 0.0, 1.0);

    vec2 disp = wave_uv - p_uv;
    float distort_strength = p * p * 0.4;
    vec2 warped_uv = uv + disp * distort_strength;

    vec2 center = uv - 0.5;
    float dist = length(center * vec2(1.0, 0.7));
    float dissolve = (1.0 - dist) * 0.85 + energy * 0.5;
    float remain = smoothstep(dissolve + 0.3, dissolve - 0.3, p * 1.35);

    vec4 screen = texture(sourceImage, warped_uv);

    float edge = smoothstep(0.0, 0.6, remain) * smoothstep(1.0, 0.3, remain);
    vec3 final_rgb = mix(screen.rgb, screen.rgb + glow_col * 0.6, edge * 0.85);

    float tail = smoothstep(1.0, 0.85, p);
    float mask = screen.a * remain * tail;
    fragColor = vec4(final_rgb * mask, mask);
}

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
