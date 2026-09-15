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
    
    // --- ROUNDED EDGE CALCULATION ---
    
    // Define the geometry of the row
    float rowHeight = 1.0 / rows;
    float centerY = (rowId + 0.5) * rowHeight;
    float radiusY = rowHeight * 0.5; // Radius of the rounded cap
    
    // Aspect ratio correction to ensure the ends are perfectly circular 
    // instead of stretched ovals. Adjust this (e.g. 1.0 for squares) if 
    // your texture/element is not a 16:9 rectangle!
    float aspectRatio = 16.0 / 9.0;
    float radiusX = radiusY / aspectRatio;
    
    // Calculate the right-most tip position of the row
    float linePos = 1.5 - (ubuf.progress * 2.0); 
    float edgeX = linePos - offset;
    
    // The center point of the semi-circle cap is pulled back by the radius
    float capCenterX = edgeX - radiusX;
    
    // Calculate a 2D Distance Field (SDF) to the central line segment
    vec2 p = qt_TexCoord0;
    
    // Find the closest point on the horizontal line segment of the current row
    // The segment goes horizontally from x = -infinity to x = capCenterX
    vec2 closestLinePoint = vec2(min(p.x, capCenterX), centerY);
    
    // Vector to the closest point, stretched by aspect ratio so X and Y math matches
    vec2 distVec = p - closestLinePoint;
    distVec.x *= aspectRatio;
    
    // True Euclidean distance from the core of the line
    float dist = length(distVec);
    
    // Apply smoothstep for a sharp, anti-aliased rounded edge
    float gradientWidth = 0.002; // Keeps the edges crisp
    float alphaMask = 1.0 - smoothstep(radiusY - gradientWidth, radiusY + gradientWidth, dist);
    
    // Make so there is no gaps between the lines on the left
    alphaMask = max(alphaMask, step(p.x, capCenterX));

    vec4 texColor = texture(sourceImage, qt_TexCoord0);
    fragColor = texColor * alphaMask * ubuf.qt_Opacity;
}
