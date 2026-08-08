//
// Created by elder on 8/6/2026.
//

#include <curand_kernel.h>
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

__device__ float3 kernelAcceleration(const Particle &particleA, const Particle &particleB, const float &massB) {
    float3 direction = kernelDirectionAB(particleA, particleB);
    float distanceSquared = kernelDistanceSquaredAB(particleA, particleB);

    float accelerationMagnitude = (G * massB) / (distanceSquared + (SOFTENING * SOFTENING));

    float3 acceleration = {direction.x * accelerationMagnitude,direction.y * accelerationMagnitude,direction.z * accelerationMagnitude};

    return acceleration;
}

__global__ void kernelUpdateParticles(Particle *particles, float dt) {
    unsigned int globalIndex = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int localThreadIndex = threadIdx.x;

    __shared__ Particle sharedParticles[TPB];

    // loads each block with a shared TPB size array
    if (globalIndex < N_PARTICLES) {
        sharedParticles[localThreadIndex] = particles[globalIndex];
    } else {
        sharedParticles[localThreadIndex] = SENTINEL_PARTICLE;
    }
    __syncthreads();

    if (sharedParticles[localThreadIndex].mass != 0.0f) {
        float3 newPosition = {};
        float3 newVelocity = {};
        float3 summedAcceleration = {};

        newPosition = sharedParticles->position + sharedParticles->velocity * dt;
        newVelocity = sharedParticles->velocity + sharedParticles->acceleration *dt;

        // Total acceleration sum
        for (int i = 0; i < TPB; i++) {
            if (i == localThreadIndex) continue;

            float3 currentAcceleration = kernelAcceleration(sharedParticles[localThreadIndex], sharedParticles[i], sharedParticles[i].mass);

            summedAcceleration.x += currentAcceleration.x;
            summedAcceleration.y += currentAcceleration.y;
            summedAcceleration.z += currentAcceleration.z;
        }

        // place new values to current particle at local thread
        sharedParticles[localThreadIndex].position = newPosition;
        sharedParticles[localThreadIndex].velocity = newVelocity;
        sharedParticles[localThreadIndex].acceleration = summedAcceleration;
    } else return;

    if (globalIndex < N_PARTICLES) {
        particles[globalIndex] = sharedParticles[localThreadIndex];
    }
}

// pass in empty states array pointer and a seed
__device__ void initState(curandState *states, const unsigned int seed) {
    int globalIndex = blockIdx.x * blockDim.x + threadIdx.x; // get threads global index

    // creates "infinite" sequence of floats for current thread
    curand_init(seed, globalIndex, 0, &states[globalIndex]);
}

// pass curandState that allows per thread randomness
__device__ float3 randFloat3(curandState *state) {
    float3 rand;

    // pulls a single floating number from the generated states sequence of numbers.
    rand.x = curand_uniform(state);
    rand.y = curand_uniform(state);
    rand.z = curand_uniform(state);

    return rand;
}

__global__ void loadParticles(Particle *particles, curandState *states, const unsigned int seed) {
    unsigned int globalIndex = blockIdx.x * blockDim.x + threadIdx.x;

    if (globalIndex >= N_PARTICLES) return;

    // init state per thread
    initState(states, seed);

    float3 position{};
    float3 velocity{};
    float3 acceleration{};

    position = randFloat3(&states[globalIndex]);
    velocity = randFloat3(&states[globalIndex]);
    acceleration = randFloat3(&states[globalIndex]);

    particles[globalIndex].position = position;
    particles[globalIndex].velocity = velocity;
    particles[globalIndex].acceleration = acceleration;
}