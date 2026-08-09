//
// Created by elder on 8/9/2026.
//

#include "../Header/Camera.h"


Camera::Camera() {
    yaw = 0.0f;
    pitch = 0.0f;
    speed = 10.0f;
    firstMove = true;
    position = {0.0f, 0.0f, 0.0f};
    worldUp = {0.0f, 1.0f, 0.0f};
}

glm::vec3 Camera::getDirection() const {
    float x = std::cosf(pitch) * std:: sinf(yaw);
    float y = std::sinf(pitch);
    float z = -std::cosf(pitch) * std:: cosf(yaw);

    glm::vec3 direction(x, y, z);

    direction = glm::normalize(direction);

    return direction;
}

glm::vec3 Camera::getRight() const {
    glm::vec3 direction = getDirection();
    glm::vec3 right = glm::cross(direction, worldUp);

    right = glm::normalize(right);

    return right;
}

glm::mat4 Camera::getViewMatrix() const {
    auto direction = getDirection();
    auto target = position + direction;
    glm::mat4 resultingMatrix = glm::lookAt(position, target, worldUp);

    return resultingMatrix;
}

void Camera::setPosition(const glm::vec3 &passedPosition) {
    position = passedPosition;
}

void Camera::setPosition(float x, float y, float z) {
    position.x = x;
    position.y = y;
    position.z = z;
}

void Camera::setYaw(float passedYaw) {
    yaw = passedYaw;
}

void Camera::setPitch(float passedPitch) {
    pitch = passedPitch;
}


float &Camera::getYaw() {
    return yaw;
}

float &Camera::getPitch() {
    return pitch;
}

glm::vec3 &Camera::getPosition() {
    return position;
}
