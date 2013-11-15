//
//  SGResponseViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGAWSGame;
@interface SGResponseViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate> {
    UIViewController *presentedParent;
}

@property(nonatomic, retain) UIViewController *presentedParent;

-(void)sendGameToServer:(SGAWSGame *)game;

@end
