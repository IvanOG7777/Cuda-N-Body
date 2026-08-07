//
// Created by elder on 8/6/2026.
//
#include <iostream>
#include <cassert>
#include "Tiled-N-Body-Header.h"

constexpr int N_PARTICLES = 100;
constexpr int TPB = 64;
constexpr int BLOCKS = (N_PARTICLES + TPB - 1) / TPB;
constexpr float DT = 0.016f;
constexpr float MAX_TIME = 10.0f;
constexpr float G = 1.0f;
constexpr float SOFTENING = 0.01f;


int main() {

    Particle *particles = static_cast<Particle *>(malloc(N_PARTICLES * sizeof(Particle)));
    assert(particles != nullptr);

    // load particles here

    Particle *deviceParticles = nullptr;
    cudaMalloc(&deviceParticles, N_PARTICLES * sizeof(Particle));

    cudaMemcpy(deviceParticles, particles, N_PARTICLES * sizeof(Particle), cudaMemcpyHostToDevice);


}