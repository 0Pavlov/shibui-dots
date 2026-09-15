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

// Ported from skwd-wall plasma-flow transition

            float pf_hash(vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
            }

            float pf_noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                return mix(mix(pf_hash(i), pf_hash(i + vec2(1.0, 0.0)), f.x),
                           mix(pf_hash(i + vec2(0.0, 1.0)), pf_hash(i + vec2(1.0, 1.0)), f.x), f.y);
            }

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                vec2 flow = vec2(
                    pf_noise(uv * 5.0 + vec2(p * 2.0, 0.0)),
                    pf_noise(uv * 5.0 + vec2(0.0, p * 2.0))
                ) - 0.5;
                float intensity = sin(p * 3.14159) * 0.18;
                vec2 distorted = uv + flow * intensity;

                vec2 tc = distorted;
                vec4 win = texture(sourceImage, tc.st);

                float reveal = smoothstep(0.2, 0.8, p);
                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
