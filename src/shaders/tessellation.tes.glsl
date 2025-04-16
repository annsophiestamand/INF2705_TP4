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
    vec4 a = mix(v0, v1, gl_TessCoord.x);
    vec4 b = mix(v3, v2, gl_TessCoord.x);
    return mix(a, b, gl_TessCoord.y);
}


const float PLANE_SIZE = 256.0f;

void main()
{
	vec4 position = interpole( gl_in[0].gl_Position, gl_in[1].gl_Position, gl_in[2].gl_Position, gl_in[3].gl_Position );

    // Pour heighmap, seule le plan xz est utiliser pour élevé les points selon leur brightness dans le plan y.
    // Si le plan est 0-1, alors le plan est -PLANE_SIZE/2 à PLANE_SIZE/2, et on le converti en 0-1 en divisant par PLANE_SIZE
    // Il est ensuite demander de diviser par 4 pour étirer la texture

    float heighMapX = ((position.x + PLANE_SIZE/2)/ PLANE_SIZE) / 4;
    float heighMapZ = ((position.z + PLANE_SIZE/2)/ PLANE_SIZE) / 4;
    
    // doit faire un vec2 car la fonction texture va utiliser le sampler2d

    vec2 heighMap = vec2(heighMapX,heighMapZ);

    // brightness (donc hauteur) est donnée dans la composante r de la texture qui est en noire et blanc comme dans tp3 speculaire 
    float height = texture(heighmapSampler, heighMap).r;

    // convertir la hauteur de 0-1 à [-32/32]
    float vertexHeight = height * 64 - 32;

    attribOut.patchDistance = vec4(gl_TessCoord.x, gl_TessCoord.y, 1-gl_TessCoord.x, 1-gl_TessCoord.y);

    // attribut en sortie doit avoir la valeur normalisé
    position.y = vertexHeight;

    attribOut.texCoords.x = gl_TessCoord.x * 2.0;
    attribOut.texCoords.y = gl_TessCoord.y * 2.0;
    attribOut.height = height;

    gl_Position = mvp * position;


}