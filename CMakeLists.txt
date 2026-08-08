cmake_minimum_required(VERSION 3.28)
project(CudaPractice LANGUAGES C CXX CUDA)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_ARCHITECTURES 86)


add_executable(Naive-N-Body
        Naive/Naive-N-Body.cu
)

add_executable(Tiled-N-Body
        Tiled/Tiled-N-Body.cu
        Tiled/Tiled-N-Body-Header.h
        Tiled/DeviceFunctions.cu
)

add_executable(Visual-N-Body
        Visual/Source/Visual-N-Body.cu
        Visual/Header/Visual-N-Body-Header.h
        Visual/Source/DeviceFunctions.cu
        Visual/Source/glad.c
        Visual/Header/GLUtils.h
        Visual/Source/GLUtils.cpp
)

target_include_directories(Visual-N-Body PRIVATE
        ${CMAKE_SOURCE_DIR}/Visual/Libraries/include
)

target_link_libraries(Visual-N-Body PRIVATE
        ${CMAKE_SOURCE_DIR}/Visual/Libraries/lib/glfw3.lib
        opengl32
)