//
// Created by elder on 8/6/2026.
//

#include <math_functions.h>
#include "Tiled-N-Body-Header.h"

__device__ float3 kernelDisplacementAB(const Particle &particleA, const Particle &particleB) {
    return particleB.position - particleA.position;
}

__device__ float kernelDistanceAB(const Particle &particleA, const Particle &particleB) {
    float3 displacement = kernelDisplacementAB(particleA, particleB);
    return sqrtf(displacement.x * displacement.x + displacement.y * displacement.y + displacement.z * displacement.z);
}

__device__ float kernelDistanceSquaredAB(Particle &particleA, Particle &particleB) {
    float3 displacement = kernelDisplacementAB(particleA, particleB);

    return displacement.x * displacement.x + displacement.y * displacement.y + displacement.z * displacement.z;
}

__device__ float3 kernelDirectionVectorNormalAB(Particle &particleA, Particle &particleB) {
    float3 displacement = kernelDisplacementAB(particleA, particleB);

    float length = kernelDistanceAB(particleA, particleB);

    if (length == 0.0f) return {};

    return displacement/length;
}

__global__ void kernelUpdateParticles(Particle *particles, float dt) {
    unsigned int globalIndex = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int localThreadIndex = threadIdx.x;

    __shared__ Particle sharedParticles[TPB];

    if (globalIndex < N_PARTICLES) {
        sharedParticles[localThreadIndex] = particles[globalIndex];
    } else {
        sharedParticles[localThreadIndex] = SENTINEL_PARTICLE;
    }
    __syncthreads();


}