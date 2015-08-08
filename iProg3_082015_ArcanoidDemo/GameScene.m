//
//  GameScene.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.friction       = 0;
    self.physicsBody      = border;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    SKSpriteNode *ball = (SKSpriteNode *)[self childNodeWithName:@"ball"];
    NSParameterAssert(ball);
    ball.physicsBody.friction       = 0;
    ball.physicsBody.restitution    = 1;
    ball.physicsBody.linearDamping  = 0;
    ball.physicsBody.angularDamping = 0;
    ball.physicsBody.allowsRotation = NO;

    
    [ball.physicsBody applyImpulse:CGVectorMake(15, -10)];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
}

-(void)update:(CFTimeInterval)currentTime {
    
}

@end
