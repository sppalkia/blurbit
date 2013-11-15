//
//  SGUserInfoViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGUserInfo;
@interface SGUserInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    NSDictionary *_data;
}

@property(nonatomic, retain) SGUserInfo *userInfo;
@property(nonatomic, retain) IBOutlet UITableView *infoView;

-(IBAction)back;
-(IBAction)friends;

@end
