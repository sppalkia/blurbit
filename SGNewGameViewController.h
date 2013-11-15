//
//  SGNewGameViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGResponseViewController.h"

@interface SGNewGameViewController : SGResponseViewController <UITextFieldDelegate> {
    UITextView *inputView;
    UITextField *gameNameField;
}

@property(nonatomic, retain) IBOutlet UITextView *inputView;
@property(nonatomic, retain) IBOutlet UITextField *gameNameField;

@end
