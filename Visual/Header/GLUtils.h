//
// Created by elder on 8/8/2026.
//

#ifndef CUDAPRACTICE_GLUTILS_H
#define CUDAPRACTICE_GLUTILS_H

#include <iostream>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

GLFWwindow *createWindow(int w, int h, const char *title);

const char *createVertexShader(const std::string type);

const char *createFragmentShader(const std::string type);

void setVAO(GLuint &VAO, GLuint &VBO, GLenum drawHint);

GLuint compileShader(const char *shader, GLenum shaderType);


#endif //CUDAPRACTICE_GLUTILS_H