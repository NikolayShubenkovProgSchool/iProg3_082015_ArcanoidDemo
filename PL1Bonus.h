//
//  Bonus.h
//  iProg3_082015_ArcanoidDemo
//
//  Created by Nikolay Shubenkov on 19/08/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, PL1BonusType) {
    PL1BonusTypeFire,
    PL1BonusTypeLargedesk
};

@class PL1Bonus;
@protocol PL1BonusDelegate <NSObject>

- (void)pl1_bonusDidExpired:(PL1Bonus *)bonus;

@end



@interface PL1Bonus : SKSpriteNode

@property (nonatomic) PL1BonusType type;
@property (nonatomic) id <PL1BonusDelegate> delegate;

//default value is 5 sec
@property (nonatomic) NSTimeInterval lifetime;

- (void)startExpiring;
- (void)resetExpireTime;
+ (instancetype)bonusWithPosition:(CGPoint)poisition type:(PL1BonusType)type;

@end
