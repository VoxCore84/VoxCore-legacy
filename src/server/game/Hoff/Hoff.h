/*
 * Copyright 2023 Hoff
 */

#ifndef HOFF_H
#define HOFF_H

#include "Common.h"
#include "Map.h"
#include "Player.h"
#include "Position.h"

enum EFollowAngle
{
    FOLLOW_ANGLE_FRONT,
    FOLLOW_ANGLE_FRONT_LEFT,
    FOLLOW_ANGLE_FRONT_RIGHT,
    FOLLOW_ANGLE_LEFT,
    FOLLOW_ANGLE_RIGHT,
    FOLLOW_ANGLE_BACK,
    FOLLOW_ANGLE_BACK_LEFT,
    FOLLOW_ANGLE_BACK_RIGHT
};

class TC_GAME_API Hoff
{
public:

    /**
    * Get a valid position for a follower/pet to walk on at the given angle
    * @param ParentUnit The original unit the follower is following
    * @param Angle The angle to follow at
    * @param Distance The distance to follow at
    * @return Position The target position
    */
    static Position GetTargetFollowPosition(Unit* ParentUnit, EFollowAngle Angle, float Distance);
};

#endif
