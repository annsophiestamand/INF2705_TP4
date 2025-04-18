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
    for ( int i = 0 ; i < gl_in.length() ; ++i )
    {
        attribOut.height = attribIn[i].height;
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.patchDistance = attribIn[i].patchDistance;
        vec3 baryConst = vec3(0);
        baryConst[i] = 1;
        attribOut.barycentricCoords = baryConst;
        gl_Position = gl_in[i].gl_Position;

        EmitVertex();
    }


}
