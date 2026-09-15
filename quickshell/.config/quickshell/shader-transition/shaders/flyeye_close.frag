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

// Ported from skwd-wall flyeye transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                float sz = 0.04;
                float zoom = 50.0;
                float inv = 1.0 - p;
                vec2 disp = sz * vec2(cos(zoom * uv.x), sin(zoom * uv.y));
                vec2 sample_uv = uv + inv * disp;

                vec2 tc = sample_uv;
                vec4 win = texture(sourceImage, tc.st);

                fragColor = win * p;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
