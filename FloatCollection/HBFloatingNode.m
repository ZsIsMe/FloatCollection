//
//  HBFloatingNode.m
//  FloatCollection
//
//  Created by haibao on 16/1/11.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBFloatingNode.h"

NSString * const HBFloatingNodeRemovingKey = @"action.removing";
NSString * const HBFloatingNodeSelectingKey = @"action.selecting";
NSString * const HBFloatingNormalizeKey = @"action.normalize";

@interface HBFloatingNode ()
@property (nonatomic,assign) HBFloatingNodeState tempState ;

@end


@implementation HBFloatingNode

- (void)stateChanged{
    SKAction * action;
    NSString * actionKey;
    
    switch (self.state) {
        case HBFloatingNodeStateNormal:
            action = [self normalizeAnimation];
            actionKey = HBFloatingNormalizeKey;
            break;
        case  HBFloatingNodeStateSelected:
            action = [self selectingAnimation];
            actionKey= HBFloatingNodeSelectingKey;
            break;
        case HBFloatingNodeStateRemoving:
            action  = [self removingAnimation];
            actionKey= HBFloatingNodeRemovingKey;
        default:
            break;
    }
    
    if (action&&actionKey) {
        [self runAction:action withKey:actionKey];
    }
}
- (SKAction*)selectingAnimation{
    return nil;
}
- (SKAction*)normalizeAnimation{
    return nil;
}
- (SKAction*)removeAnimation{
    return nil;
}
- (SKAction*)removingAnimation{
    return nil;
}

#pragma mark --lazy init
- (void)setState:(HBFloatingNodeState)state{
    if (self.tempState !=state) {
        self.previousState = self.tempState;
        self.tempState     = state;
        [self stateChanged];
    }
}

- (HBFloatingNodeState)state{
    return self.tempState;
}
- (HBFloatingNodeState)previousState{
    if (!_previousState) {
        _previousState = HBFloatingNodeStateNormal;
    }
    return _previousState;
}
- (HBFloatingNodeState)tempState{
    if (!_tempState) {
        _tempState = HBFloatingNodeStateNormal;
    }
    return _tempState;
}
@end
