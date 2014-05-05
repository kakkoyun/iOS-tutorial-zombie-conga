//
//  KAKViewController.m
//  Zombie Conga
//
//  Created by Kemal Akkoyun on 04/05/14.
//  Copyright (c) 2014 Kemal Akkoyun. All rights reserved.
//

#import "KAKViewController.h"
#import "KAKMyScene.h"

@implementation KAKViewController

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  // Configure the view.
  SKView * skView = (SKView *)self.view;

  if(!skView.scene){
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // SKScene : SKNode
    // SKNode.userInteractionEnabled = NO; by default
    // SKScene.userInteractionEnabled = YES; by default
    
    // Create and configure the scene.
    SKScene * scene = [KAKMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
  }
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIInterfaceOrientationMaskAllButUpsideDown;
  } else {
    return UIInterfaceOrientationMaskAll;
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

@end
