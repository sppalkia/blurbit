//
//  SGTutorialViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGImageViewController;
@interface SGTutorialViewController : UIViewController {
    SGImageViewController *_imageController;
    NSArray *_imageNames;
    
    NSUInteger _index;
    
    UIBarButtonItem *previous;
    UIBarButtonItem *next;
}

@property(nonatomic, retain) UINavigationController *navController;

@end
