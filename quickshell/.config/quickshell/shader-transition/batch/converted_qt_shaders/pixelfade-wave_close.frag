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

// Ported from skwd-wall pixelfade-wave transition

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                float wave_x = (uv.x + uv.y) * 0.5;
                float wave_p = smoothstep(0.0, 1.0, p * 1.6 - wave_x * 0.6);
                float bump = sin(wave_p * 3.14159);
                float blocks = mix(800.0, 8.0, bump);
                vec2 q = floor(uv * blocks) / blocks + 0.5 / blocks;

                vec2 tc = q;
                vec4 win = texture(sourceImage, tc.st);

                float reveal = smoothstep(0.0, 1.0, wave_p);
                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
