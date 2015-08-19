//
//  GameScene.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 08/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "GameScene.h"

#import "Constants.h"
#import "PL1Brick.h"
#import "PL1Bonus.h"

static const CGFloat kMnAllowedXYSpeed = 20;
//в слчае когда мяч возле самой стены
static const CGFloat kSpeedToSetForBallNearWall = 40;

@interface GameScene () <SKPhysicsContactDelegate, PL1BonusDelegate>

@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKSpriteNode *desk;
@property (nonatomic) BOOL isTouchingDesk;
@property (nonatomic, strong) SKNode *bottomLine;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) NSArray *bonuses;

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
        _ball.physicsBody.collisionBitMask   = PhysicsCategoryDesk | PhysicsCategoryBrick;
        _ball.physicsBody.affectedByGravity = NO;
        _ball.position   = CGPointMake(100, 100);
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
    border.linearDamping  = 0;
    border.angularDamping = 0;
    border.restitution    = 1;
    self.physicsBody      = border;
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    [self.ball.physicsBody applyImpulse:CGVectorMake(8, 10)];
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
    
    //test for x velocity
    if (fabs(self.ball.physicsBody.velocity.dx) < kMnAllowedXYSpeed){
        CGVector velocity     = self.ball.physicsBody.velocity;
        SKPhysicsBody *abody  = self.ball.physicsBody;
        self.ball.physicsBody = nil;
        velocity.dx           = self.ball.position.x > 200 ? -kSpeedToSetForBallNearWall :
        kSpeedToSetForBallNearWall;
        abody.velocity        = velocity;
        self.ball.physicsBody = abody;
    }
    //test for y velocity
    if (fabs(self.ball.physicsBody.velocity.dy) < kMnAllowedXYSpeed){
        CGVector velocity     = self.ball.physicsBody.velocity;
        SKPhysicsBody *abody  = self.ball.physicsBody;
        self.ball.physicsBody = nil;
        velocity.dy           = self.ball.position.y < 200 ? kSpeedToSetForBallNearWall : -kSpeedToSetForBallNearWall;
        abody.velocity        = velocity;
        self.ball.physicsBody = abody;
    }
    //get speed and update if it too small
    CGFloat speed = sqrt(pow(self.ball.physicsBody.velocity.dy, 2) + pow(self.ball.physicsBody.velocity.dx, 2));
    if (speed < 200){
        SKPhysicsBody *ballBody = self.ball.physicsBody;
        self.ball.physicsBody   = nil;
        CGVector updatedVelocity = ballBody.velocity;
        updatedVelocity.dx /= speed;
        updatedVelocity.dy /= speed;
        updatedVelocity.dx *= 200;
        updatedVelocity.dy *= 200;
        ballBody.velocity = updatedVelocity;
        self.ball.physicsBody = ballBody;
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
        
        SKAction *scale  = [SKAction scaleBy:0 duration:1];

        SKAction *sequence = [SKAction sequence:@[scale]];
        [aBrick runAction:sequence];
        
        [self bonusFromPoint:aBrick.position];
        
        [fire runAction:[SKAction waitForDuration:0.25]
             completion:^{
                 fire.particleBirthRate = 0;
                 [fire runAction:[SKAction waitForDuration:1]
                      completion:^{
                          [aBrick removeFromParent];
                      }];
             }];
        self.score++;
    }
}

- (void)loadLevel
{
    CGFloat y = CGRectGetHeight(self.frame) - 40;
    
    for (int i = 0; i < 8; i ++, y-= 30) {
        for (CGFloat x = (i % 2) == 0 ? 40 : 20; x < CGRectGetWidth(self.frame) - 30; x += 30){
            PL1Brick *aBrick = [PL1Brick brickAtPoint:CGPointMake(x, y)];
            [self addChild:aBrick];
        }
    }
}

- (SKEmitterNode *)createFire
{
    NSString *pathToFire = [[NSBundle mainBundle] pathForResource:@"fire"
                                                           ofType:@"sks"];
    SKEmitterNode *fire = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToFire];
    return fire;
}

- (SKNode *)bonusFromPoint:(CGPoint)aPoint
{
    if (arc4random() % 1 == 0){
        
        PL1Bonus *bonus = [PL1Bonus bonusWithPosition:aPoint type:PL1BonusTypeFire];
        [bonus runAction:[SKAction moveTo:CGPointMake(arc4random() % (int) CGRectGetWidth(self.frame), 0) duration:3] completion:^{
        }];
        
        bonus.delegate = self;
        self.bonuses = [[NSArray arrayWithArray:self.bonuses] arrayByAddingObject:bonus];
        
        [self addChild:bonus];
        return bonus;
    }
    return nil;
}

#pragma mark

- (void)pl1_bonusDidExpired:(PL1Bonus *)bonus
{
    NSMutableArray *bonuses = [NSMutableArray arrayWithArray:self.bonuses];
    
    [bonuses removeObject:bonus];
    
    self.bonuses = [bonuses copy];
    NSLog(@"Bonus expired");
}

@end
