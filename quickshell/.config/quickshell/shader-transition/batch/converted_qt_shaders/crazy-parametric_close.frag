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

// Ported from skwd-wall crazy-parametric transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                float a = 4.0;
                float b = 1.0;
                float amplitude = 120.0;
                float smoothness = 0.1;
                vec2 dir = uv - vec2(0.5);
                float dist = length(dir);
                float xx = (a - b) * cos(p) + b * cos(p * ((a / b) - 1.0));
                float yy = (a - b) * sin(p) - b * sin(p * ((a / b) - 1.0));
                vec2 offset = dir * vec2(sin(p * dist * amplitude * xx), sin(p * dist * amplitude * yy)) / smoothness;

                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                float reveal = smoothstep(0.2, 1.0, p);
                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
