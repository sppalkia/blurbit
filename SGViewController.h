//
//  SGViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 1/22/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "iAd/iAd.h"

@interface SGViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ADBannerViewDelegate, UIAlertViewDelegate> {
    UITableView *gameListView;
    
    NSMutableArray *games;
    
    BOOL shouldUpdate, firstTimeViewing, showHelpOnViewAppear;
    
    ADBannerView *adView;
    BOOL _bannerIsVisible;
    
    UIImageView *_helpImage;
}

@property(nonatomic, retain) IBOutlet UITableView *gameListView;
@property(nonatomic, retain) NSMutableArray *games;
@property(nonatomic, retain) IBOutlet ADBannerView *adView;

@end
