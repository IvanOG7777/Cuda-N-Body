//
// Created by elder on 8/6/2026.
//

#ifndef CUDAPRACTICE_TILED_N_BODY_HEADER_H
#define CUDAPRACTICE_TILED_N_BODY_HEADER_H

struct Particle {
    float mass;
    float3 position{};
    float3 velocity{};
    float3 acceleration{};

    Particle() : mass(0.0f){}
};

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

__device__ float kernelDisplacementAB(Particle &particleA, Particle &particleB);
__device__ float kernelDistanceAB(Particle &particleA, Particle &particleB);
__device__ float kernelDirectionAB(Particle &particleA, Particle &particleB);

__device__ kernelAcceleration()


#endif //CUDAPRACTICE_TILED_N_BODY_HEADER_H