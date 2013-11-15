//
//  SGPlayGameViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGResponseViewController.h"

@class SGAWSGame;
@interface SGPlayGameViewController : SGResponseViewController {
    UITextView *prevTurnView;
    UITextView *inputView;
    
    SGAWSGame *game;
}

@property(nonatomic, retain) SGAWSGame *game;
@property(nonatomic, retain) IBOutlet UITextView *prevTurnView;
@property(nonatomic, retain) IBOutlet UITextView *inputView;

@end
