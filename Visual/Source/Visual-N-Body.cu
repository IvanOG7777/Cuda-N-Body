//
// Created by elder on 8/6/2026.
//

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include "../Header/GLUtils.h"

int main() {

    if (!glfwInit()) {
        std:: cerr << "Failed to load GLFW" << std:: endl;
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = createWindow(1280, 800, "Visual-N-Body-Simulation");
    glfwMakeContextCurrent(window);
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cerr << "GLAD INIT ERROR\n";
        return -1;
    }

    Particle *deviceParticles = nullptr;
    curandState *deviceStates = nullptr;

    cudaMalloc(&deviceParticles, N_PARTICLES * sizeof(Particle));
    cudaMalloc(&deviceStates, N_PARTICLES * sizeof(curandState));

    // loads particles with data
    loadParticles<<<BLOCKS, TPB>>>(deviceParticles, deviceStates, 1234ULL);
    cudaDeviceSynchronize();

    Particle *hostParticles = static_cast<Particle *>(malloc(N_PARTICLES * sizeof(Particle)));

    GLuint VAO = 0, VBO = 0;

    setVAO(VAO, VBO, GL_DYNAMIC_DRAW);
    const char* vertexShader = createVertexShader("glPoints");
    const char* fragmentShader = createFragmentShader("glPoints");

    GLuint VS = compileShader(vertexShader, GL_VERTEX_SHADER);
    GLuint FS = compileShader(fragmentShader, GL_FRAGMENT_SHADER);

    GLuint program = glCreateProgram();
    glAttachShader(program, VS);
    glAttachShader(program, FS);
    glLinkProgram(program);

    glDeleteShader(VS);
    glDeleteShader(FS);

    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);


        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();




    cudaFree(deviceParticles);
    cudaFree(deviceStates);

    free(hostParticles);

    return 0;
}