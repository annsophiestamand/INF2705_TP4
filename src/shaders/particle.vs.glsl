#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 velocity;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 size;
layout (location = 4) in float timeToLive;

uniform mat4 modelView;

out ATTRIB_VS_OUT
{
    vec4 color;
    vec2 size;
} attribOut;

void main()
{
    vec3 debugPosition = vec3(0.0, 0.0, 0.0);
    gl_Position = modelView * vec4(debugPosition, 1.0);
    attribOut.color = vec4(1.0, 0.0, 0.0, 1.0);
    attribOut.size = vec2(0.1, 0.1);
}
