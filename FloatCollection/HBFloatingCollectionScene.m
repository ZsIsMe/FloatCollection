//
//  HBFloatingCollectionScene.m
//  FloatCollection
//
//  Created by haibao on 16/1/11.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "HBFloatingCollectionScene.h"
#import "HBFloatingNode.h"
@interface HBFloatingCollectionScene()


@property (nonatomic,assign) CGPoint         touchPoint;
@property (nonatomic,assign) NSTimeInterval  removingStartedTime;
@property (nonatomic,assign) NSTimeInterval  touchStartedTime;

@end
@implementation HBFloatingCollectionScene

- (void)didMoveToView:(SKView *)view{
    [super didMoveToView:view];
    [self configureFirst];
}
- (void)addChild:(SKNode *)node{
    
    if ([node isKindOfClass:[HBFloatingNode class]]) {
        [self configureNode:(HBFloatingNode*)node];
        [self.floatingNodes addObject:(HBFloatingNode*)node];
    }
    [super addChild:node];
}
- (void)configureFirst{
   
    //参数初始化
    self.timeToStartRemove = 0.7;
    self.timeToRemove      = 2;
    self.allowEditing      = NO;
    self.allowMutipleSelection   = YES;
    self.restictedToBounds  = YES;
    self.pushStrength      = 10000;
    self.floatingNodes     = [@[] mutableCopy];
    
    
    self.physicsWorld.gravity   = CGVectorMake(0, 0);
    self.physicsBody            = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.magneticField          = [SKFieldNode radialGravityField];
    self.magneticField.region   = [[SKRegion alloc]initWithRadius:10000];
    self.magneticField.minimumRadius =10000;
    self.magneticField.strength = 8000;
    self.position               = CGPointMake(self.size.width/2, self.size.height/2);
    
    [self addChild:self.magneticField];
    
    
}
- (void)configureNode:(HBFloatingNode*)node{
    if (node.physicsBody==nil) {
         CGPathRef  path =CGPathCreateMutable();
        
        if (node.path!=nil) {
            path = node.path;
        }
        node.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    }
   
    node.physicsBody.dynamic = YES;
    node.physicsBody.affectedByGravity = NO;
    node.physicsBody.allowsRotation    = NO;
    node.physicsBody.mass              = 0.3;
    node.physicsBody.friction          = 0;
    node.physicsBody.linearDamping     = 3;
    
}
#pragma mark touch事件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    self.touchPoint = [touch locationInNode:self];
    self.touchStartedTime = touch.timestamp;
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.mode == HBFloatingCollectionSceneModeEditing) {
        return;
    }
    
    UITouch * touch = [touches anyObject];
    if (touch) {
        
        CGPoint plin = [touch previousLocationInNode:self];
        CGPoint lin  = [touch locationInNode:self];
        CGFloat dx   = lin.x - plin.x;
        CGFloat dy   = lin.y - plin.y;
        
        CGFloat distance = sqrt(pow(lin.x, 2)+pow(lin.y, 2));
        
        dx = (distance==0)>0?0:(dx/distance);
        dy = (distance==0)>0?0:(dy/distance);
        
        if (dx==0&&dy==0) {
            return;
        }else if(self.mode!= HBFloatingCollectionSceneModeMoving){
            self.mode = HBFloatingCollectionSceneModeMoving;
        }
        for (HBFloatingNode * node in self.floatingNodes) {
            CGFloat width = node.frame.size.width/2;
            CGFloat height= node.frame.size.height/2;
            CGVector vector = CGVectorMake(self.pushStrength*dx, self.pushStrength*dy);
            if (self.restictedToBounds) {
                if ((node.position.x * dx > 0)&&!(node.position.x>-width&&node.position.x<width+self.size.width)) {
                    vector.dx = 0;
                }
                if ((node.position.y * dy > 0)&&!(node.position.y>-height&&node.position.y<height+self.size.height)) {
                    vector.dy = 0;
                }
            }
            [node.physicsBody applyForce:vector];
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.mode!= HBFloatingCollectionSceneModeMoving) {
        HBFloatingNode * node =(HBFloatingNode*)[self nodeAtPoint:self.touchPoint];
        [self updateNodeState:node];
    }
    self.mode = HBFloatingCollectionSceneModeNormal;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.mode = HBFloatingCollectionSceneModeNormal;
}

