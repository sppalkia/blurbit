//
//  SGStoryRootViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSavedTabBarIndex = 0,
    kTopTabBarIndex = 1,
    kNewestTabBarIndex = 2,
} kTabBarIndex;

@interface SGStoryRootViewController : UIViewController <UITabBarControllerDelegate> {
    UITabBarController *tabController;
}

@property(nonatomic, retain) NSMutableArray *stories;
@property(nonatomic, retain) IBOutlet UITabBarController *tabController;


@end
