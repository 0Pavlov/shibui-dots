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

// Ported from skwd-wall overexposure transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                float strength = 0.6;
                float PI = 3.141592653589793;

                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                float to_m = p + sin(PI * p) * strength;
                vec4 mixed = vec4(
                    win.r * win.a * to_m,
                    win.g * win.a * to_m,
                    win.b * win.a * to_m,
                    win.a * p
                );

                fragColor = mixed;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
