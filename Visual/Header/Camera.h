//
// Created by elder on 8/9/2026.
//

#ifndef VISUAL_N_BODY_CAMERA_H
#define VISUAL_N_BODY_CAMERA_H

#include <glm/glm/glm.hpp>
#include "glm/glm/gtc/matrix_transform.hpp"

class Camera {
public:
    float yaw;
    float pitch;
    float speed;
    bool firstMove;
    float currentX;
    float currentY;
    float currentZ;
private:
    glm::vec3 position;
    glm::vec3 worldUp;

public:

    Camera();

    glm::vec3 getDirection() const;

    glm::vec3 getRight() const;

    glm::mat4 getViewMatrix() const;

    void setPosition(const glm::vec3 &passedPosition);
    void setPosition(float x, float y, float z);
    glm::vec3 &getPosition();

    void setYaw(float passedYaw);
    float &getYaw();

    void setPitch(float passedPitch);
    float &getPitch();
};

#endif //VISUAL_N_BODY_CAMERA_H