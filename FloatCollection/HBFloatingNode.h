//
//  HBFloatingNode.h
//  FloatCollection
//
//  Created by haibao on 16/1/11.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


extern  NSString * const HBFloatingNodeRemovingKey  ;
extern  NSString * const HBFloatingNodeSelectingKey ;
extern  NSString * const HBFloatingNormalizeKey     ;

typedef NS_ENUM(NSInteger,HBFloatingNodeState){
    HBFloatingNodeStateNormal = 1,
    HBFloatingNodeStateSelected,
    HBFloatingNodeStateRemoving
};

@interface HBFloatingNode : SKShapeNode
@property (nonatomic,assign) HBFloatingNodeState state;
@property (nonatomic,assign) HBFloatingNodeState previousState;

- (SKAction*)selectingAnimation;
- (SKAction*)normalizeAnimation;
- (SKAction*)removeAnimation;
- (SKAction*)removingAnimation;

@end
