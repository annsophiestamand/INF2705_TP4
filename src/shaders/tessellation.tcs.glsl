#version 400 core

layout(vertices = 4) out;

uniform mat4 modelView;


const float MIN_TESS = 4;
const float MAX_TESS = 32;

const float MIN_DIST = 30.0f;
const float MAX_DIST = 100.0f;

void main()
{
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

    // TODO

    gl_in[0].gl_Position; // (0,0)
    gl_in[1].gl_Position; // (1,0)
    gl_in[2].gl_Position; // (1,1)
    gl_in[3].gl_Position; // (0,1)
    
    if (gl_InvocationID == 0) {
        // multiplier par modelview pour avoir le point centre des cotés par rapport à la caméra
        vec4 OL0Centre = modelView * (gl_in[0].gl_Position + gl_in[3].gl_Position) * 0.5;
        vec4 OL1Centre = modelView * (gl_in[0].gl_Position + gl_in[1].gl_Position) * 0.5;
        vec4 OL2Centre = modelView * (gl_in[0].gl_Position + gl_in[1].gl_Position) * 0.5;
        vec4 OL3Centre = modelView * (gl_in[1].gl_Position + gl_in[2].gl_Position) * 0.5;

        // Distance du point par rapport à la caméra
        float ol0Dist = length(OL0Centre);
        float ol1Dist = length(OL1Centre);
        float ol2Dist = length(OL2Centre);
        float ol3Dist = length(OL3Centre);

        // si valeur < min, = min, si valeur > max, = max ; si dist = 22 -> dist = 30;
        float ol0Clamped = clamp( ol0Dist, MIN_DIST, MAX_DIST);
        float ol1Clamped = clamp( ol1Dist, MIN_DIST, MAX_DIST);
        float ol2Clamped = clamp( ol2Dist, MIN_DIST, MAX_DIST);
        float ol3Clamped = clamp( ol3Dist, MIN_DIST, MAX_DIST);

        // Calcul le ratio de tessellation T qui varie entre 0 et 1, ou 0 est le min dist et 1 le max dist.
        float ol0TessValue = (ol0Clamped - MIN_DIST) / (MAX_DIST - MIN_DIST);
        float ol1TessValue = (ol1Clamped - MIN_DIST) / (MAX_DIST - MIN_DIST);
        float ol2TessValue = (ol2Clamped - MIN_DIST) / (MAX_DIST - MIN_DIST);
        float ol3TessValue = (ol3Clamped - MIN_DIST) / (MAX_DIST - MIN_DIST);
        
        // Fait un niveau de division de chaque arrête selon la distance; plus est proche, plus il y a tessellation (subdivisions). Se base sur le facteur T.
        float tessLevel0 = mix( MAX_TESS, MIN_TESS, ol0TessValue);
        float tessLevel1 = mix( MAX_TESS, MIN_TESS, ol1TessValue);
        float tessLevel2 = mix( MAX_TESS, MIN_TESS, ol2TessValue);
        float tessLevel3 = mix( MAX_TESS, MIN_TESS, ol3TessValue);

        // Step 5: set the corresponding outer edge tessellation levels (https://learnopengl.com/Guest-Articles/2021/Tessellation/Tessellation)
        gl_TessLevelOuter[0] = tessLevel0; 
        gl_TessLevelOuter[1] = tessLevel1;
        gl_TessLevelOuter[2] = tessLevel2;
        gl_TessLevelOuter[3] = tessLevel3;

        // Step 6: set the inner tessellation levels to the max of the two parallel edges (learnopengl)
        // tess0 (Gauche) et tess2(droite), tess1(Bas) et tess3(haut)
        gl_TessLevelInner[0] = max(tessLevel1, tessLevel3);
        gl_TessLevelInner[1] = max(tessLevel0, tessLevel2);
        
    }

}
