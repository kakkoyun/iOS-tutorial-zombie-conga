//
//  KAKMyScene.m
//  Zombie Conga
//
//  Created by Kemal Akkoyun on 04/05/14.
//  Copyright (c) 2014 Kemal Akkoyun. All rights reserved.
//

#import "KAKMyScene.h"

static const float ZOMBIE_MOVES_PER_SECOND = 120.0; // About 1/5 of scene.

@implementation KAKMyScene
{
  SKSpriteNode *_zombie;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  CGPoint _velocity; // Represents 2D vector, direction(sign) and length (120, 0) ->
}

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
    NSLog(@"Size: %@", NSStringFromCGSize(background.size));
    
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    //    _zombie.xScale = 2;
    //    _zombie.yScale = 2;
    //    [_zombie setScale:
    
    _velocity = CGPointMake(ZOMBIE_MOVES_PER_SECOND, 0); // initial velocity
    [self addChild:background];
    [self addChild:_zombie];
  }
  return self;
}

- (void)update:(NSTimeInterval)currentTime
{
  if(_lastUpdateTime){
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;
  NSLog(@"%0.2f time since last update time in milliseconds.", _dt * 1000);
  
  [self boundsCheckPlayerForZombie];
  [self rotateSprite:_zombie toFace:_velocity];
  //  _zombie.position = CGPointMake(_zombie.position.x + 2, _zombie.position.y);
  [self moveSprite:_zombie
          velocity:_velocity];
}

- (void) moveSprite:(SKSpriteNode *)sprite
           velocity:(CGPoint)velocity
{
  CGPoint amountToMove = CGPointMake(velocity.x * _dt, velocity.y * _dt);
  NSLog(@"Amount to move : %@", NSStringFromCGPoint(amountToMove));
  
  sprite.position = CGPointMake(sprite.position.x + amountToMove.x,
                                sprite.position.y + amountToMove.y);
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)direction
{
  // Note : Assumption that sprite actual faces pi degress.
  sprite.zRotation = atan2f(direction.y, direction.x);
  
}

- (void)moveZombieTowardsLocation:(CGPoint)location
{
  CGPoint offset = CGPointMake(location.x - _zombie.position.x,
                               location.y - _zombie.position.y);
  CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
  CGPoint direction = CGPointMake(offset.x / length, offset.y / length); // Normalizing.
  _velocity = CGPointMake(direction.x * ZOMBIE_MOVES_PER_SECOND,
                          direction.y * ZOMBIE_MOVES_PER_SECOND);
}

- (void)boundsCheckPlayerForZombie
{
  CGPoint latestPosition = _zombie.position;
  CGPoint latestVelocity = _velocity;
  
  CGPoint bottomLeft = CGPointZero;
  CGPoint topRight = CGPointMake(self.size.width, self.size.height);
  
  if (latestPosition.x <= bottomLeft.x) {
    latestPosition.x = bottomLeft.x;
    latestVelocity.x = -latestVelocity.x;
  }
  if (latestPosition.y <= bottomLeft.y) {
    latestPosition.y = bottomLeft.y;
    latestVelocity.y = -bottomLeft.y;
  }
  if (latestPosition.x >= topRight.x) {
    latestPosition.x = topRight.x;
    latestVelocity.x = -latestVelocity.x;
  }
  if (latestPosition.y >= topRight.y) {
    latestPosition.y = topRight.y;
    latestVelocity.y = -latestVelocity.y;
  }
  
  _zombie.position = latestPosition;
  _velocity = latestVelocity;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
  [self moveZombieTowardsLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
  [self moveZombieTowardsLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
  [self moveZombieTowardsLocation:touchLocation];
}

@end
