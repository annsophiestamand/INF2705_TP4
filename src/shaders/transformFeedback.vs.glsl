#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 velocity;
layout (location = 2) in vec4 color;
layout (location = 3) in vec2 size;
layout (location = 4) in float timeToLive;

out vec3 positionMod;
out vec3 velocityMod;
out vec4 colorMod;
out vec2 sizeMod;
out float timeToLiveMod;

uniform float time;
uniform float dt; // delta time

uint seed = uint(time * 1000.0) + uint(gl_VertexID);
uint randhash( ) // entre  0 et UINT_MAX
{
    uint i=((seed++)^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u); i *= 2654435769u; i += (i<<5u)^(i>>12u);
    return i;
}
float random() // entre  0 et 1
{
    const float UINT_MAX = 4294967295.0;
    return float(randhash()) / UINT_MAX;
}

float randomInRange(float min, float max) // entre  min et max
{
    return min + random() * (max - min);
}

const float PI = 3.14159265359f;
vec3 randomInCircle(in float radius, in float height)
{
    float r = radius * sqrt(random());
    float theta = random() * 2 * PI;
    return vec3(r * cos(theta), height, r * sin(theta));
}


const float MIN_TIME_TO_LIVE = 1.7f;
const float MAX_TIME_TO_LIVE = 2.0f;
const float INITIAL_RADIUS = 0.2f;
const float INITIAL_HEIGHT = 0.0f;
const float FINAL_RADIUS = 0.5f;
const float FINAL_HEIGHT = 5.0f;

const float INITIAL_SPEED_MIN = 0.5f;
const float INITIAL_SPEED_MAX = 0.6f;

const float INITIAL_ALPHA = 0.0f;
const float ALPHA = 0.1f;
const vec3 YELLOW_COLOR = vec3(1.0f, 0.9f, 0.0f);
const vec3 ORANGE_COLOR = vec3(1.0f, 0.4f, 0.2f);
const vec3 DARK_RED_COLOR = vec3(0.1, 0.0, 0.0);

const vec3 ACCELERATION = vec3(0.0f, 0.1f, 0.0f);

float getAlphaValue(float timeToLive)
{
    float increase = smoothstep(0.0, 0.2, timeToLive);
    float decrease = smoothstep(0.8, 1.0, timeToLive);
    return (increase * (1.0 - decrease)) * ALPHA;
}

vec4 chooseColor(float timeToLive)
{
    float timeToLiveNormalised = timeToLive / MAX_TIME_TO_LIVE;

    if (timeToLiveNormalised <= 0.25){
        return vec4(YELLOW_COLOR, ALPHA);
    } else if (timeToLiveNormalised <= 0.3){
        return vec4(mix(YELLOW_COLOR, ORANGE_COLOR, smoothstep(0.25, 0.3, timeToLiveNormalised)), getAlphaValue(timeToLiveNormalised));
    } else if (timeToLiveNormalised <= 0.5){
        return vec4(ORANGE_COLOR, ALPHA);
    } else if(timeToLiveNormalised <= 1) {
        return vec4(mix(ORANGE_COLOR, DARK_RED_COLOR, smoothstep(0.25, 0.3, timeToLiveNormalised)), getAlphaValue(timeToLiveNormalised));
    }
    return vec4(YELLOW_COLOR, ALPHA); // Par défaut je retourne du jaune
}

void main()
{
    if(timeToLive < 0.0){
        positionMod = randomInCircle(0.2, 0.0);
        vec3 particleCone = randomInCircle(0.5, 5.0);
        float particleModule = randomInRange(0.5, 0.6);
        velocityMod = particleCone * particleModule;
        colorMod = vec4(YELLOW_COLOR, 0.0);
        sizeMod = vec2(0.5, 1.0);
        timeToLiveMod = randomInRange(1.7, 2.0);
    } else {
        positionMod = position + velocity * dt;
        velocityMod = velocity + ACCELERATION * dt;
        colorMod = chooseColor(timeToLive);

        float normalizedTime = timeToLive / MAX_TIME_TO_LIVE;
        float scale = mix(1.0, 1.5, normalizedTime);
        sizeMod = vec2(0.5, 1.0) * scale;
        timeToLiveMod = timeToLive - dt;
    }
}

