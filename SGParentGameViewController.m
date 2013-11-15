//
//  SGParentGameViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/29/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGParentGameViewController.h"
#import "SGGameLoadingViewController.h"
#import "SGNewGameViewController.h"

@implementation SGParentGameViewController
@synthesize navController;
@synthesize navBar;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil root:(GameState)theState {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        state = theState;
    }
    return self;
}

#pragma mark - Selectors

-(void)back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (state == kGameStateExisting) {
        SGGameLoadingViewController *controller = [[SGGameLoadingViewController alloc] initWithNibName:@"SGLoadingViewController" bundle:nil];
        controller.presentedParent = self;
        self.navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        [controller release];
    }
    else {
        SGNewGameViewController *controller = [[SGNewGameViewController alloc] initWithNibName:@"SGNewGameViewController" bundle:nil];
        controller.presentedParent = self;
        self.navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
        [controller release];
    }

    self.navController.navigationBarHidden = YES;
    self.navController.view.frame = CGRectMake(0, 44, 320, 460-44);
    self.navBar.barStyle = UIBarStyleBlack;
    self.navBar.topItem.title = @"Compose";
    self.navBar.tintColor = [UIColor colorWithRed:RGBA_BAR_COLORS[0] green:RGBA_BAR_COLORS[1] blue:RGBA_BAR_COLORS[2] alpha:RGBA_BAR_COLORS[3]];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    self.navBar.topItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    [self.view addSubview:self.navController.view];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.navController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    self.navBar = nil;
    self.navController = nil;
    [super dealloc];
}

@end
