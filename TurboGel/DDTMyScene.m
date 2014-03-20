#import "DDTMyScene.h"

typedef NS_ENUM(NSUInteger , Direction)
{
  None,
  Left,
  Right
};


@interface DDTMyScene ()

@property (nonatomic, strong) SKSpriteNode *ship;
@property (nonatomic) Direction direction;
@property (nonatomic, strong) SKSpriteNode *energyShip;

@property (nonatomic) NSInteger smokeShootDelay;

@property (nonatomic) BOOL isTouching;

@property (strong, nonatomic) SKAction *bulletSound;

@property (nonatomic) NSInteger whichBullet;

@end


@implementation DDTMyScene

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor blackColor];
    
    self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    [self addChild:self.ship];
    self.ship.zPosition = 100;
    
    self.ship.position = CGPointMake(160, 150);
    
    self.ship.physicsBody.collisionBitMask = 1;
    self.ship.physicsBody.categoryBitMask = 1;
    self.ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.ship.size];
    self.ship.physicsBody.dynamic = NO;
    self.physicsWorld.contactDelegate = self;
    
    self.energyShip = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    [self addChild:self.energyShip];
    self.energyShip.zPosition = 100;
    self.energyShip.position = CGPointMake(20, 400);
    
    self.bulletSound = [SKAction playSoundFileNamed:@"bullet.wav" waitForCompletion:NO];
    
    [self makeTean];
    
    
    [self makeRopeAttachedToNode:self.ship];
    
  }
  return self;
}

- (void)makeRopeAttachedToNode:(SKSpriteNode *)node
{
  SKSpriteNode *ropeNode = [SKSpriteNode spriteNodeWithImageNamed:@"Smoke1"];
  ropeNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeNode.size];
  [self addChild:ropeNode];
  
  SKPhysicsJointFixed *joint= [SKPhysicsJointFixed jointWithBodyA:ropeNode.physicsBody bodyB:node.physicsBody anchor:CGPointMake(self.ship.frame.origin.x, self.ship.frame.origin.y+20)];
  [self.physicsWorld addJoint:joint];
  
  
}

- (void)createGelAt:(CGPoint)point
{
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"GelStick"];
  sprite.position = point;
  SKAction *action = [SKAction rotateByAngle:(arc4random() % 7) -3.5  duration:2];
  [sprite runAction:[SKAction repeatActionForever:action]];
  [sprite runAction:[SKAction sequence:@[[SKAction moveToY:0 duration:4], [SKAction removeFromParent] ]]];
  [self addChild:sprite];
  sprite.name = @"Gel";
  
  
  //sprite.physicsBody.collisionBitMask = 1;
  sprite.physicsBody.categoryBitMask = 1;
  sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
  sprite.physicsBody.affectedByGravity = NO;
  sprite.physicsBody.friction = 0.1;
}



- (void)createBackgroundAt:(CGPoint)point
{
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
  sprite.position = point;
  [sprite runAction:[SKAction sequence:@[[SKAction moveToY:-140 duration:6], [SKAction removeFromParent] ]]];
  [self addChild:sprite];
  sprite.name = @"Background";
}

- (void)placeRandomGel
{
  NSInteger randomNumber = arc4random() % 320;
  [self createGelAt:CGPointMake(randomNumber ,600)];
}
- (void)placeRandomBackground
{
  NSInteger randomNumber = arc4random() % 320;
  [self createBackgroundAt:CGPointMake(randomNumber ,800)];
}
- (void)makeSmoke:(NSString *)bulletImageName
{
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:bulletImageName];
  sprite.position = CGPointMake(self.ship.position.x, self.ship.position.y+40);
  [sprite runAction:[SKAction sequence:@[ [SKAction moveBy:CGVectorMake(0 , 2000) duration:2], [SKAction removeFromParent] ]]];
  [self addChild:sprite];
  sprite.physicsBody.affectedByGravity = YES;
  sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
  sprite.physicsBody.categoryBitMask = 2;
  
  sprite.physicsBody.contactTestBitMask = 1;
  
  /*
  sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Smoke"];
  sprite.position = CGPointMake(self.ship.position.x+10, self.ship.position.y+40);
  [sprite runAction:[SKAction sequence:@[ [SKAction moveBy:CGVectorMake(0 , 2000) duration:2], [SKAction removeFromParent] ]]];
  [self addChild:sprite];
  sprite.physicsBody.affectedByGravity = YES;
  sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
  */
  
}

- (void)makeTean
{
  SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"BackgroundTean"];
  sprite.position = CGPointMake(160,2000);
  [sprite runAction:[SKAction sequence:@[[SKAction moveToY:-2000 duration:50], [SKAction removeFromParent] ]]];
  [self addChild:sprite];
  sprite.name = @"Background";
}

-(void)update:(CFTimeInterval)currentTime
{
  if ( ! (arc4random() % 40)) {
    [self placeRandomGel];
  }
  
  if ( ! (arc4random() % 100)) {
    [self placeRandomBackground];
  }
  
  if (self.isTouching) {
    if (!self.smokeShootDelay) {
      [self makeSmoke:[NSString stringWithFormat:@"Smoke%d", ++self.whichBullet]];
      if (self.whichBullet == 5) {
        self.whichBullet = 0;
      }
      self.smokeShootDelay = 1;
    }
    self.smokeShootDelay --;
  }
  
  [self checkForShipOverGel];
}

- (void)checkForShipOverGel
{
  [self enumerateChildNodesWithName:@"Gel" usingBlock:^(SKNode *node, BOOL *stop){
    
    CGPoint shipCentre = CGPointMake(self.ship.position.x + self.ship.size.width/2 , self.ship.position.y +self.ship.size.height/2);
    if ([node containsPoint:shipCentre] )
    {
      [self.energyShip runAction:[SKAction moveBy:CGVectorMake(0, -10) duration:0]];
    }
  }];
  
  if (self.energyShip.position.y < 0) {

  }
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
 // if (contact.bodyA.collisionBitMask == )
  
//  [contact.bodyA.node runAction:self.bulletSound];
  
}


- (void)didEndContact:(SKPhysicsContact *)contact
{
  
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.isTouching = YES;
  
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    
    [self.ship runAction:[SKAction moveToX:location.x duration:.2]];
  }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    
    [self.ship runAction:[SKAction moveToX:location.x duration:.2]];
  }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.isTouching = NO;
  
  [self.ship removeAllActions];
  
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.isTouching = NO;
  
  [self.ship removeAllActions];
}


@end
