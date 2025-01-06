// Vertex shader
uniform float time;

vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    // Add some wave motion to particles
    vertex.x += sin(time * 2.0 + vertex.y) * 0.02;
    vertex.y += cos(time * 2.0 + vertex.x) * 0.02;
    return projection * transform * vertex;
}

// Fragment shader
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    // Calculate distance from center
    vec2 center = vec2(0.5, 0.5);
    float dist = length(uv - center);
    
    // Create soft particle effect
    float alpha = smoothstep(0.5, 0.0, dist);
    
    // Add some sparkle
    float sparkle = fract(sin(dot(uv, vec2(12.9898, 78.233)) + time) * 43758.5453);
    sparkle = pow(sparkle, 20.0) * 0.5;
    
    // Final color
    vec4 particleColor = graphicsColor;
    particleColor.a *= alpha;
    particleColor.rgb += sparkle;
    
    return particleColor;
} 