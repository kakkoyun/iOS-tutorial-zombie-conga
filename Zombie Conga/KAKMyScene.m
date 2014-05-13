//
//  KAKMyScene.m
//  Zombie Conga
//
//  Created by Kemal Akkoyun on 04/05/14.
//  Copyright (c) 2014 Kemal Akkoyun. All rights reserved.
//

#import "KAKMyScene.h"

#define ARC4RANDOM_MAX 0x100000000

static const float ZOMBIE_MOVES_PER_SECOND = 120.0; // About 1/5 of scene.
static const float ZOMBIE_ROTATE_RADIANS_PER_SECOND = 4 * M_PI;

static inline CGFloat ScalarRandomRange(const CGFloat min, const CGFloat max)
{
  return floorf(((double)arc4random() / ARC4RANDOM_MAX) * (max - min) + min);
}

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
  return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a, const CGPoint b)
{
  return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat c)
{
  return CGPointMake(a.x * c, a.y * c);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
  return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGFloat CGPointDistance(const CGPoint a, const CGPoint b)
{
  return CGPointLength(CGPointSubtract(a, b));
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
  CGFloat length = CGPointLength(a);
  return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
  return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
  return a <= 0 ? -1 : 1;
}

static inline CGFloat ScalarShortestAngleBetween(const CGFloat a, const CGFloat b)
{
  CGFloat difference = b - a;
  CGFloat angle = fmodf(difference, M_PI * 2);
  if (angle >= M_PI) {
    angle -= M_PI * 2;
  } else if (angle < -M_PI) {
    angle += M_PI * 2;
  }
  return angle;
}

@implementation KAKMyScene {
  SKSpriteNode *_zombie;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  CGPoint _velocity; // Represents 2D vector, direction(sign) and length (120,
  // 0) ->
  CGPoint _lastTouchLocation;
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
    //    [_zombie setScale:<#scale#>];

    _velocity = CGPointMake(ZOMBIE_MOVES_PER_SECOND, 0); // initial velocity
    [self addChild:background];
    [self addChild:_zombie];
    //    [self spawnEnemy];
    [self runAction:[SKAction
                        repeatActionForever:
                            [SKAction sequence:@[
                                                 [SKAction performSelector:@selector(spawnEnemy) onTarget:self],
                                                 [SKAction waitForDuration:2.0]
                                               ]]]];
  }
  return self;
}

- (void)update:(NSTimeInterval)currentTime
{
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;

  //  NSLog(@"%0.2f time since last update time in milliseconds.", _dt * 1000);

  CGFloat distance = CGPointDistance(_zombie.position, _lastTouchLocation);
  if (distance <= (_dt * ZOMBIE_MOVES_PER_SECOND)) {
    _zombie.position = _lastTouchLocation;
    _velocity = CGPointZero;
  } else {
    [self boundsCheckPlayerForZombie];
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SECOND];
    //  _zombie.position = CGPointMake(_zombie.position.x + 2,
    // _zombie.position.y);
    [self moveSprite:_zombie velocity:_velocity];
  }
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity
{
  CGPoint amountToMove = CGPointMake(velocity.x * _dt, velocity.y * _dt);
  //  NSLog(@"Amount to move : %@", NSStringFromCGPoint(amountToMove));

  sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)rotateSprite:(SKSpriteNode *)sprite
                 toFace:(CGPoint)direction
    rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
  CGFloat shortest = ScalarShortestAngleBetween(sprite.zRotation, CGPointToAngle(direction));
  CGFloat amtToRotate = rotateRadiansPerSec * _dt;
  CGFloat angle = fabsf(shortest) < amtToRotate ? fabsf(shortest) : amtToRotate;
  sprite.zRotation += ScalarSign(angle) * angle;
  // Note : Assumption that sprite actual faces pi degress.
  //  sprite.zRotation = CGPointToAngle(direction);
}

- (void)moveZombieTowardsLocation:(CGPoint)location
{
  CGPoint offset = CGPointSubtract(location, _zombie.position);
  CGPoint direction = CGPointNormalize(offset); // Normalizing.
  _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVES_PER_SECOND);
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

- (void)spawnEnemy
{
  SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
  enemy.position = CGPointMake(self.size.width + enemy.size.width / 2,
                               ScalarRandomRange(enemy.size.height / 2, self.size.height - enemy.size.height / 2));
  [self addChild:enemy];

  SKAction *wait = [SKAction waitForDuration:0.25];

  SKAction *actionLogMessage = [SKAction runBlock:^{ NSLog(@"Reached bottom !"); }];

  SKAction *actionMidMove = [SKAction moveByX:-self.size.width / 2 - enemy.size.width / 2
      y:-self.size.height / 2 + enemy.size.height / 2
      duration:1.0];

  SKAction *actionMove = [SKAction moveToX:-enemy.size.width / 2 duration:2.0];

  //  SKAction *actionReverseMid = [actionMidMove reversedAction];
  //  SKAction *actionReverseMove = [actionMove reversedAction];
  //
  //  SKAction *sequence = [SKAction sequence:@[
  //                                            actionMidMove,
  //                                            actionLogMessage,
  //                                            wait,
  //                                            actionMove,
  //                                            actionReverseMove,
  //                                            actionLogMessage,
  //                                            wait,
  //                                            actionReverseMid
  //                                          ]];

  SKAction *sequence = [SKAction sequence:@[ actionMidMove, actionLogMessage, wait, actionMove ]];

  sequence = [SKAction sequence:@[ sequence, [sequence reversedAction] ]];

  //  [enemy runAction:sequence];

  SKAction *repeat = [SKAction repeatActionForever:sequence];
  [enemy runAction:repeat];
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
