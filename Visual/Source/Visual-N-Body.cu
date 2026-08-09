//
// Created by elder on 8/6/2026.
//

#include <iostream>

#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <glm/glm/glm.hpp>
#include <glm/glm/gtc/matrix_transform.hpp>
#include <glm/glm/gtc/type_ptr.hpp>

#include <cuda_gl_interop.h>

#include "../Header/GLUtils.h"
#include "../Header/Camera.h"
#include "../Header/Visual-N-Body-Header.h"

int main() {

    if (!glfwInit()) {
        std:: cerr << "Failed to load GLFW" << std:: endl;
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = createWindow(1920, 1080, "Visual-N-Body-Simulation");
    glfwMakeContextCurrent(window);
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cerr << "GLAD INIT ERROR\n";
        return -1;
    }

    Particle *deviceParticles = nullptr;
    curandState *deviceStates = nullptr;

    cudaMalloc(&deviceStates, N_PARTICLES * sizeof(curandState));

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

    GLint uMVP = glGetUniformLocation(program, "uMVP");

    float fov = glm::radians(45.0f);
    float aspect = 1920.0f/1080.0f;
    float near = 0.1;
    float far = 1000;

    Camera camera;
    camera.setPosition(5, 5, 15);
    glm::mat4 view;
    glm:: mat4 particleMVP;
    glm::mat4 perspectiveMatrix = glm::perspective(fov, aspect, near, far);

    cudaGraphicsResource *cudaRenderResource;


    // Tell cuda to use allocated VBO from opengl. It will write to it and not read
    // Do this once because its memory intensive
    cudaGraphicsGLRegisterBuffer(&cudaRenderResource, VBO, cudaGraphicsMapFlagsWriteDiscard);
    size_t bytes = 0;
    cudaGraphicsMapResources(1, &cudaRenderResource, nullptr); // give ownership to cuda
    cudaGraphicsResourceGetMappedPointer((void**)&deviceParticles, &bytes, cudaRenderResource); //map data
    kernelLoadParticles<<<BLOCKS, TPB>>>(deviceParticles, deviceStates, 1234ULL); // run kernel
    cudaGraphicsUnmapResources(1, &cudaRenderResource, nullptr); //return ownership back to openGL



    glEnable(GL_PROGRAM_POINT_SIZE);
    while (!glfwWindowShouldClose(window)) {
        glClear(GL_COLOR_BUFFER_BIT);

        size_t numBytes = 0;

        cudaGraphicsMapResources(1, &cudaRenderResource, nullptr);

        cudaGraphicsResourceGetMappedPointer((void**)&deviceParticles, &numBytes, cudaRenderResource);

        kernelUpdateParticles<<<BLOCKS, TPB>>>(deviceParticles, DT);
        cudaDeviceSynchronize();

        cudaGraphicsUnmapResources(1, &cudaRenderResource, nullptr);

        glUseProgram(program);

        view = camera.getViewMatrix();

        particleMVP = perspectiveMatrix * view * glm::mat4(1.0f);
        glUniformMatrix4fv(uMVP, 1, GL_FALSE, glm::value_ptr(particleMVP));

        glBindVertexArray(VAO);
        glDrawArrays(GL_POINTS, 0, N_PARTICLES);


        glfwPollEvents();
        glfwSwapBuffers(window);
    }

    cudaGraphicsUnregisterResource(cudaRenderResource);
    glfwDestroyWindow(window);
    glfwTerminate();

    cudaFree(deviceStates);

    return 0;
}
