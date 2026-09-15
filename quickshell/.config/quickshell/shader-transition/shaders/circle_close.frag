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

// Ported from gl-transitions/circleopen.glsl (MIT, gre)

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                float seed_local = ubuf.seed;

                float smoothness = 0.3;
                float SQRT_2 = 1.414213562;

                vec2 center = vec2(0.5 + (seed_local - 0.5) * 0.15, 0.5 + (seed_local * 0.7 - 0.35) * 0.15);

                float dist = SQRT_2 * distance(center, uv);
                float m = smoothstep(-smoothness, 0.0, dist - p * (1.0 + smoothness));
                float reveal = 1.0 - m;

                vec2 tc = uv;
                vec4 color = texture(sourceImage, tc.st);

                fragColor = color * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
