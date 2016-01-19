//
//  BubbleNode.m
//  FloatCollection
//
//  Created by haibao on 16/1/12.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "BubbleNode.h"
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKitBase.h>

@interface BubbleNode ()
@property (nonatomic,strong) SKLabelNode * labelNode;
@end

@implementation BubbleNode

+(BubbleNode*)instantiate{

    BubbleNode * node = [BubbleNode shapeNodeWithPath:([UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 60, 60)]).CGPath centered:YES];
    [node configureNode];
    return node;
}
- (void)configureNode{
    
    CGRect  boundingBox = CGPathGetBoundingBox(self.path);
    CGFloat radius      = boundingBox.size.width/2;
    self.physicsBody    = [SKPhysicsBody bodyWithCircleOfRadius:radius+1.5];
    self.fillColor      = [UIColor colorWithRed:255.0/256 green:38.0/256 blue:84.0/256 alpha:1];
    self.strokeColor    = self.fillColor;
    
    self.labelNode          = [SKLabelNode labelNodeWithFontNamed:@""];
    self.labelNode.text     = @"呵呵";
    self.labelNode.position = CGPointZero;
    self.labelNode.fontColor = [SKColor whiteColor];
    self.labelNode.fontSize = 10;
    self.labelNode.userInteractionEnabled  = NO;
    self.labelNode.verticalAlignmentMode   = SKLabelVerticalAlignmentModeCenter;
    self.labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    [self addChild:self.labelNode];
   
    
}
- (SKAction*)selectingAnimation{
    [self removeActionForKey:HBFloatingNodeRemovingKey];
    return [SKAction scaleTo:1.3 duration:0.2];
}
- (SKAction*)normalizeAnimation{
    [self removeActionForKey:HBFloatingNodeRemovingKey];
    return [SKAction scaleTo:1 duration:0.2];
}
- (SKAction*)removeAnimation{
    [self removeActionForKey:HBFloatingNodeRemovingKey];
    return [SKAction fadeOutWithDuration:0.2];
}
- (SKAction*)removingAnimation{
    SKAction * pulseUp   = [SKAction scaleTo:self.xScale+0.13 duration:0];
    SKAction * pulseDown = [SKAction scaleTo:self.xScale duration:.3];
    SKAction * pulse     = [SKAction sequence:@[pulseUp,pulseDown]];
    SKAction * repeatPulse = [SKAction repeatActionForever:pulse];
    return repeatPulse;
}
@end
