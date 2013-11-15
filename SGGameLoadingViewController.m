//
//  SGGameLoadingViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGGameLoadingViewController.h"
#import "SGAppDelegate.h"
#import "SGAWSUtility.h"
#import "SGLocalDataUtility.h"
#import "SGAWSGame.h"
#import "SGUserInfo.h"
#import "SGListGamesViewController.h"

@implementation SGGameLoadingViewController

-(void)performLoad {
    SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error = nil;
    SGUserInfo *updatedInfo = nil;    
    NSMutableArray *games = nil;
    games = [SGAWSUtility fetchGames];
    updatedInfo = [SGAWSUtility fetchUserInfo:nil];
    while (updatedInfo == nil && games == nil) {}
    
    if (![[updatedInfo uuid] isEqualToString:ERROR_ID]) {
        delegate.userInfo = updatedInfo;
    }
    
    if ([games count] > 0 && [games objectAtIndex:0] == ERROR_ID) {
        [self.presentedParent.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        error = [NSError errorWithDomain:@"Network Error" code:NETWORK_ERROR userInfo:nil];
        return;
    }
    
    for (int i = 0; i < [games count]; i++) {
        SGAWSGame *game = [games objectAtIndex:i];
        if (game.gameOver) {
            [games removeObjectAtIndex:i];
            i--;
        }
    }
    
    SGListGamesViewController *controller = [[SGListGamesViewController alloc] initWithNibName:@"SGListGamesViewController" 
                                                                                        bundle:nil 
                                                                                      gameList:games
                                                                                         error:error];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
    
    if (finished) {
        [self.presentedParent.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
