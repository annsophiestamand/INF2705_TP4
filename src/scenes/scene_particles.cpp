#include "scene_particles.h"

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "imgui/imgui.h"

#include "utils.h"
#include "shader_object.h"

#include <iostream>



static const unsigned int MAX_N_PARTICULES = 1000;
static Particle particles[MAX_N_PARTICULES] = { {{0,0,0},{0,0,0},{0,0,0,0}, {0,0},0} };

SceneParticles::SceneParticles(bool& isMouseMotionEnabled)
: Scene()
, m_isMouseMotionEnabled(isMouseMotionEnabled)
, m_cameraOrientation(0)
, m_totalTime(0.0f)
, m_cumulativeTime(0.0f)
, m_tfo(0)
, m_vao(0)
, m_vbo{0, 0}
, m_nParticles(1)
, m_nMaxParticles(MAX_N_PARTICULES)
, m_transformFeedbackShaderProgram("TransformFeedback")
, m_timeLocationTransformFeedback(-1)
, m_dtLocationTransformFeedback(-1)
, m_particleShaderProgram("ParticleShader")
, m_modelViewLocationParticle(-1)
, m_projectionLocationParticle(-1)
, m_flameTexture("../textures/flame.png")
, m_menuVisible(true)
{
    initializeShader();
    initializeTexture();

    glEnable(GL_PROGRAM_POINT_SIZE);
    
    // Allouer des ressources
    glGenVertexArrays(1, &m_vao);
    glGenBuffers(2, m_vbo);

    glBindVertexArray(m_vao);

    // VBO entrée
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Particle) * MAX_N_PARTICULES, particles, GL_DYNAMIC_COPY);
    
    // Activer les attributs du VAO
    for(int i = 0 ; i < 5 ; i++){
        glEnableVertexAttribArray(i);
    }

    // VBO sortie
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Particle) * MAX_N_PARTICULES, nullptr, GL_DYNAMIC_COPY);

    // Création objets de rétroaction
    glGenTransformFeedbacks(1, &m_tfo);
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK, m_tfo);
}

SceneParticles::~SceneParticles()
{
    glDeleteBuffers(2, m_vbo);
    glDeleteVertexArrays(1, &m_vao);
    glDeleteTransformFeedbacks(1, &m_tfo);
}

void SceneParticles::run(Window& w, double dt)
{
    updateInput(w, dt);
    
    drawMenu();
    
    glm::mat4 view = getCameraThirdPerson(2.5);
    glm::mat4 projPersp = getProjectionMatrix(w);
    glm::mat4 modelView = view;

    m_totalTime += dt;
    m_cumulativeTime += dt;
    if (dt == 0.0f)
        m_nParticles = 1;

    m_transformFeedbackShaderProgram.use();
    glUniform1f(m_timeLocationTransformFeedback, m_totalTime);
    glUniform1f(m_dtLocationTransformFeedback, (float)dt);
    
    // buffer binding    
    bindBuffer();

    // update particles
    glEnable(GL_RASTERIZER_DISCARD);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);

    glBeginTransformFeedback(GL_POINTS);
    glDrawArrays(GL_POINTS, 0, m_nParticles);
    glEndTransformFeedback();

    glDisable(GL_RASTERIZER_DISCARD);

    // swap buffers
    std::swap(m_vbo[0], m_vbo[1]);
    m_particleShaderProgram.use();
    m_flameTexture.use(0);
    
    glUniformMatrix4fv(m_modelViewLocationParticle, 1, GL_FALSE, &modelView[0][0]);
    glUniformMatrix4fv(m_projectionLocationParticle, 1, GL_FALSE, &projPersp[0][0]);

    // buffer binding
    bindBuffer();

    // TODO: Draw particles without depth write and with blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    if (m_cumulativeTime > 1.0f / 60.0f)
    {
        m_cumulativeTime = 0.0f;
        if (++m_nParticles > m_nMaxParticles)
            m_nParticles = m_nMaxParticles;
    }

    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
}

