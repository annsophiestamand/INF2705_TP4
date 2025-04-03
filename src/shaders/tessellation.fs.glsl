#version 330 core

in ATTRIB_GS_OUT
{
    float height;
    vec2 texCoords;
    vec4 patchDistance;
    vec3 barycentricCoords;
} attribIn;

uniform sampler2D groundSampler;
uniform sampler2D sandSampler;
uniform sampler2D snowSampler;
uniform bool viewWireframe;

out vec4 FragColor;

float edgeFactor(vec3 barycentricCoords, float width)
{
    vec3 d = fwidth(barycentricCoords);
    vec3 f = step(d * width, barycentricCoords);
    return min(min(f.x, f.y), f.z);
}

float edgeFactor(vec4 barycentricCoords, float width)
{
    vec4 d = fwidth(barycentricCoords);
    vec4 f = step(d * width, barycentricCoords);
    return min(min(min(f.x, f.y), f.z), f.w);
}

const vec3 WIREFRAME_COLOR = vec3(0.5f);
const vec3 PATCH_EDGE_COLOR = vec3(1.0f, 0.0f, 0.0f);

const float WIREFRAME_WIDTH = 0.5f;
const float PATCH_EDGE_WIDTH = 0.5f;

void main()
{
	// Sample textures
    vec4 sandColor = texture(sandSampler, attribIn.texCoords);
    vec4 grassColor = texture(groundSampler, attribIn.texCoords);
    vec4 snowColor = texture(snowSampler, attribIn.texCoords);
    
    // Determine texture mix factors based on height
    float height = attribIn.height;
    
    // Between 0.0 and 0.3: sand
    // Between 0.3 and 0.35: sand and grass blend
    // Between 0.35 and 0.6: grass
    // Between 0.6 and 0.65: grass and snow blend
    // Between 0.65 and 1.0: snow
    
    // Sand to grass transition
    float sandGrassFactor = smoothstep(0.3, 0.35, height);
    
    // Grass to snow transition
    float grassSnowFactor = smoothstep(0.6, 0.65, height);
    
    // Mix sand and grass
    vec4 sandGrassColor = mix(sandColor, grassColor, sandGrassFactor);
    
    // Mix grass and snow
    vec4 grassSnowColor = mix(grassColor, snowColor, grassSnowFactor);
    
    // Final color based on height
    vec4 terrainColor;
    if (height < 0.35) {
        terrainColor = sandGrassColor;
    } else if (height < 0.6) {
        terrainColor = grassColor;
    } else {
        terrainColor = grassSnowColor;
    }
    
    // Calculate wireframe and patch edge factors
    float wireframeFactor = edgeFactor(attribIn.barycentricCoords, WIREFRAME_WIDTH);
    float patchEdgeFactor = edgeFactor(attribIn.patchDistance, PATCH_EDGE_WIDTH);
    
    // Final color with wireframe if enabled
    if (viewWireframe) {
        // Mix terrain color with wireframe color
        vec3 color = mix(WIREFRAME_COLOR, terrainColor.rgb, wireframeFactor);
        
        // Mix with patch edge color
        color = mix(PATCH_EDGE_COLOR, color, patchEdgeFactor);
        
        FragColor = vec4(color, 1.0);
    } else {
        FragColor = terrainColor;
    }
}
