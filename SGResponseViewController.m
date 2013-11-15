//
//  SGResponseViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGResponseViewController.h"
#import "SGAppDelegate.h"
#import "SGGame.h"
#import "SGAWSGame.h"
#import "SVProgressHUD.h"
#import "SGAWSUtility.h"
#import "SGLocalDataUtility.h"

@implementation SGResponseViewController
@synthesize presentedParent;

-(void)sendGameToServer:(SGAWSGame *)game {
    self.view.userInteractionEnabled = NO;
    
    //START DEBUG
    
    /*
    [game retain];
    NSString *t = @"Test Game ";
    SGAWSGame *actualGame = (SGAWSGame *)game;
    for (NSUInteger i = 1; i <= 50; i++) {
        actualGame.name = [NSString stringWithFormat:@"%@%u", t, i];
        actualGame.url = [NSString stringWithFormat:@"%@/%@", game.name, [[NSDate date] description]];
        [SGAWSUtility pushGame:actualGame];
        sleep(1);
    }
    NSLog(@"Done with Uploads");
    [game release];
    */
     
    
    //END DEBUG
    [SVProgressHUD showWithStatus:@"Sending game to server..."];
    NSString *result = [SGAWSUtility pushGame:game];
    while (!result) {} //Hard Lock this thread
    if ([result isEqualToString:ERROR_ID]) {
        [SVProgressHUD dismissWithError:@"The game could not be uploaded." afterDelay:2.0];
    }
    else {
        SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.localDataUtility writeGameURL:game.url];
        [SVProgressHUD dismiss];
    }
    self.view.userInteractionEnabled = YES;
    if (self.presentedParent) {
        [self.presentedParent.presentingViewController dismissModalViewControllerAnimated:YES];
    }    
}

#pragma mark UIAlertViewDelegate

-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Does nothing; implemented to prevent callback errors to super
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //Does nothing; implemented to prevent callback errors to super
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Submit Move?" message:@"Would you like to submit this sentence?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = SEND_ALERT_VIEW_TAG;
        alert.delegate = self; //implemented in superclasses
        [alert show];
        [alert release];
        return FALSE;
    }
    if ([text isEqualToString:@""]) {
        //backspace allowed even if character limit hit
        return TRUE;
    }
    else if ([textView.text length] >= MAX_CHARACTER_LIMIT) {
        return FALSE;
    }
    return TRUE;
}

#pragma mark - Memory Management

-(void)dealloc {
    self.presentedParent = nil;
    [super dealloc];
}

@end
