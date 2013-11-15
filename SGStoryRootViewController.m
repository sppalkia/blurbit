//
//  SGStoryRootViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStoryRootViewController.h"
#import "SGStoriesViewController.h"
#import "SGStoryLoadingViewController.h"
#import "SGAWSUtility.h"

@implementation SGStoryRootViewController
@synthesize tabController;
@synthesize stories;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

#pragma mark - Selectors

-(void)back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(UINavigationController *)initNavigationControllerWithRoot:(UIViewController *)controller {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    //navController.view.frame = CGRectMake(0, 44.0f, 320.f, 367.0f);
    navController.navigationBarHidden = NO;
    navController.view.frame = CGRectMake(0, 44, 320, 460-44);
    navController.navigationBar.frame = CGRectMake(0, 0, 320.0f, 44.0f);
    navController.navigationBar.barStyle = UIBarStyleBlack;
    navController.navigationBar.tintColor = [UIColor colorWithRed:RGBA_BAR_COLORS[0]
                                                            green:RGBA_BAR_COLORS[1] 
                                                             blue:RGBA_BAR_COLORS[2] 
                                                            alpha:RGBA_BAR_COLORS[3]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    navController.navigationBar.topItem.leftBarButtonItem = backButton;
    [backButton release];
    
    return navController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabController.delegate = self;
    SGStoryLoadingViewController *controller1 = [[SGStoryLoadingViewController alloc] initWithNibName:@"SGLoadingViewController" bundle:nil query:LOCAL_QUERY];
    controller1.presentedParent = self;
    UINavigationController *navController1 = [self initNavigationControllerWithRoot:controller1];
    [controller1 release];
        
    SGStoryLoadingViewController *controller2 = [[SGStoryLoadingViewController alloc] initWithNibName:@"SGLoadingViewController" bundle:nil query:VOTE_QUERY];
    controller2.presentedParent = self;
    UINavigationController *navController2 = [self initNavigationControllerWithRoot:controller2];
    [controller2 release];
    
    SGStoryLoadingViewController *controller3 = [[SGStoryLoadingViewController alloc] initWithNibName:@"SGLoadingViewController" bundle:nil query:NEWEST_QUERY];
    controller3.presentedParent = self;
    UINavigationController *navController3 = [self initNavigationControllerWithRoot:controller3];
    [controller3 release];

    
    navController1.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:kSavedTabBarIndex] autorelease];
    navController2.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:kTopTabBarIndex] autorelease];
    navController3.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:kNewestTabBarIndex] autorelease];

    self.tabController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, nil];
    [navController1 release];
    [navController2 release];
    [navController3 release];

    //self.tabController.view.frame = CGRectMake(0.0f, 44.0f, 320.0f, 416.0f);
    [self.view addSubview:self.tabController.view];
}

#pragma mark - Memory Management

-(void)dealloc {
    self.tabController = nil;
    self.stories = nil;
    [super dealloc];
}

@end
