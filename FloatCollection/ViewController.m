//
//  ViewController.m
//  FloatCollection
//
//  Created by haibao on 16/1/11.
//  Copyright © 2016年 haibao. All rights reserved.
//

#import "ViewController.h"
#import "BubbleNode.h"
#import "BubblesScene.h"

@interface ViewController ()
@property (nonatomic,strong) SKView * skView;
@property (nonatomic,strong) BubblesScene * floatingCollectionScene;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.skView = [[SKView alloc]initWithFrame:self.view.frame];
    self.skView.backgroundColor = [SKColor whiteColor];
    [self.view addSubview:self.skView];
    
    self.floatingCollectionScene = [[BubblesScene alloc]initWithSize:
                                    self.skView.bounds.size];
    
    [self.skView presentScene:self.floatingCollectionScene];
    self.floatingCollectionScene.topOffset = 64;
    self.floatingCollectionScene.topOffset = 0;
    for (int i=0; i<20; i++) {
        BubbleNode * node = [BubbleNode instantiate];
        [self.floatingCollectionScene addChild:node];
    }
    
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
