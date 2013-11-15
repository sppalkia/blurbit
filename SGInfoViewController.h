//
//  SGInfoViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 1/25/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGInfoViewController : UIViewController {
    UIView *shadowedView;
}

@property(nonatomic, retain) IBOutlet UIView *shadowedView;

-(IBAction)back:(id)sender;

@end
