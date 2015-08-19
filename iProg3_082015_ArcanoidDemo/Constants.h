//
//  Contants.h
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#ifndef iProg3_082015_ArcanoidDemo_Contants_h
#define iProg3_082015_ArcanoidDemo_Contants_h

typedef NS_OPTIONS(uint32_t, PhysicsCategory) {
    PhysicsCategoryBall       = 1 << 0,
    PhysicsCategoryBottomLine = 1 << 1,
    PhysicsCategoryBrick      = 1 << 2,
    PhysicsCategoryDesk       = 1 << 3,
    PhysicsCategoryBonus      = 1 << 4
};

#endif
