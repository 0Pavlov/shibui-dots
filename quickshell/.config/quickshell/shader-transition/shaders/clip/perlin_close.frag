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

// Ported from skwd-wall perlin transition

            float perlin_random(vec2 co) {
                float a = 12.9898;
                float b = 78.233;
                float c = 43758.5453;
                float dt = dot(co.xy, vec2(a, b));
                float sn = mod(dt, 3.14);
                return fract(sin(sn) * c);
            }

            float perlin_noise(in vec2 st) {
                vec2 i = floor(st);
                vec2 f = fract(st);
                float a = perlin_random(i);
                float b = perlin_random(i + vec2(1.0, 0.0));
                float c = perlin_random(i + vec2(0.0, 1.0));
                float d = perlin_random(i + vec2(1.0, 1.0));
                vec2 u = f * f * (3.0 - 2.0 * f);
                return mix(a, b, u.x) +
                    (c - a) * u.y * (1.0 - u.x) +
                    (d - b) * u.x * u.y;
            }

            
void qt_original_main() {

                float pr = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;
                vec2 tc = uv;
                vec4 win = texture(sourceImage, tc.st);

                float scale = 4.0;
                float smoothness = 0.01;
                float n = perlin_noise(uv * scale);
                float p = mix(-smoothness, 1.0 + smoothness, pr);
                float lower = p - smoothness;
                float higher = p + smoothness;
                float q = smoothstep(lower, higher, n);
                float reveal = 1.0 - q;

                fragColor = win * reveal;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
