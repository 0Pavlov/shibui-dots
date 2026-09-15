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

// Ported from skwd-wall directional transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                vec2 dir = vec2(0.0, 1.0);
                vec2 q = uv + p * sign(dir);
                float inside = step(0.0, q.y) * step(q.y, 1.0) * step(0.0, q.x) * step(q.x, 1.0);

                fragColor = win * (1.0 - inside);
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
