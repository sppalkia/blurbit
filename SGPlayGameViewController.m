//
//  SGPlayGameViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGPlayGameViewController.h"
#import "SGAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#import "SGLocalDataUtility.h"
#import "SGAWSUtility.h"
#import "SGUserInfo.h"


#import "SGGame.h"
#import "SGTurn.h"
#import "SGPlayer.h"
#import "SGAWSGame.h"
#import "SGAWSStory.h"
#import "SGRulebook.h"
#import "SGGameLoadingViewController.h"

@implementation SGPlayGameViewController
@synthesize prevTurnView;
@synthesize inputView;
@synthesize game;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputView.layer.masksToBounds = NO;
    self.inputView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.inputView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.inputView.layer.shadowOpacity = 1.0f;
    self.inputView.layer.shadowRadius = 5.0f;
    self.inputView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.inputView.bounds].CGPath;
    self.inputView.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.inputView.autocapitalizationType = UITextAutocapitalizationTypeNone;

    self.prevTurnView.layer.masksToBounds = NO;
    self.prevTurnView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.prevTurnView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.prevTurnView.layer.shadowOpacity = 1.0f;
    self.prevTurnView.layer.shadowRadius = 5.0f;
    self.prevTurnView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.inputView.bounds].CGPath;
    
    self.navigationController.navigationBar.topItem.title = @"Blurbit!";
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.prevTurnView.text = self.game.previousTurn.playString;
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    if ([self.game.turns count] == self.game.numberOfTurns-1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're the Last One!" 
                                                        message:@"Finish this blurb off with a bang!" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Okay!" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self.inputView becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.prevTurnView = nil;
    self.inputView = nil;
    [super dealloc];
}

-(void)dealloc {
    self.game = nil;
    self.prevTurnView = nil;
    self.inputView = nil;
    [super dealloc];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
        BOOL submit = [self.game submitMove:textView.text withPlayer:delegate.userInfo.player];
        if (!submit) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Sentence!" 
                                                            message:self.game.rulebook.errorString 
                                                           delegate:nil cancelButtonTitle:@"Okay" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return NO;
        }
    }
    
    //Submit move prompt, character limits, etc.
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SEND_ALERT_VIEW_TAG) {
        if (buttonIndex == 1) {
            SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
            SGUserInfo *userInfo = delegate.userInfo;
            userInfo.gamesPlayed++;
            userInfo.points += kPlayPointValue;
            [SGAWSUtility pushUserInfo:userInfo];
            [self sendGameToServer:self.game];
            if (self.game.gameOver) {
                SGAWSStory *story = [[SGAWSStory alloc] initWithTurns:self.game.turns title:self.game.name url:game.url];
                NSString *storyResponse = nil;
                storyResponse = [SGAWSUtility pushStory:story];
                while (!storyResponse) {}
                if (![storyResponse isEqualToString:ERROR_ID]) {
                    [delegate.localDataUtility writeStoryURL:story.url];
                }
                [story release];
            }
            NSArray *controllers = [self.navigationController viewControllers];
            SGGameLoadingViewController *parent = (SGGameLoadingViewController *)[controllers objectAtIndex:0];
            [parent.presentedParent dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}

@end
