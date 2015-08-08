//
//  GameScene.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKSpriteNode *desk;

@end

@implementation GameScene

#pragma mark - Properties Overload

- (SKSpriteNode *)ball
{
    if (!_ball){
        _ball = (SKSpriteNode *)[self childNodeWithName:@"ball"];
        NSParameterAssert(_ball);
        _ball.physicsBody.friction       = 0;
        _ball.physicsBody.restitution    = 1;
        _ball.physicsBody.linearDamping  = 0;
        _ball.physicsBody.angularDamping = 0;
        _ball.physicsBody.allowsRotation = NO;
    }
    return _ball;
}

- (SKSpriteNode *)desk
{
    if (!_desk){
        _desk = (SKSpriteNode *)[self childNodeWithName:@"desk"];
        NSParameterAssert(_desk);
        _desk.physicsBody.friction       = 0;
        _desk.physicsBody.restitution    = 1;
        _desk.physicsBody.linearDamping  = 0;
        _desk.physicsBody.angularDamping = 0;
        _desk.physicsBody.allowsRotation = NO;
        
        _desk.physicsBody.dynamic        = NO;
        NSParameterAssert(_desk);
    }
    return _desk;
}

- (void)didMoveToView:(SKView *)view {
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.friction       = 0;
    self.physicsBody      = border;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    [self.ball.physicsBody applyImpulse:CGVectorMake(15, -10)];
    self.desk.color = [UIColor purpleColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    
}

-(void)update:(CFTimeInterval)currentTime {
    
}

@end
