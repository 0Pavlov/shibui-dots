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

// Ported from skwd-wall crosswarp transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                float x = smoothstep(0.0, 1.0, (p * 2.0 + uv.x - 1.0));
                vec2 warped = clamp((uv - 0.5) * x + 0.5, vec2(0.0), vec2(1.0));

                vec2 tc = warped;
                vec4 win = texture(sourceImage, tc.st);

                float in_bounds = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
                fragColor = win * x * in_bounds;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
