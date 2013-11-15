//
//  SGStoryLoadingViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStoryLoadingViewController.h"
#import "SGAppDelegate.h"
#import "SGLocalDataUtility.h"
#import "SGStoriesViewController.h"

@implementation SGStoryLoadingViewController
@synthesize query;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil query:(SGStoryQuery)q {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.query = q;
    }
    return self;
}

-(void)performLoad {
    [SGAWSUtility resetQuery];
    NSMutableArray *stories = nil;
    NSError *error = nil;
    if ([self.query isEqualToString:LOCAL_QUERY]) {
        SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
        SGLocalDataUtility *utility = delegate.localDataUtility;
        NSArray *urls = [utility getStoryURLs];
        stories = [SGAWSUtility fetchStoriesWithURLs:urls];
        while (!stories) {}
    }
    else {
        stories = [SGAWSUtility fetchStoriesByQuery:self.query];
        while (!stories) {}
    }
    
    if ([stories count] > 0 && [stories objectAtIndex:0] == ERROR_ID) {
        stories = [NSMutableArray array];
        error = [NSError errorWithDomain:@"Network Error" code:NETWORK_ERROR userInfo:nil];
    }
    SGStoriesViewController *controller = [[SGStoriesViewController alloc] initWithNibName:@"SGStoriesViewController"
                                                                                    bundle:nil
                                                                                     query:self.query
                                                                                     error:error];
    controller.presentedParent = self.presentedParent;
    controller.stories = stories;
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
    
}


-(void)dealloc {
    [super dealloc];
    self.query = nil;
}
@end
