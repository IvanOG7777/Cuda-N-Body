//
// Created by elder on 7/31/2026.
//

#include <iostream>
#include <cassert>
#include <cstdio>

constexpr int N_PARTICLES = 100;
constexpr int TPB = 64;
constexpr int BLOCKS = (N_PARTICLES + TPB - 1) / TPB;
constexpr float DT = 0.016f;
constexpr float MAX_TIME = 10.0f;
constexpr float G = 1.0f;
constexpr float SOFTENING = 0.01f;

// operator overloaders
__host__ __device__ inline float3 operator+(const float3 &valA, const float3 &valB) {
    return {valA.x + valB.x, valA.y + valB.y, valA.z + valB.z};
}

__host__ __device__ inline float3 operator*(const float3 &val, const float scalar) {
    return {val.x * scalar, val.y * scalar, val.z * scalar};
}
////

// device function to calculate AB displacement
__device__ float3 kernelDisplacement(const float3 &particleA, const float3 &particleB) {
    return {particleB.x - particleA.x, particleB.y - particleA.y, particleB.z - particleA.z};
}

// device function to calculate AB distance squared
__device__ float kernelDistanceSquaredAB(const float3 &particleA, const float3 &particleB) {
    float3 displacement = kernelDisplacement(particleA, particleB);
    return displacement.x * displacement.x + displacement.y * displacement.y + displacement.z * displacement.z;
}

// device function to calculate AB distance
__device__ float kernelDistanceAB(const float3 &particleA, const float3 &particleB) {
    float distanceSquared = kernelDistanceSquaredAB(particleA, particleB);
    return sqrtf(distanceSquared);
}

// device function to calculate AB directional vector
__device__ float3 kernelDirectionAB(const float3 &particleA, const float3 &particleB) {
    float3 displacement = kernelDisplacement(particleA, particleB);

    float length = kernelDistanceAB(particleA, particleB);

    if (length == 0.0f) {
        return {0.0f, 0.0f, 0.0f};
    }

    float3 direction = {displacement.x / length, displacement.y / length, displacement.z / length};

    return direction;
}

__device__ float3 kernelAcceleration(const float3 &particleA, const float3 &particleB, const float &massB) {
    float3 direction = kernelDirectionAB(particleA, particleB);
    float distanceSquared = kernelDistanceSquaredAB(particleA, particleB);

    float accelerationMagnitude = (G * massB) / (distanceSquared + (SOFTENING * SOFTENING));

    float3 acceleration = {direction.x * accelerationMagnitude,direction.y * accelerationMagnitude,direction.z * accelerationMagnitude};

    return acceleration;
}

// Euler semi implicit velocity update function
__device__ float3 kernelVelocity(float3 *velocity, float3 *acceleration, float dt) {
    float3 newVelocity = {};

    newVelocity = *velocity + *acceleration * dt;

    return newVelocity;
}

// Euler semi implicit position update function
__device__ float3 kernelPosition(float3 *position, float3 *velocity, float dt) {
    float3 newPosition = {};

    newPosition = *position + *velocity * dt;

    return newPosition;
}

// kernel function to calculate total acceleration from one on all others
__global__ void kernelTotalAcceleration(float3 *accelerations, const float3 *positions, const float *masses) {
    unsigned int globalIndex = blockIdx.x * blockDim.x + threadIdx.x;

    if (globalIndex >= N_PARTICLES) return;

    float3 summedAcceleration = {0,0,0};

    for (int i = 0; i < N_PARTICLES; i++) {
        if (i == globalIndex) continue;

        float3 currentAcceleration = kernelAcceleration(positions[globalIndex], positions[i], masses[i]);

        summedAcceleration.x += currentAcceleration.x;
        summedAcceleration.y += currentAcceleration.y;
        summedAcceleration.z += currentAcceleration.z;
    }

    accelerations[globalIndex] = summedAcceleration;
}

// Kernel function to update positions and velocities
__global__ void kernelUpdateValues(float3 *positions, float3 *velocities, float3 *accelerations, float dt) {
    unsigned int globalIndex = blockIdx.x * blockDim.x + threadIdx.x;

    if (globalIndex >= N_PARTICLES) return;

    float3 newVelocity = {};
    float3 newPosition = {};

    newVelocity = kernelVelocity(&velocities[globalIndex], &accelerations[globalIndex], dt);
    newPosition = kernelPosition(&positions[globalIndex], &newVelocity, dt);

    velocities[globalIndex] = newVelocity;
    positions[globalIndex] = newPosition;
}

