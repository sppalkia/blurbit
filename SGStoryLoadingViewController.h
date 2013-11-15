//
//  SGStoryLoadingViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGLoadingViewController.h"
#import "SGAWSUtility.h"

@interface SGStoryLoadingViewController : SGLoadingViewController {
    SGStoryQuery query;
}

@property(nonatomic, retain) SGStoryQuery query;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil query:(SGStoryQuery)q;


@end
