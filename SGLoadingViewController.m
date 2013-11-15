//
//  SGLoadingViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/29/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGLoadingViewController.h"
#import "SGNewGameViewController.h"
#import "SGListGamesViewController.h"
#import "SGPlayGameViewController.h"
#import "SGAWSUtility.h"
#import "SGAWSGame.h"

@implementation SGLoadingViewController
@synthesize presentedParent;

-(void)performLoad {
    //does nothing; interface
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    visited = NO;
    finished = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performLoad];
}

#pragma mark - Memory Management

-(void)dealloc {
    self.presentedParent = nil;
    [super dealloc];
}

@end
