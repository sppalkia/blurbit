//
//  SGUserInfoViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGUserInfoViewController.h"
#import "SGInfoViewController.h"
#import "SGAppDelegate.h"
#import "SVProgressHUD.h"
#import "SGUserInfo.h"
#import "SGAWSUtility.h"
#import "SGPlayer.h"

@implementation SGUserInfoViewController
@synthesize infoView;
@synthesize userInfo;

//Alert View
#define InvalidUserNameTag @"Invalid Username"
#define UsernameAlertTag @"Choose a Username"
#define UsernameAlertDone @"Done"
#define UsernameAlertAnon @"Anonymous"
#define UsernameAlertCancel @"Cancel"

-(void)showSetUsernameAlert {
    UIAlertView *setUNView = [[UIAlertView alloc] initWithTitle:UsernameAlertTag
                                                        message:@"Pick a username or choose to remain anonymous."
                                                       delegate:self
                                              cancelButtonTitle:UsernameAlertAnon
                                              otherButtonTitles:UsernameAlertDone, nil];
    setUNView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [setUNView show];
    [setUNView release];
}


-(IBAction)back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)friends {
    [self showSetUsernameAlert];
}

-(void)viewDidLoad {
    self.infoView.scrollEnabled = NO;
    SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.userInfo = delegate.userInfo;
    SGPlayer *player = self.userInfo.player;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterNoStyle];
    NSString *date = [dateFormat stringFromDate:self.userInfo.playerSince];
    [dateFormat release];
    
    NSArray *nameArray = [NSArray arrayWithObjects:player.name, date, nil];
    NSArray *nameKeys = [NSArray arrayWithObjects:@"Player Name", @"Player Since", nil];
    NSDictionary *namesDictionary = [NSDictionary dictionaryWithObjects:nameArray forKeys:nameKeys];
    
    NSString *upstr = [NSString stringWithFormat:@"%d", self.userInfo.points]; //self.userInfo.points
    NSString *downstr = [NSString stringWithFormat:@"%@", @"n/a"]; //self.userInfo.ranking
    NSString *votesstr = [NSString stringWithFormat:@"%d", 0];
    NSArray *voteArray = [NSArray arrayWithObjects:upstr, downstr, votesstr, nil];
    NSArray *voteKeys = [NSArray arrayWithObjects:@"Points", @"Ranking", @"Certificates", nil];
    NSDictionary *votesDictionary = [NSDictionary dictionaryWithObjects:voteArray forKeys:voteKeys];

    NSString *played = [NSString stringWithFormat:@"%d", self.userInfo.gamesPlayed];
    NSString *created = [NSString stringWithFormat:@"%d", self.userInfo.gamesCreated];
    NSString *contributions = [NSString stringWithFormat:@"%d", self.userInfo.contributions];
    NSArray *gameArray = [NSArray arrayWithObjects:played, created, contributions, nil];
    NSArray *gameKeys = [NSArray arrayWithObjects:@"Games Played", @"Games Created", @"Contributions", nil];
    NSDictionary *gamesDictionary = [NSDictionary dictionaryWithObjects:gameArray forKeys:gameKeys];
    
    NSArray *finalData = [NSArray arrayWithObjects:namesDictionary, votesDictionary, gamesDictionary, nil];
    NSArray *finalKeys = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                                    [NSNumber numberWithInt:1],
                                                    [NSNumber numberWithInt:2], nil];
    _data = [[NSDictionary alloc] initWithObjects:finalData forKeys:finalKeys];

}

-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_data objectForKey:[NSNumber numberWithInt:section]] allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *info = [_data objectForKey:[NSNumber numberWithInt:[indexPath section]]];
    NSArray *keys = [info allKeys];
    
    NSInteger i = [indexPath row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [keys objectAtIndex:i];
    cell.detailTextLabel.text = [info objectForKey:[keys objectAtIndex:i]];
    return cell;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView title] isEqualToString:UsernameAlertTag]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:UsernameAlertDone]) {
            UITextField *field = [alertView textFieldAtIndex:0];
            if (![field.text isEqualToString:@""]) {
                self.userInfo.username = field.text;
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:InvalidUserNameTag 
                                                                message:@"Please choose a valid username, or remain anonymous." 
                                                               delegate:self 
                                                      cancelButtonTitle:@"Okay" 
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
        }
        else {
            self.userInfo.username = @"Anonymous";
        }
        
        [SVProgressHUD showWithStatus:@"Updating your Info..."];
        NSString *callback = nil;
        callback = [SGAWSUtility pushUserInfo:self.userInfo];
        while (!callback) {}
        if ([callback isEqualToString:ERROR_ID]) {
            [SVProgressHUD dismissWithError:@"Info could not be updated. Check network connection." afterDelay:2.5];
        }
        else {
            [SVProgressHUD dismiss];
        }
    }
    else if ([[alertView title] isEqualToString:InvalidUserNameTag]) {
        [self showSetUsernameAlert];
    }
}



-(void)dealloc {
    self.userInfo = nil;
    self.infoView = nil;
    [_data release];
    [super dealloc];
}

@end
