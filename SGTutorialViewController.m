//
//  SGTutorialViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGTutorialViewController.h"
#import "SGImageViewController.h"

@implementation SGTutorialViewController
@synthesize navController;

#define NUM_PAGES   9

#pragma mark - Selectors

-(void)back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)previousImage {
    if ([[next title] isEqualToString:@"Done!"]) {
        next.title = @"Next";
    }
    _index--;
    if (_index == 0) {
        previous.enabled = NO;
    }
    NSString *imgName = [_imageNames objectAtIndex:_index];
    UIImage *img = [UIImage imageNamed:imgName];
    [_imageController.imageView setImage:img];
}

-(void)nextImage {
    if ([[next title] isEqualToString:@"Done!"]) {
        [self back];
        return;
    }

    previous.enabled = YES;
    _index++;
    if (_index >= NUM_PAGES-1) {
        next.title = @"Done!";
    }
    
    NSString *imgName = [_imageNames objectAtIndex:_index];
    UIImage *img = [UIImage imageNamed:imgName];
    [_imageController.imageView setImage:img];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = 0;
    _imageNames = [[NSArray alloc] initWithObjects:@"page1.png", @"page2.png", @"page3.png", @"page4.png", @"page5.png", @"page6.png", @"page7.png", @"page8.png", @"page9.png", nil];
    _imageController = [[SGImageViewController alloc] initWithNibName:@"SGImageViewController" bundle:nil];
    self.navController = [[[UINavigationController alloc] initWithRootViewController:_imageController] autorelease];
    
    self.navController.navigationBarHidden = NO;
    self.navController.view.frame = CGRectMake(0, 0, 320, 460);
    self.navController.navigationBar.frame = CGRectMake(0, 0, 320.0f, 44.0f);
    self.navController.navigationBar.barStyle = UIBarStyleBlack;
    self.navController.navigationBar.tintColor = [UIColor colorWithRed:RGBA_BAR_COLORS[0]
                                                            green:RGBA_BAR_COLORS[1] 
                                                             blue:RGBA_BAR_COLORS[2] 
                                                            alpha:RGBA_BAR_COLORS[3]];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                                             style:UIBarButtonItemStylePlain 
                                                            target:self 
                                                            action:@selector(back)];
    previous = [[UIBarButtonItem alloc] initWithTitle:@"Previous" 
                                                style:UIBarButtonItemStylePlain 
                                                target:self 
                                                action:@selector(previousImage)];

    next = [[UIBarButtonItem alloc] initWithTitle:@"Next" 
                                            style:UIBarButtonItemStylePlain 
                                            target:self 
                                            action:@selector(nextImage)];
    
    self.navController.navigationBar.topItem.title = @"";
    self.navController.navigationBar.topItem.rightBarButtonItems = [NSArray arrayWithObjects:next, previous, nil];
    self.navController.navigationBar.topItem.leftBarButtonItem = back;
    
    [back release];
    
    previous.enabled = NO;

    [self.view addSubview:self.navController.view];
}

#pragma mark - Memory Management

-(void)dealloc {
    [previous release];
    [next release];
    [_imageNames release];
    [_imageController release];
    self.navController = nil;
    [super dealloc];
}


@end
