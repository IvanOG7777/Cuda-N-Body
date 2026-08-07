//
// Created by elder on 8/6/2026.
//

#ifndef CUDAPRACTICE_TILED_N_BODY_HEADER_H
#define CUDAPRACTICE_TILED_N_BODY_HEADER_H

constexpr int N_PARTICLES = 100;
constexpr int TPB = 64;
constexpr int BLOCKS = (N_PARTICLES + TPB - 1) / TPB;
constexpr  int STRIDE = (TPB + 2 - 1) / 2;
constexpr float DT = 0.016f;
constexpr float MAX_TIME = 10.0f;
constexpr float G = 1.0f;
constexpr float SOFTENING = 0.01f;

struct Particle {
    float mass;
    float3 position{};
    float3 velocity{};
    float3 acceleration{};

    Particle() : mass(0.0f){}
};

const Particle SENTINEL_PARTICLE;

inline __host__ __device__ float3 operator-(const float3 &a, const float3 &b) {
    return {a.x - b.x, a.y - b.y, a.z - b.z};
}

inline __host__ __device__ float3 operator+(const float3 &a, const float3 &b) {
    return {a.x + b.x, a.y + b.y, a.z + b.z};
}

inline __host__ __device__ float3 operator*(const float3 &a, const float3 &b) {
    return {a.x * b.x, a.y * b.y, a.z * b.z};
}

inline __host__ __device__ float3 operator*(const float3 &a, const float scalar) {
    return {a.x * scalar, a.y * scalar, a.z * scalar};
}

inline __host__ __device__ float3 operator*(const float scalar, const float3 &a) {
    return a * scalar;
}

inline __host__ __device__ float3 operator/(const float3 &a, const float scalar) {
    return {a.x / scalar, a.y / scalar, a.z / scalar};
}

inline __host__ __device__ float3 operator/(const float scalar, const float3 &a) {
    return a / scalar;
}

__device__ float3 kernelDisplacementAB(Particle &particleA, Particle &particleB);
__device__ float kernelDistanceAB(Particle &particleA, Particle &particleB);
__device__ float kernelDistanceSquaredAB(Particle &particleA, Particle &particleB);
__device__ float3 kernelDirectionAB(Particle &particleA, Particle &particleB);

__global__ void kernelUpdateParticles(Particle *particles, float dt);



#endif //CUDAPRACTICE_TILED_N_BODY_HEADER_H