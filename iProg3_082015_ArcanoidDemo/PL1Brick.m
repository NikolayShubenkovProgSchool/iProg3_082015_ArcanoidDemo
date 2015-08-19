//
//  PL1Brick.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "PL1Brick.h"
#import "Constants.h"

@implementation PL1Brick

+ (instancetype)brickAtPoint:(CGPoint)point
{
    PL1Brick *brick = [self spriteNodeWithImageNamed:@"brick"];
    
    SKPhysicsBody *body = [SKPhysicsBody bodyWithEdgeLoopFromRect:brick.frame];
    brick.physicsBody = body;
    brick.physicsBody.categoryBitMask = PhysicsCategoryBrick;
    brick.physicsBody.dynamic = 0;
    brick.physicsBody.friction       = 0;
    brick.physicsBody.restitution    = 1;
    brick.physicsBody.linearDamping  = 0;
    brick.physicsBody.angularDamping = 0;
    brick.physicsBody.allowsRotation = NO;
    brick.physicsBody.affectedByGravity = NO;
    brick.position = point;
    
    return brick;
}

@end
