#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;


in ATTRIB_TES_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
} attribIn[];

out ATTRIB_GS_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribOut;

void main()
{
    
     // Process each vertex of the triangle
    for (int i = 0; i < 3; i++)
    {
        // Pass through position
        gl_Position = gl_in[i].gl_Position;
        
        // Pass through existing attributes
        attribOut.height = attribIn[i].height;
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.patchDistance = attribIn[i].patchDistance;
        
        // Generate barycentric coordinates for wireframe rendering
        // Each vertex gets a different coordinate (1,0,0), (0,1,0), or (0,0,1)
        attribOut.barycentricCoords = vec3(0.0);
        attribOut.barycentricCoords[i] = 1.0;
        
        // Emit the vertex
        EmitVertex();
    }
    
    // End the primitive (triangle)
    EndPrimitive();
}
