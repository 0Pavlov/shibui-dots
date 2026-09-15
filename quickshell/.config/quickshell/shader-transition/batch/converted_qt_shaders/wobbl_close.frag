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

// "Wobbl" doesn't generate its own color field, unlike the other reference
// shaders — it only distorts the window's own texture. So instead of the
// energy/dissolve-mask scheme used elsewhere, this ramps the original
// wobble + a slight inward zoom together with ubuf.progress, then fades to black.
void qt_original_main() {
    float p = ubuf.progress;
    vec2 uv = qt_TexCoord0;
    float seed_local = ubuf.seed * 100.0;

    float t = p * 6.0 + seed_local;

    // ease from the untouched image towards the original 0.8*uv+0.1 zoom
    vec2 zoomed_uv = mix(uv, uv * 0.8 + 0.1, p);

    float wobble_amt = 0.025 * smoothstep(0.0, 1.0, p);
    vec2 wobbled_uv = zoomed_uv + cos(t * vec2(4.0, 6.0) + zoomed_uv * 10.0) * wobble_amt;

    vec4 color = texture(sourceImage, wobbled_uv);

    float tail = smoothstep(1.0, 0.85, p);
    fragColor = color * (1.0 - p) * tail;
}

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
