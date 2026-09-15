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

// Ported from gl-transitions/ripple.glsl (MIT, gre)

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                float seed_local = ubuf.seed * 6.28318;

                float amplitude = 100.0;
                float speed = 50.0;

                vec2 dir = uv - vec2(0.5);
                float dist = length(dir);

                float intensity = (1.0 - p) * (1.0 - p);
                vec2 offset = dir * (sin(p * dist * amplitude - p * speed + seed_local) + 0.5) / 30.0;

                vec2 wuv = uv + offset * intensity;
                vec2 tc = wuv;
                vec4 color = texture(sourceImage, tc.st);

                float alpha = smoothstep(0.0, 0.3, p);
                fragColor = color * alpha;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
