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

void qt_original_main() {

                float p = ubuf.progress;
                vec2 uv = qt_TexCoord0;

                vec2 center = vec2(0.5, 0.5);
                float scale = mix(1.0, 0.95, p);
                vec2 scaled_uv = (uv - center) / scale + center;

                vec2 tex_coords = scaled_uv;
                vec4 color = texture(sourceImage, tex_coords.st);

                float alpha = smoothstep(1.0, 0.2, p);

                fragColor = color * alpha;
            }

// --- Qt Automatic Opacity Wrapper ---
void main() {
    qt_original_main();
    fragColor *= ubuf.qt_Opacity;
}
