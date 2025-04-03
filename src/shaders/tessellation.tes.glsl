#version 400 core

layout(quads) in;

/*
in Attribs {
    vec4 couleur;
} AttribsIn[];*/


out ATTRIB_TES_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
} attribOut;

uniform mat4 mvp;

uniform sampler2D heighmapSampler;

vec4 interpole( vec4 v0, vec4 v1, vec4 v2, vec4 v3 )
{
    // Bilinear interpolation
    vec4 a = mix(v0, v1, gl_TessCoord.x);
    vec4 b = mix(v3, v2, gl_TessCoord.x);
    return mix(a, b, gl_TessCoord.y);

}


const float PLANE_SIZE = 256.0f;

void main()
{
	 // Interpolate position from the 4 control points
    vec4 pos = interpole(
        gl_in[0].gl_Position,
        gl_in[1].gl_Position,
        gl_in[2].gl_Position,
        gl_in[3].gl_Position
    );
    
    // Convert position to texture coordinates in [0,1] range
    // The plane is centered at (0,0) and has size PLANE_SIZE
    vec2 heightmapCoord = vec2(
        (pos.x + PLANE_SIZE/2.0) / PLANE_SIZE,
        (pos.z + PLANE_SIZE/2.0) / PLANE_SIZE
    );
    
    // Divide by 4 to stretch texture and reduce mountain frequency
    heightmapCoord = heightmapCoord / 4.0;
    
    // Sample height from heightmap (using red channel)
    float heightValue = texture(heighmapSampler, heightmapCoord).r;
    
    // Convert height from [0,1] to [-32, 32]
    float worldHeight = heightValue * 64.0 - 32.0;
    
    // Update position with the calculated height
    pos.y = worldHeight;
    
    // Set patch distance (barycentric coordinates for the quad)
    attribOut.patchDistance = vec4(
        gl_TessCoord.x,
        gl_TessCoord.y,
        1.0 - gl_TessCoord.x,
        1.0 - gl_TessCoord.y
    );
    
    // Set texture coordinates for fragment shader (multiplied by 2 for repetition)
    attribOut.texCoords = gl_TessCoord.xy * 2.0;
    
    // Store normalized height for fragment shader
    attribOut.height = heightValue;
    
    // Apply matrix transformations
    gl_Position = mvp * pos;
}
