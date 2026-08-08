//
// Created by elder on 8/6/2026.
//

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include "../Header/Tiled-N-Body-Header.h"

int main() {

    Particle *deviceParticles = nullptr;
    curandState *deviceStates = nullptr;

    cudaMalloc(&deviceParticles, N_PARTICLES * sizeof(Particle));
    cudaMalloc(&deviceStates, N_PARTICLES * sizeof(curandState));

    loadParticles<<<BLOCKS, TPB>>>(deviceParticles, deviceStates, 1234ULL);
    cudaDeviceSynchronize();

    Particle *hostParticles = static_cast<Particle *>(malloc(N_PARTICLES * sizeof(Particle)));

    // copies data right after particles init
    cudaMemcpy(hostParticles, deviceParticles, N_PARTICLES * sizeof(Particle), cudaMemcpyDeviceToHost);

    std:: cout << "Values before updating" << std:: endl;
    for (int i = 0; i < 20; i++) {
        printf("Position (%.2f, %.2f, %.2f)\n", hostParticles[i].position.x, hostParticles[i].position.y, hostParticles[i].position.z);
        printf("Velocity (%.2f, %.2f, %.2f)\n", hostParticles[i].velocity.x, hostParticles[i].velocity.y, hostParticles[i].velocity.z);
        printf("Acceleration (%.2f, %.2f, %.2f)\n", hostParticles[i].acceleration.x, hostParticles[i].acceleration.y, hostParticles[i].acceleration.z);
        printf("Mass: %.2f\n", hostParticles[i].mass);
        printf("\n");
    }

    printf("\n");
    printf("\n");

    float currentTime = 0.0f;
    while (currentTime <= MAX_TIME) {
        kernelUpdateParticles<<<BLOCKS, TPB>>>(deviceParticles, DT);
        cudaDeviceSynchronize();

        currentTime += DT;
    }

    cudaMemcpy(hostParticles, deviceParticles, N_PARTICLES * sizeof(Particle), cudaMemcpyDeviceToHost);

    std:: cout << "Values after updating" << std:: endl;
    for (int i = 0; i < 20; i++) {
        printf("Position (%.2f, %.2f, %.2f)\n", hostParticles[i].position.x, hostParticles[i].position.y, hostParticles[i].position.z);
        printf("Velocity (%.2f, %.2f, %.2f)\n", hostParticles[i].velocity.x, hostParticles[i].velocity.y, hostParticles[i].velocity.z);
        printf("Acceleration (%.2f, %.2f, %.2f)\n", hostParticles[i].acceleration.x, hostParticles[i].acceleration.y, hostParticles[i].acceleration.z);
        printf("\n");
    }

    cudaFree(deviceParticles);
    cudaFree(deviceStates);

    free(hostParticles);

    return 0;
}