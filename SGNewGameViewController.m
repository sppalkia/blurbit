//
//  SGNewGameViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGNewGameViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "SGLocalDataUtility.h"
#import "SGAppDelegate.h"
#import "SGAWSUtility.h"

#import "SGPlayer.h"
#import "SGTurn.h"
#import "SGAWSGame.h"
#import "SGUserInfo.h"

#import "SGRulebook.h"

@implementation SGNewGameViewController
@synthesize inputView;
@synthesize gameNameField;

#define INVALID_TITLE_ALERT_TAG     3894
#define TEXTFIELD_DONE_PRESSED      3798


#pragma mark - Selectors

-(void)back {
    [self.presentedParent.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Create a New Game";
    self.inputView.delegate = self;
    self.gameNameField.delegate = self;
    
    self.inputView.layer.masksToBounds = NO;
    self.inputView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.inputView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.inputView.layer.shadowOpacity = 1.0f;
    self.inputView.layer.shadowRadius = 5.0f;
    self.inputView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.inputView.bounds].CGPath;
    self.inputView.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.inputView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.gameNameField.text = @"";
    self.gameNameField.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.gameNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

-(void)viewDidAppear:(BOOL)animated {
    [self.gameNameField becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    self.inputView = nil;
    self.gameNameField = nil;
    [super viewDidUnload];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == INVALID_TITLE_ALERT_TAG) {
        [self.gameNameField becomeFirstResponder];
    }
    else if (alertView.tag == SEND_ALERT_VIEW_TAG) {
        if (buttonIndex == 1) {
            NSString *title = self.gameNameField.text;
            SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *uuid = [delegate.userInfo uuid];
            SGPlayer *me = delegate.userInfo.player;
            SGAWSGame *game = [[SGAWSGame alloc] initWithName:title playersOrNil:[NSArray arrayWithObject:me] uniqueCreatorID:uuid];
            
            SGUserInfo *userInfo = nil;
            userInfo = [SGAWSUtility fetchUserInfo:nil];
            while (!userInfo) {}
            if ([[userInfo uuid] isEqualToString:ERROR_ID]) {
                delegate.userInfo = userInfo;
            }

            delegate.userInfo.gamesCreated++;
            delegate.userInfo.points += kNewGamePointValue;
            [SGAWSUtility pushUserInfo:delegate.userInfo];
            
            //Add the data to game. Does a redundant rulebook check (so always TRUE)
            [game submitMove:self.inputView.text]; 
            [self sendGameToServer:game];
            [game release];
        }
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) { //Done button pressed
        NSUInteger length = [self.gameNameField.text length];
        if (length < 5 || length > 20) {
            UIAlertView *titleAlert = [[UIAlertView alloc] initWithTitle:@"Choose a Valid Title" message:@"A valid title is between 5 and 20 characters long." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            titleAlert.tag = INVALID_TITLE_ALERT_TAG;
            titleAlert.delegate = self;
            [titleAlert show];
            [titleAlert release];
            [textView resignFirstResponder];
            return NO;
        }
        else {
            SGRulebook *rulebook = [[[SGRulebook alloc] init] autorelease];
            if ([SGRulebook producedError:[rulebook applyRules:textView.text]]) {
                UIAlertView *moveAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Sentence!" message:rulebook.errorString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [moveAlert show];
                [moveAlert release];
                return NO;
            }
        }
    }
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.inputView becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.tag = TEXTFIELD_DONE_PRESSED;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Memory Management

-(void)dealloc {
    self.inputView = nil;
    self.gameNameField = nil;
    [super dealloc];
}

@end
