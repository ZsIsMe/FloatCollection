//
//  BubblesScene.m
//  FloatCollection
//
//  Created by haibao on 16/1/12.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "BubblesScene.h"
#import "BubbleNode.h"
typedef void (^CompletionBlock)(void);
static const CGFloat kBottomOffset = 100.0;


@implementation BubblesScene
- (void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    [self configure];
}
- (void)configure{
    self.topOffset       = 0;
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode       = SKSceneScaleModeAspectFill;
    self.allowMutipleSelection = false;
    CGRect bodyFrame     = self.frame;
    bodyFrame.size.width = self.magneticField.minimumRadius;
    bodyFrame.origin.x  -= bodyFrame.size.width/2;
    bodyFrame.size.height= self.frame.size.height - kBottomOffset;
    bodyFrame.origin.y   = self.frame.size.height - bodyFrame.size.height-self.topOffset;
    
    self.physicsBody     = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyFrame];
    self.magneticField.position = CGPointMake(CGRectGetWidth(self.frame)/2,
                                              CGRectGetWidth(self.frame)/2 +kBottomOffset/2 -self.topOffset/2
                                              );
    
}
- (void)addChild:(SKNode *)node{
    if ([node isKindOfClass:[BubbleNode class]]) {
        CGFloat x = [self getRadomFromMin:-kBottomOffset toMax:-node.frame.size.width];
        CGFloat y = [self getRadomFromMin:self.frame.size.height - kBottomOffset - CGRectGetHeight(node.frame)
                                    toMax: self.frame.size.height - self.topOffset - node.frame.size.height
                     ];
        if (self.floatingNodes.count%2==0||self.floatingNodes.count==0) {
            x = [self getRadomFromMin:CGRectGetWidth(self.frame)+CGRectGetWidth(node.frame)
                                toMax:CGRectGetWidth(self.frame)+kBottomOffset
                 ];
        }
        node.position = CGPointMake(x, y);
       
    }
    [super addChild:node];
}
- (void)performCommitSelectionAnimation{
    
    self.physicsWorld.speed = 0;
    NSArray * sortedArray = [self sortedFloatingNodes];
    NSMutableArray * actions = [@[] mutableCopy];
    
    for (HBFloatingNode * node in sortedArray) {
        node.physicsBody = nil;
        SKAction * action = [self actionForFloatingNode:node];
        [actions addObject:action];
    }
    [self runAction:[SKAction sequence:actions]];
}
- (NSArray*)sortedFloatingNodes{
   NSArray * sortedArray = [self.floatingNodes sortedArrayUsingComparator:^NSComparisonResult(HBFloatingNode   * _Nonnull  node, HBFloatingNode   * _Nonnull  nextNode) {
        CGFloat distance = [self distanceBetweenPoint:node.position secondPoint:self.magneticField.position];
        CGFloat nDistance = [self distanceBetweenPoint:nextNode.position secondPoint:self.magneticField.position];
        return distance<nDistance&&node.state != HBFloatingNodeStateSelected;
    }];
    return sortedArray;
}
-(SKAction*)actionForFloatingNode:(HBFloatingNode*)node{
    SKAction * action = [SKAction runBlock:^{
        NSInteger index = [self.floatingNodes indexOfObject:node];
        if (index!=NSNotFound) {
            [self removeFloatinNodeAtIndex:index];
            if (node.state == HBFloatingNodeStateSelected) {
             
                [self throwNode:node
                        toPoint:CGPointMake(self.size.width / 2, self.size.height + 40)
                     completion:^{
                         [node removeFromParent];
                     }];
                
            }
        }
    }];
        
              
    return action;
}
- (void)throwNode:(SKNode*)node toPoint:(CGPoint)toPoint completion:(CompletionBlock)block{
    [node removeAllActions];
    
    SKAction * movingXAction = [SKAction moveToX:toPoint.x duration:0.2];
    SKAction * movingYAction = [SKAction moveToY:toPoint.y duration:0.4];
    
    SKAction * resizeAction  = [SKAction scaleXTo:0.3 duration:.4];
    SKAction * throwAction   = [SKAction group:@[movingXAction,movingYAction,resizeAction]];
    [node runAction:throwAction completion:^{
        if (block) {
            block();
        }
    }];
}

#pragma 随机数
- (CGFloat)getRadomFromMin:(CGFloat)min toMax:(CGFloat)max{
    return [self getRadom]*(max-min)+min;
}
- (CGFloat)getRadom{
    return ((CGFloat)arc4random())/0xFFFFFFFF;
}
@end
