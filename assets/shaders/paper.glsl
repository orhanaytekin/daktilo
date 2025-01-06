// Vertex shader
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    return projection * transform * vertex;
}

// Fragment shader
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    // Paper texture effect
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    vec4 paperColor = vec4(0.98, 0.97, 0.95, 1.0);
    
    // Add subtle grain
    float grain = fract(sin(dot(uv * 100.0, vec2(127.1, 311.7))) * 43758.5453);
    grain = mix(0.95, 1.0, grain);
    
    // Add subtle yellowing at edges
    float edgeEffect = smoothstep(0.0, 0.2, uv.x) * smoothstep(0.0, 0.2, 1.0 - uv.x) *
                      smoothstep(0.0, 0.2, uv.y) * smoothstep(0.0, 0.2, 1.0 - uv.y);
    vec4 edgeColor = vec4(0.98, 0.95, 0.9, 1.0);
    
    // Combine effects
    vec4 finalColor = mix(edgeColor, paperColor, edgeEffect);
    finalColor.rgb *= grain;
    
    return mix(graphicsColor, finalColor, noise * 0.15);
} 