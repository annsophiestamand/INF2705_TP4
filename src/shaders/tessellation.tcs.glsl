#version 400 core

layout(vertices = 4) out;

uniform mat4 modelView;


const float MIN_TESS = 4;
const float MAX_TESS = 64;

const float MIN_DIST = 30.0f;
const float MAX_DIST = 100.0f;

void main()
{
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    
    if (gl_InvocationID == 0) {
        // Calculate centers of each edge in view space
        // Edge 0 (OL-0): between vertices 0(0,0) and 3(0,1)
        vec4 edge0Center = modelView * (gl_in[0].gl_Position + gl_in[3].gl_Position) * 0.5;
        
        // Edge 1 (OL-1): between vertices 0(0,0) and 1(1,0)
        vec4 edge1Center = modelView * (gl_in[0].gl_Position + gl_in[1].gl_Position) * 0.5;
        
        // Edge 2 (OL-2): between vertices 1(1,0) and 2(1,1)
        vec4 edge2Center = modelView * (gl_in[1].gl_Position + gl_in[2].gl_Position) * 0.5;
        
        // Edge 3 (OL-3): between vertices 2(1,1) and 3(0,1)
        vec4 edge3Center = modelView * (gl_in[2].gl_Position + gl_in[3].gl_Position) * 0.5;
        
        // Calculate distance from camera to each edge center
        float dist0 = length(edge0Center.xyz);
        float dist1 = length(edge1Center.xyz);
        float dist2 = length(edge2Center.xyz);
        float dist3 = length(edge3Center.xyz);
        
        // Normalize and clamp distances to [0,1] range
        float t0 = clamp((dist0 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0, 1.0);
        float t1 = clamp((dist1 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0, 1.0);
        float t2 = clamp((dist2 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0, 1.0);
        float t3 = clamp((dist3 - MIN_DIST) / (MAX_DIST - MIN_DIST), 0.0, 1.0);
        
        // Linear interpolation between MIN_TESS and MAX_TESS based on distance
        float tess0 = mix(MAX_TESS, MIN_TESS, t0);
        float tess1 = mix(MAX_TESS, MIN_TESS, t1);
        float tess2 = mix(MAX_TESS, MIN_TESS, t2);
        float tess3 = mix(MAX_TESS, MIN_TESS, t3);
        
        // Assign tessellation levels to each edge
        gl_TessLevelOuter[0] = tess0; // OL-0 (left edge)
        gl_TessLevelOuter[1] = tess1; // OL-1 (bottom edge)
        gl_TessLevelOuter[2] = tess2; // OL-2 (right edge)
        gl_TessLevelOuter[3] = tess3; // OL-3 (top edge)
        
        // Set inner tessellation levels as maximum of the outer edges
        // IL-0: horizontal inner level (max of top and bottom edges)
        gl_TessLevelInner[0] = max(tess1, tess3);
        // IL-1: vertical inner level (max of left and right edges)
        gl_TessLevelInner[1] = max(tess0, tess2);
    }

}
