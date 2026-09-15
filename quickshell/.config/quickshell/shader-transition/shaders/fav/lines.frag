#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
} ubuf;

layout(binding = 1) uniform sampler2D sourceImage;

// Pseudo-random hash
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    // Divide Y axis into segmented rows
    float rows = 45.0;
    float rowId = floor(qt_TexCoord0.y * rows);
    
    // Create static offset + slight animation jiggle for each row
    float rowOffset = random(vec2(rowId, 0.0)) * 0.4;
    float glitchAnim = sin(ubuf.progress * 40.0 + rowId) * 0.03;
    float offset = rowOffset + glitchAnim;
    
    // Wipe right to left, range extended to account for offset
    float linePos = 1.5 - (ubuf.progress * 2.0); 
    float gradientWidth = 0.01; // Sharp, digital edge
    
    float alphaMask = 1.0 - smoothstep(linePos - gradientWidth, linePos + gradientWidth, qt_TexCoord0.x + offset);

    vec4 texColor = texture(sourceImage, qt_TexCoord0);
    fragColor = texColor * alphaMask * ubuf.qt_Opacity;
}