int main() {

    // Allocation host pointers
    float3 *positions = static_cast<float3 *>(malloc(N_PARTICLES * sizeof(float3)));
    float3 *velocities = static_cast<float3 *>(malloc(N_PARTICLES * sizeof(float3)));
    float3 *accelerations = static_cast<float3 *>(malloc(N_PARTICLES * sizeof(float3)));
    float *masses = static_cast<float *> (malloc(N_PARTICLES * sizeof(float)));

    float3 *devicePositions = nullptr;
    float3 *deviceAccelerations = nullptr;
    float3 *deviceVelocities = nullptr;
    float *deviceMasses = nullptr;

    assert(positions != nullptr);
    assert(velocities != nullptr);
    assert(accelerations != nullptr);
    assert(masses != nullptr);

    //// init values "randomly"
    for (int i = 0; i < N_PARTICLES; i++) {
        positions[i].x = rand() % (10 + 1 - 1) + 1;
        positions[i].y = rand() % (11 + 2 - 1) + 2;
        positions[i].z = rand() % (12 + 3 - 1) + 3;
    }

    for (int i = 0; i < N_PARTICLES; i++) {
        velocities[i].x = 0;
        velocities[i].y = 0;
        velocities[i].z = 0;
    }

    for (int i = 0; i < N_PARTICLES; i++) {
        masses[i] = rand() % (13 + 1 - 1) + 1;
    }
    //////


    // Allocating device pointers and copying host to device
    cudaMalloc(&devicePositions, N_PARTICLES * sizeof(float3));
    cudaMalloc(&deviceVelocities, N_PARTICLES * sizeof(float3));
    cudaMalloc(&deviceAccelerations, N_PARTICLES * sizeof(float3));
    cudaMalloc(&deviceMasses, N_PARTICLES * sizeof(float));

    cudaMemcpy(devicePositions, positions, N_PARTICLES * sizeof(float3), cudaMemcpyHostToDevice);
    cudaMemcpy(deviceVelocities, velocities, N_PARTICLES * sizeof(float3), cudaMemcpyHostToDevice);
    cudaMemcpy(deviceMasses, masses, N_PARTICLES * sizeof(float), cudaMemcpyHostToDevice);

    assert(devicePositions != nullptr);
    assert(deviceVelocities != nullptr);
    assert(deviceAccelerations != nullptr);
    assert(deviceMasses != nullptr);
    //////

    float currentTime = 0.0f;

    while (currentTime < MAX_TIME) {
        std:: cout << "Current time: " << currentTime << std:: endl;

        kernelTotalAcceleration<<<BLOCKS, TPB>>>(deviceAccelerations, devicePositions, deviceMasses);
        cudaDeviceSynchronize();
        kernelUpdateValues<<<BLOCKS, TPB>>>(devicePositions, deviceVelocities, deviceAccelerations, DT);
        cudaDeviceSynchronize();

        currentTime += DT;
    }
    std:: cout << std:: endl;

    // Copy data back host from device
    cudaMemcpy(positions, devicePositions, N_PARTICLES * sizeof(float3), cudaMemcpyDeviceToHost);
    cudaMemcpy(velocities, deviceVelocities, N_PARTICLES * sizeof(float3), cudaMemcpyDeviceToHost);
    cudaMemcpy(accelerations, deviceAccelerations, N_PARTICLES * sizeof(float3), cudaMemcpyDeviceToHost);

    std:: cout << "Final values" << std:: endl;

    for (int i = 0; i < N_PARTICLES; i++) {
        printf("Position: (%.2f, %.2f, %.2f)\n", positions[i].x, positions[i].y, positions[i].z);
    }
    std:: cout << std:: endl;

    for (int i = 0; i < N_PARTICLES; i++) {
        printf("Velocities: (%.2f, %.2f, %.2f)\n", velocities[i].x, velocities[i].y, velocities[i].z);
    }
    std:: cout << std:: endl;

    for (int i = 0; i < N_PARTICLES; i++) {
        printf("Accelerations: (%.2f, %.2f, %.2f)\n", accelerations[i].x, accelerations[i].y, accelerations[i].z);
    }


    // Freeing memory
    cudaFree(devicePositions);
    cudaFree(deviceVelocities);
    cudaFree(deviceAccelerations);
    cudaFree(deviceMasses);

    free(positions);
    free(velocities);
    free(accelerations);
    free(masses);
}