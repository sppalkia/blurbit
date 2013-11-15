//
//  SGStoriesViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGAWSUtility.h"

@interface SGStoriesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *stories;
    UITableView *listView;
    SGStoryQuery query;
    
    UIViewController *presentingParent;
    
    BOOL _doneLoadingStories;
    
    NSError *_error;
}

@property(nonatomic, retain) NSMutableArray *stories;
@property(nonatomic, retain) IBOutlet UITableView *listView;
@property(nonatomic, retain) SGStoryQuery query;

@property(nonatomic, retain) UIViewController *presentedParent;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil query:(SGStoryQuery)q error:(NSError *)error;

@end
