//
//  KAKMyScene.m
//  Zombie Conga
//
//  Created by Kemal Akkoyun on 04/05/14.
//  Copyright (c) 2014 Kemal Akkoyun. All rights reserved.
//

#import "KAKMyScene.h"

@implementation KAKMyScene

- (instancetype)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
//    background.anchorPoint = CGPointZero;
//    background.position = CGPointZero;
    background.anchorPoint = CGPointMake(0.5, 0.5); // Default point.
    background.position = CGPointMake(self.size.width / 2, self.size.height / 2);
//    background.zRotation = M_PI / 8;
    [self addChild:background];
  }
  return self;
}

@end
