//
//  Bonus.m
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 19/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "PL1Bonus.h"

#import "Constants.h"

@interface PL1Bonus()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PL1Bonus

+ (instancetype)bonusWithPosition:(CGPoint)poisition type:(PL1BonusType)type
{
    PL1Bonus *bonus  = [self spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(40, 40)];
    
    bonus.lifetime = 5;
    bonus.type     = type;
    
    bonus.position = poisition;
    
    SKPhysicsBody *aBody = [SKPhysicsBody bodyWithRectangleOfSize:bonus.size];
    aBody.restitution    = 1;
    aBody.linearDamping  = 0;
    aBody.angularDamping = 0;
    aBody.allowsRotation = NO;
    aBody.dynamic        = YES;
    aBody.categoryBitMask  = PhysicsCategoryBonus;
    aBody.collisionBitMask = 0;
    aBody.contactTestBitMask = PhysicsCategoryDesk | PhysicsCategoryBottomLine;
    bonus.physicsBody  = aBody;
    
    return bonus;
}

- (void)startExpiring
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.lifetime
                                                  target:self
                                                selector:@selector(expire:)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)expire:(NSTimer *)timer
{
    [self.delegate pl1_bonusDidExpired:self];
}

@end
