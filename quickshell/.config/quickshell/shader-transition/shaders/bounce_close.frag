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

// Ported from skwd-wall bounce transition

            
void qt_original_main() {

                float p = ubuf.progress;
                vec2 uv = qt_TexCoord0;
                float PI = 3.14159265358;
                float bounces = 3.0;

                float time = p;
                float stime = sin(time * PI / 2.0);
                float phase = time * PI * bounces;
                float yy = (abs(cos(phase))) * (1.0 - stime);
                float d = uv.y - yy;

                vec2 sample_uv = uv;
                sample_uv.y = uv.y + (1.0 - yy);
                vec2 tc = sample_uv;
                vec4 win = texture(sourceImage, tc.st);

                float reveal = step(d, 0.0);
                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
