//
//  SGParentGameViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 1/29/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kGameStateExisting,
    kGameStateNew
} GameState;

@interface SGParentGameViewController : UIViewController {
    UINavigationController *navController;
    UINavigationBar *navBar;
    GameState state;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil root:(GameState)theState;

@property(nonatomic, retain) UINavigationController *navController;
@property(nonatomic, retain) IBOutlet UINavigationBar *navBar;

@end
