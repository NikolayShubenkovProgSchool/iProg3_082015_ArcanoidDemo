//
//  GameScene.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "GameScene.h"

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKSpriteNode *desk;
@property (nonatomic) BOOL isTouchingDesk;
@property (nonatomic, strong) SKNode *bottomLine;

@end

typedef NS_OPTIONS(uint32_t, PhysicsCategory) {
    PhysicsCategoryBall       = 1,
    PhysicsCategoryBottomLine = 1 << 1,
    PhysicsCategoryBrick      = 1 << 2,
    PhysicsCategoryDesk       = 1 << 3
};

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
        _ball.physicsBody.categoryBitMask = PhysicsCategoryBall;
        _ball.physicsBody.contactTestBitMask = PhysicsCategoryBottomLine;
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
        _desk.physicsBody.categoryBitMask = PhysicsCategoryDesk;
        NSParameterAssert(_desk);
    }
    return _desk;
}

- (SKNode *)bottomLine
{
    if (!_bottomLine){
        _bottomLine = [SKNode new];
        // полоска внизу сцены
        CGRect bodyRect = CGRectMake(self.frame.origin.x,
                                     self.frame.origin.y,
                                     CGRectGetWidth(self.frame),
                                     1);
        //создадим тело, которое будет касаться мяча
        _bottomLine.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyRect];
        _bottomLine.physicsBody.categoryBitMask = PhysicsCategoryBottomLine;
    }
    return _bottomLine;
}

- (void)didMoveToView:(SKView *)view {
    SKPhysicsBody *border = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.friction       = 0;
    self.physicsBody      = border;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    [self.ball.physicsBody applyImpulse:CGVectorMake(15, -10)];
    self.desk.color = [UIColor purpleColor];
    [self addChild:self.bottomLine];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [[touches anyObject] locationInNode:self];
    
    //найдем все ноды в точке касания
    NSArray *nodes = [self nodesAtPoint:touchLocation];
    
    //если среди нодов, которых коснулись есть доска
    self.isTouchingDesk = [nodes containsObject:self.desk];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isTouchingDesk){
        return;
    }
    UITouch *aTouch = [touches anyObject];
    //Считаем текущую и предыдущую точки касания
    CGPoint currentPoint = [aTouch locationInNode:self];
    CGPoint prevPoint    = [aTouch previousLocationInNode:self];
    
    //В соответствии с ними переместрим доску
    
    CGFloat delta = currentPoint.x - prevPoint.x;
    CGFloat newX = self.desk.position.x + delta;
    
    CGPoint newPosition = CGPointMake(newX, self.desk.position.y);
    
    CGFloat deskWidth = CGRectGetWidth(self.desk.frame);
    if (newPosition.x < deskWidth / 2){
        newPosition.x = deskWidth / 2;
    }
    
    if (newPosition.x > CGRectGetWidth(self.frame) - deskWidth / 2){
        newPosition.x = CGRectGetWidth(self.frame) - deskWidth / 2;
    }
    
    self.desk.position = newPosition;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)update:(CFTimeInterval)currentTime {
    
}

#pragma mark - PhysycsWorld Delegate

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody = contact.bodyA;
    SKPhysicsBody *secondBody = contact.bodyB;
    
    if (firstBody.categoryBitMask > secondBody.categoryBitMask){
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == PhysicsCategoryBall &&
        secondBody.categoryBitMask == PhysicsCategoryBottomLine){
        NSLog(@"Game Over") ;
    }
    
    
}

@end
