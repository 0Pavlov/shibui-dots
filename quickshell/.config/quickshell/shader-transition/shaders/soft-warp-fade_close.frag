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

// Ported from skwd-wall soft-warp-fade transition

            float swf_hash(vec2 p) {
                return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
            }

            float swf_noise(vec2 p) {
                vec2 i = floor(p);
                vec2 f = fract(p);
                f = f * f * (3.0 - 2.0 * f);
                return mix(mix(swf_hash(i), swf_hash(i + vec2(1.0, 0.0)), f.x),
                           mix(swf_hash(i + vec2(0.0, 1.0)), swf_hash(i + vec2(1.0, 1.0)), f.x), f.y);
            }

            
void qt_original_main() {

                float p = 1.0 - ubuf.progress;
                vec2 uv = qt_TexCoord0;

                float strength = sin(p * 3.14159) * 0.025;
                vec2 warp = vec2(
                    swf_noise(uv * 3.0 + vec2(0.0, p * 0.5)),
                    swf_noise(uv * 3.0 + vec2(p * 0.5, 0.0))
                ) - 0.5;
                vec2 warped = uv + warp * strength;

                vec2 tc = warped;
                vec4 win = texture(sourceImage, tc.st);

                float t = smoothstep(0.05, 0.95, p);
                t = t * t * (3.0 - 2.0 * t);
                fragColor = win * t;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
