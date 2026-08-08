//
// Created by elder on 8/6/2026.
//
#include <iostream>
#include <cassert>
#include "Tiled-N-Body-Header.h"

int main() {
    // load particles here

    Particle *deviceParticles = nullptr;
    cudaMalloc(&deviceParticles, N_PARTICLES * sizeof(Particle));


}