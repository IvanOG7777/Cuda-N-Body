//
// Created by elder on 8/6/2026.
//
#include <iostream>
#include <cassert>
#include "Tiled-N-Body-Header.h"


int main() {

    Particle *particles = static_cast<Particle *>(malloc(N_PARTICLES * sizeof(Particle)));
    assert(particles != nullptr);

    // load particles here

    Particle *deviceParticles = nullptr;
    cudaMalloc(&deviceParticles, N_PARTICLES * sizeof(Particle));

    cudaMemcpy(deviceParticles, particles, N_PARTICLES * sizeof(Particle), cudaMemcpyHostToDevice);


}