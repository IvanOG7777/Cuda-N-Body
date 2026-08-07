//
// Created by elder on 8/6/2026.
//

#include <math_functions.h>
#include "Tiled-N-Body-Header.h"

__device__ float kernelDistanceAB(const Particle &particleA, const Particle &particleB) {
    float3 positionA = particleA.position;
    float3 positionB = particleB.position;
    return sqrtf(positionA - positionB);
}

__device