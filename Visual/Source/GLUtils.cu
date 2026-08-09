//
// Created by elder on 8/8/2026.
//

#include "../Header/GLUtils.h"
#include "../../Tiled/Tiled-N-Body-Header.h"

GLFWwindow *createWindow(const int w, const int h, const char *title) {
    if (w == 0 || h == 0) {
        std::cerr << "WINDOW WIDTH OR HEIGHTs IS 0" << std::endl;
        exit(EXIT_FAILURE);
    }

    GLFWwindow *window = glfwCreateWindow(w, h, title, nullptr, nullptr);

    if (window == nullptr) {
        std::cerr << "WINDOW IS NULLPTR" << std::endl;
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    std:: cout << "Created window successfully" << std:: endl;
    return window;
}

const char *createVertexShader(const std::string type) {
    if (type == "glPoints") {
        return R"GLSL(
            #version 330 core

            layout (location = 0) in vec3 aPos;
            layout (location = 1) in vec3 aVel;

            uniform mat4 uMVP;
            out vec3 vertexColor;

            void main() {
                gl_Position = uMVP * vec4(aPos, 1.0);
                gl_PointSize = 2.0;

                float speed = length(aVel);
                float t = clamp(speed / 10.0, 0.0, 1.0);

                vertexColor = mix(vec3(0.1, 0.3, 1.0), vec3(1.0, 0.15, 0.1), t);
            }
        )GLSL";
    }
    return nullptr;
}

const char *createFragmentShader(const std::string type) {
    if (type == "glPoints") {
        return R"GLSL(
            #version 330 core

            in vec3 vertexColor;
            out vec4 FragColor;

            void main() {
                FragColor = vec4(vertexColor, 1.0);
            }
        )GLSL";
    }
    return nullptr;
}

void setVAO(GLuint &VAO, GLuint &VBO, GLenum drawHint) {
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);


    // let cuda pass in data only allocate space within VAO and VBO
    glBufferData(GL_ARRAY_BUFFER, N_PARTICLES * sizeof(Particle), nullptr, drawHint);

    // location 0 within vertex for particle position
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), reinterpret_cast<void*>(offsetof(Particle, position))); // skip offset to positons
    glEnableVertexAttribArray(0);

    //location 1 within vertex for particle velocity
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), reinterpret_cast<void*>(offsetof(Particle, velocity))); // skip offset to velocity
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

GLuint compileShader(const char *shader, GLenum shaderType) {
    GLuint s = glCreateShader(shaderType);
    glShaderSource(s, 1, &shader, nullptr);
    glCompileShader(s);

    return s;
}


