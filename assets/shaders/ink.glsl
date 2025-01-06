// Vertex shader
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    return projection * transform * vertex;
}

// Fragment shader
uniform float time;
uniform vec2 resolution;
uniform float spread;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    // Ink spreading effect
    float noise = fract(sin(dot(uv * time, vec2(12.9898, 78.233))) * 43758.5453);
    float spread = sin(time * 10.0) * 0.005;
    
    // Create ink bleeding effect
    vec2 offset = vec2(spread * noise);
    vec4 inkColor = vec4(0.0, 0.0, 0.0, graphicsColor.a);
    
    // Sample multiple times for a more natural look
    vec4 color = inkColor;
    for(int i = 0; i < 4; i++) {
        vec2 offsetUV = uv + offset * float(i);
        color += inkColor * (1.0 - float(i) * 0.2);
    }
    color /= 4.0;
    
    // Add slight color variation
    color.rgb += noise * 0.1;
    
    // Blend with paper
    return mix(graphicsColor, color, graphicsColor.a);
} 