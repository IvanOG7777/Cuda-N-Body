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
        Naive-N-Body.cu
)

add_executable(Tiled-N-Body
        Tiled-N-Body.cu
        Tiled-N-Body-Header.h
        DeviceFunctions.cu
)