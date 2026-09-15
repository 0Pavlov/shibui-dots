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

// Ported from skwd-wall ink-splash transition

            float is_hash(vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
            }

            float is_noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                return mix(mix(is_hash(i), is_hash(i + vec2(1.0, 0.0)), f.x),
                           mix(is_hash(i + vec2(0.0, 1.0)), is_hash(i + vec2(1.0, 1.0)), f.x), f.y);
            }

            float is_fbm(vec2 p) {
                float v = 0.0;
                float amp = 0.5;
                for (int i = 0; i < 4; i++) {
                    v += amp * is_noise(p);
                    p *= 2.1;
                    amp *= 0.5;
                }
                return v;
            }

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                float blob = is_fbm(uv * 3.5);
                float fingers = is_fbm(uv * 14.0);
                float distortion = (blob - 0.5) * 0.5 + (fingers - 0.5) * 0.18;
                vec2 c = uv - vec2(0.5);
                c.x *= ubuf.surface_size.x / max(ubuf.surface_size.y, 0.0001);
                float d = length(c);
                float splash_d = d + distortion;
                float boundary = p * 1.7 - 0.15;
                float diff = splash_d - boundary;
                float reveal = smoothstep(0.04, -0.04, diff);

                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
