//
//  SGLoadingViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 1/29/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGLoadingViewController : UIViewController {
    UIViewController *presentedParent;
    BOOL visited;
    BOOL finished;
}

@property(nonatomic, retain) UIViewController *presentedParent;

-(void)performLoad;

@end
