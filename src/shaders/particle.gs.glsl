#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;


in ATTRIB_VS_OUT
{
    vec4 color;
    vec2 size;
} attribIn[];

out ATTRIB_GS_OUT
{
    vec4 color;
    vec2 texCoords;
} attribOut;

uniform mat4 projection;

void main()
{
    vec4 center = gl_in[0].gl_Position;
    vec2 halfSize = attribIn[0].size * 0.5;

    vec2 offsets[4] = vec2[](
        vec2(-halfSize.x, -halfSize.y),
        vec2( halfSize.x, -halfSize.y),
        vec2(-halfSize.x,  halfSize.y),
        vec2( halfSize.x,  halfSize.y)
    );

    const vec2 texCoords[4] = vec2[](
        vec2(0.0, 0.0),
        vec2(1.0, 0.0),
        vec2(0.0, 1.0),
        vec2(1.0, 1.0)
    );

    for (int i = 0 ; i < 4 ; i++){
        gl_Position = projection * (center + vec4(offsets[i], 0.0, 0.0));
        attribOut.color = attribIn[0].color;
        attribOut.texCoords = texCoords[i];
        EmitVertex();
    }
    
    EndPrimitive();
}
