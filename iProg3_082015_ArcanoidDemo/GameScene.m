//
//  GameScene.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "GameScene.h"

#import "Contants.h"
#import "PL1Brick.h"

static const CGFloat kMnAllowedXYSpeed = 20;
//в слчае когда мяч возле самой стены
static const CGFloat kSeedToSetForBallNearWall = 80;

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKSpriteNode *desk;
@property (nonatomic) BOOL isTouchingDesk;
@property (nonatomic, strong) SKNode *bottomLine;
@property (nonatomic) NSInteger score;

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
        _ball.physicsBody.categoryBitMask = PhysicsCategoryBall;
        _ball.physicsBody.contactTestBitMask = PhysicsCategoryBottomLine |
                                               PhysicsCategoryBrick;
        _ball.physicsBody.affectedByGravity = NO;
        _ball.position   = CGPointMake(100, 50);
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
    
    [self loadLevel];
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
    if (fabs(self.ball.physicsBody.velocity.dx) < kMnAllowedXYSpeed){
        CGVector velocity     = self.ball.physicsBody.velocity;
        SKPhysicsBody *abody  = self.ball.physicsBody;
        self.ball.physicsBody = nil;
        velocity.dx           = self.ball.position.x > 200 ? -kSeedToSetForBallNearWall :
        kSeedToSetForBallNearWall;
        abody.velocity        = velocity;
        self.ball.physicsBody = abody;
    }
    if (fabs(self.ball.physicsBody.velocity.dy) < kMnAllowedXYSpeed){
        CGVector velocity     = self.ball.physicsBody.velocity;
        SKPhysicsBody *abody  = self.ball.physicsBody;
        self.ball.physicsBody = nil;
        velocity.dy           = -kSeedToSetForBallNearWall;
        abody.velocity        = velocity;
        self.ball.physicsBody = abody;

    }
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
    
    //Касание низа уровня
    if (firstBody.categoryBitMask == PhysicsCategoryBall &&
        secondBody.categoryBitMask == PhysicsCategoryBottomLine){
        NSLog(@"Game Over") ;
    }
    
    //Касание кирпича
    if (firstBody.categoryBitMask == PhysicsCategoryBall &&
        secondBody.categoryBitMask == PhysicsCategoryBrick){
        
        PL1Brick *aBrick = (PL1Brick *) secondBody.node;
        aBrick.physicsBody = nil;

        SKEmitterNode *fire = [self createFire];
        [aBrick addChild:fire];
        
//        fire.position = aBrick.position;
        
        SKAction *scale  = [SKAction scaleBy:0 duration:1];

        
        SKAction *sequence = [SKAction sequence:@[scale]];
        [aBrick runAction:sequence];
        
        [fire runAction:[SKAction waitForDuration:0.25]
             completion:^{
                 fire.particleBirthRate = 0;
                 [fire runAction:[SKAction waitForDuration:1]
                      completion:^{
                              SKAction *remove = [SKAction removeFromParent];
                          [aBrick runAction:remove];
                          [fire removeFromParent];
                      }];
             }];
        self.score++;
    }
}

- (void)loadLevel
{
    for (CGFloat x = 40; x < CGRectGetWidth(self.frame) - 30; x += 30){
        PL1Brick *aBrick = [PL1Brick brickAtPoint:CGPointMake(x, CGRectGetHeight(self.frame) - 40)];
        [self addChild:aBrick];
    }
}

- (SKEmitterNode *)createFire
{
    NSString *pathToFire = [[NSBundle mainBundle] pathForResource:@"fire"
                                                           ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToFire];
    return fire;
}

@end
