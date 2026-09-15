#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;  // Changed from 'time' to 'progress'
} ubuf;

layout(binding = 1) uniform sampler2D sourceImage;

void main() {
    // As progress goes from 0.0 to 1.0, the line moves right to left seamlessly
    float linePos = 1.1 - (ubuf.progress * 1.2);
    float gradientWidth = 0.05;
    
    // Calculate the alpha wipe mask
    float alphaMask = 1.0 - smoothstep(linePos - gradientWidth, linePos + gradientWidth, qt_TexCoord0.x);

    // Sample the color of the screenshot
    vec4 texColor = texture(sourceImage, qt_TexCoord0);
    
    fragColor = texColor * alphaMask * ubuf.qt_Opacity;
}
