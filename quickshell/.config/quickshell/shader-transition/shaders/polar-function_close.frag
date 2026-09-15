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

// Ported from skwd-wall polar-function transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                int segments = 5;
                float angle = atan(uv.y - 0.5, uv.x - 0.5);
                float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
                float difference = length(uv - vec2(0.5, 0.5));
                float reveal = step(difference, radius * p);

                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
