//
// Created by elder on 8/8/2026.
//

#include "../Header/GLUtils.h"

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