void SceneParticles::updateInput(Window& w, double dt)
{        
    int x = 0, y = 0;
    if (m_isMouseMotionEnabled)
        w.getMouseMotion(x, y);
    const float MOUSE_SENSITIVITY = 0.1;
    float cameraMouvementX = y * MOUSE_SENSITIVITY;
    float cameraMouvementY = x * MOUSE_SENSITIVITY;
    
    const float KEYBOARD_MOUSE_SENSITIVITY = 1.5f;
    if (w.getKeyHold(Window::Key::UP))
        cameraMouvementX += KEYBOARD_MOUSE_SENSITIVITY;
    if (w.getKeyHold(Window::Key::DOWN))
        cameraMouvementX -= KEYBOARD_MOUSE_SENSITIVITY;
    if (w.getKeyHold(Window::Key::LEFT))
        cameraMouvementY += KEYBOARD_MOUSE_SENSITIVITY;
    if (w.getKeyHold(Window::Key::RIGHT))
        cameraMouvementY -= KEYBOARD_MOUSE_SENSITIVITY;
    
    m_cameraOrientation.y -= cameraMouvementY * dt;
    m_cameraOrientation.x -= cameraMouvementX * dt;
}

void SceneParticles::drawMenu()
{
    if (!m_menuVisible) return;

    ImGui::Begin("Scene Parameters");
    ImGui::End();
}

void SceneParticles::bindBuffer()
{
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo[0]);

    // Préciser où prendre les entrées du shader transform feedback
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, position)); // Position
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, velocity)); // Velocité        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, color)); // Couleur
    glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, size)); // Taille
    glVertexAttribPointer(4, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (void*)offsetof(Particle, timeToLive)); // Durée de vie

    // Préciser où mettre la sortie du shader transform feedback
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, m_vbo[1]);
}

void SceneParticles::initializeShader()
{
    // Particule shader
    {
        std::string vertexCode = readFile("shaders/particle.vs.glsl");
        std::string geometryCode = readFile("shaders/particle.gs.glsl");
        std::string fragmentCode = readFile("shaders/particle.fs.glsl");

        ShaderObject vertex("particule.vs.glsl", GL_VERTEX_SHADER, vertexCode.c_str());
        ShaderObject geometry("particule.gs.glsl", GL_GEOMETRY_SHADER, geometryCode.c_str());
        ShaderObject fragment("particule.fs.glsl",GL_FRAGMENT_SHADER, fragmentCode.c_str());
        m_particleShaderProgram.attachShaderObject(vertex);
        m_particleShaderProgram.attachShaderObject(geometry);
        m_particleShaderProgram.attachShaderObject(fragment);
        m_particleShaderProgram.link();

        m_modelViewLocationParticle = m_particleShaderProgram.getUniformLoc("modelView");
        m_projectionLocationParticle = m_particleShaderProgram.getUniformLoc("projection");
    }
    
    // Transform feedback shader
    {
        std::string vertexCode = readFile("shaders/transformFeedback.vs.glsl");

        ShaderObject vertex("transformFeedback.vs.glsl", GL_VERTEX_SHADER, vertexCode.c_str());
        m_transformFeedbackShaderProgram.attachShaderObject(vertex);

        // TODO
        const char* varyings[] = {"positionMod", "velocityMod", "colorMod", "sizeMod", "timeToLiveMod"};
        m_transformFeedbackShaderProgram.setTransformFeedbackVaryings(varyings, 5, GL_INTERLEAVED_ATTRIBS);
        
        m_transformFeedbackShaderProgram.link();

        m_timeLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("time");
        m_dtLocationTransformFeedback = m_transformFeedbackShaderProgram.getUniformLoc("dt");
    }
}

void SceneParticles::initializeTexture()
{
    m_flameTexture.setFiltering(GL_LINEAR);
    m_flameTexture.setWrap(GL_CLAMP_TO_EDGE);
}