#pragma mark 重载
- (void)update:(NSTimeInterval)currentTime{
    
    for (HBFloatingNode * node in self.floatingNodes) {
        
        CGFloat distanceFromCenter = [self distanceBetweenPoint:self.magneticField.position secondPoint:node.position];
        node.physicsBody.linearDamping = distanceFromCenter > 100 ? 2 : 2 + ((100 - distanceFromCenter) / 10);
    }
    if (self.mode == HBFloatingCollectionSceneModeMoving||!self.allowEditing) {
        return;
    }
    if (!CGPointEqualToPoint(self.touchPoint, CGPointZero)&&self.touchStartedTime) {
        
        CGFloat duringTime = currentTime - self.touchStartedTime;
        
        if(duringTime>= self.timeToStartRemove){
            self.touchStartedTime = 0;
            HBFloatingNode * node = (HBFloatingNode*)[self nodeAtPoint:self.touchPoint];
            if (node) {
                self.removingStartedTime = currentTime;
            [self startRemovingNode:node];
            }
        }
    }else if(self.mode ==HBFloatingCollectionSceneModeEditing&&self.removingStartedTime&&!CGPointEqualToPoint(self.touchPoint, CGPointZero)){
        CGFloat duringTime = currentTime - self.removingStartedTime;
         HBFloatingNode * node = (HBFloatingNode*)[self nodeAtPoint:self.touchPoint];
        if (node) {
           
            if (duringTime>=self.timeToRemove) {
                self.removingStartedTime = 0;
                NSUInteger index = [self.floatingNodes indexOfObject:node];
                if (index != NSNotFound) {
                    [self removeFloatinNodeAtIndex:index];
                }
            }
           
        }
    }
}
- (void)startRemovingNode:(HBFloatingNode *)node{
    self.mode = HBFloatingCollectionSceneModeEditing;
    node.physicsBody.dynamic = NO;
    node.state = HBFloatingNodeStateRemoving;
    
    NSUInteger index = [self.floatingNodes indexOfObject:node];
    if (index!=NSNotFound) {
        if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:startedRemovingOfFloatingNodeAtIndex:)]) {
            [_floatingDelegate floatingScene:self startedRemovingOfFloatingNodeAtIndex:index];
        }
    }
}
- (void)updateNodeState:(HBFloatingNode*)node{
    NSUInteger index = [self.floatingNodes indexOfObject:node];
    if (index!= NSNotFound) {
        switch (node.state) {
            case HBFloatingNodeStateNormal:
                if ([self shouldSelectNodeAtIndex:index]) {
                    if (!self.allowMutipleSelection) {
                        NSInteger selectedIndex = [self indexOfSelectedNode];
                        if (selectedIndex!= NSNotFound) {
                            [self updateNodeState:self.floatingNodes[selectedIndex]];
                        }
                        
                    }
                    node.state = HBFloatingNodeStateSelected;
                }
            break;
            case HBFloatingNodeStateSelected:
                if ([self shouldDeselectNodeAtIndex:index]) {
                    node.state = HBFloatingNodeStateNormal;
                    if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:didDeselectFloatingNodeAtIndex:)]) {
                        
                        [_floatingDelegate floatingScene:self didDeselectFloatingNodeAtIndex:index];
                        
                    }
                }
            default:
                break;
        }
    }
}
- (void)cancelRemovingNode:(HBFloatingNode*)node{
    self.mode = HBFloatingCollectionSceneModeNormal;
    node.physicsBody.dynamic = YES;
    node.state   = node.previousState;
    NSUInteger index = [self.floatingNodes indexOfObject:node];
    if (index!=NSNotFound) {
        if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:canceledRemovingOfFloatingNodeAtIndex:)]) {
            [_floatingDelegate floatingScene:self canceledRemovingOfFloatingNodeAtIndex:index];
        }
    }
}
- (HBFloatingNode*)floatingNodeAtIndex:(NSInteger)index{
    if (index>=0&&index<self.floatingNodes.count) {
        return self.floatingNodes[index];
    }
    return nil;
}
- (NSInteger)indexOfSelectedNode{
    for (NSInteger i = 0; i<self.floatingNodes.count; i++) {
        HBFloatingNode * node = self.floatingNodes[i];
        if (node.state == HBFloatingNodeStateSelected) {
            return i;
        }
    }
    return NSNotFound;
}
#pragma mark --Floating Delegate Helpers
- (void)removeFloatinNodeAtIndex:(NSInteger)index{
    if ([self shouldRemoveNodeAtIndex:index]) {
        HBFloatingNode * node = self.floatingNodes[index];
        [self.floatingNodes removeObjectAtIndex:index];
        [node removeFromParent];
        if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:didRemoveFloatingNodeAtIndex:)]) {
            [_floatingDelegate floatingScene:self didRemoveFloatingNodeAtIndex:index];
        }
    }
}
- (BOOL)shouldRemoveNodeAtIndex:(NSInteger)index{
    if (index>=0&&index<self.floatingNodes.count-1) {
        if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:shouldRemoveFloatingNodeAtIndex:)]) {
            return [_floatingDelegate floatingScene:self shouldRemoveFloatingNodeAtIndex:index];
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

- (BOOL)shouldSelectNodeAtIndex:(NSInteger)index{
    if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:shouldSelectFloatingNodeAtIndex:)]) {
        return [_floatingDelegate floatingScene:self shouldSelectFloatingNodeAtIndex:index];
    }
    return true;
}
- (BOOL)shouldDeselectNodeAtIndex:(NSInteger)index{
    if (_floatingDelegate&&[_floatingDelegate respondsToSelector:@selector(floatingScene:shouldDeselectFloatingNodeAtIndex:)]) {
        return [_floatingDelegate floatingScene:self shouldDeselectFloatingNodeAtIndex:index];
    }
    return true;
}

- (SKNode*)nodeAtPoint:(CGPoint)p{
    SKNode * currentNode = [super nodeAtPoint:p];
    
    while (!([currentNode.parent isKindOfClass:[SKScene class]])&&!([currentNode isKindOfClass:[HBFloatingNode class]])) {
        currentNode = currentNode.parent;
    }
    return currentNode;
}
- (void)modeUpdated{
    switch (self.mode) {
        case HBFloatingCollectionSceneModeNormal:
        case HBFloatingCollectionSceneModeMoving:
            self.touchStartedTime = 0;
            self.removingStartedTime = 0;
            self.touchPoint       = CGPointZero;
            break;
        default:
            break;
    }
}
#pragma mark --helper
- (CGFloat)distanceBetweenPoint:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint{
    return hypot(secondPoint.x - firstPoint.x , secondPoint.y - firstPoint.y);
}

@end
