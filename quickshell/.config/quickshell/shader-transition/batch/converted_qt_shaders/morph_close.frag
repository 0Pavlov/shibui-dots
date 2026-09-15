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

// Ported from skwd-wall morph transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                float strength_v = 0.15;

                vec2 tc0 = uv;
                vec4 cb = texture(sourceImage, tc0.st);
                vec2 ob = ((cb.rg + cb.b) * 0.5) * 2.0 - 1.0;
                vec2 oc = ob * strength_v;
                float w1 = 1.0 - p;

                vec2 sample_uv = uv - oc * w1;
                vec2 tc = sample_uv;
                vec4 win = texture(sourceImage, tc.st);

                fragColor = win * p;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
