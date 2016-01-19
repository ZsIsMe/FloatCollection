//
//  HBFloatingCollectionScene.h
//  FloatCollection
//
//  Created by haibao on 16/1/11.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class HBFloatingCollectionScene;
@class HBFloatingNode;

typedef NS_ENUM(NSInteger,HBFloatingCollectionSceneMode){
    
    HBFloatingCollectionSceneModeNormal =1,
    HBFloatingCollectionSceneModeEditing  ,
    HBFloatingCollectionSceneModeMoving
} ;
@protocol HBFloatingCollectionSceneDelegate <NSObject>

@optional
- (BOOL)floatingScene:(HBFloatingCollectionScene*)scene didSelectFloatingNodeAtIndex:(NSInteger)index;
@optional
- (BOOL)floatingScene:(HBFloatingCollectionScene*)scene shouldSelectFloatingNodeAtIndex:(NSInteger)index;
@optional
- (BOOL)floatingScene:(HBFloatingCollectionScene*)scene shouldDeselectFloatingNodeAtIndex:(NSInteger)index;
@optional
- (void)floatingScene:(HBFloatingCollectionScene*)scene didDeselectFloatingNodeAtIndex:(NSInteger)index;
@optional
- (void)floatingScene:(HBFloatingCollectionScene*)scene startedRemovingOfFloatingNodeAtIndex:(NSInteger)index;
@optional
- (void)floatingScene:(HBFloatingCollectionScene*)scene canceledRemovingOfFloatingNodeAtIndex:(NSInteger)index;
- (BOOL)floatingScene:(HBFloatingCollectionScene*)scene shouldRemoveFloatingNodeAtIndex:(NSInteger)index;
@optional
- (void)floatingScene:(HBFloatingCollectionScene*)scene didRemoveFloatingNodeAtIndex:(NSInteger)index;

@end



@interface HBFloatingCollectionScene : SKScene
@property (nonatomic,assign) NSTimeInterval  timeToStartRemove;
@property (nonatomic,assign) NSTimeInterval  timeToRemove;
@property (nonatomic,assign) HBFloatingCollectionSceneMode mode;
@property (nonatomic,assign) BOOL            allowEditing;
@property (nonatomic,assign) BOOL            allowMutipleSelection;
@property (nonatomic,assign) BOOL            restictedToBounds;
@property (nonatomic,assign) CGFloat         pushStrength;
@property (nonatomic,assign) id<HBFloatingCollectionSceneDelegate> floatingDelegate;
@property (nonatomic,strong) SKFieldNode   * magneticField;
@property (nonatomic,strong) NSMutableArray <HBFloatingNode*>* floatingNodes;

- (void)removeFloatinNodeAtIndex:(NSInteger)index;
- (CGFloat)distanceBetweenPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint;
@end
