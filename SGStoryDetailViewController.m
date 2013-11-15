//
//  SGStoryDetailViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStoryDetailViewController.h"
#import "SGAppDelegate.h"
#import "SGLocalDataUtility.h"
#import "SGFullStoryCell.h"
#import "SGStoryDetailCell.h"
#import "SGTurnDetailCell.h"
#import "SGAWSStory.h"
#import "SGTurn.h"
#import "SGPlayer.h"
#import "SVProgressHUD.h"
#import "SGUserInfo.h"
#import "SGAWSUtility.h"
#import "Constants.h"
#import "FBConnect.h"

@implementation SGStoryDetailViewController
@synthesize storyDetailView;
@synthesize story;
@synthesize inSaveView;

#define kActionSheetSaveTag     10
#define FacebookAlertTag        20

NSString * const kFacebookTag = @"Post to Facebook";
NSString * const kEmailTag = @"Email Story";
NSString * const kSaveTag = @"Save Story";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil story:(SGAWSStory *)st
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.story = st;
        self.inSaveView = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil story:(SGAWSStory *)st inSaveView:(BOOL)flag
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.story = st;
        self.inSaveView = flag;
    }
    return self;
}

#pragma mark - Selectors

-(void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:self.story.title];        
        [mailer setMessageBody:self.story.storyString isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
        [mailer release];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" 
                                                        message:@"This device doesn't support email yet." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Okay" 
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

-(void)push:(SGAWSStory *)aStory {
    [aStory retain];
    [SGAWSUtility pushStory:aStory];
    BOOL givePoints = upvoted && (aStory.upvotes%kUpvotesNeededForPoints == 5);
    BOOL losePoints = downvoted && (aStory.downvotes%kDownvotesNeededForPoints == 5);
    BOOL modifyInfo = givePoints || losePoints;
    
    if (modifyInfo) {
        SGPlayer *creator = [[aStory.turns objectAtIndex:0] player];
        SGUserInfo *info = [SGAWSUtility fetchUserInfo:[creator idNumber]];
        [creator retain];
        [info retain];
        while (!info) {}
        if ([info.uuid isEqualToString:ERROR_ID]) {
            [creator release];
            [info release];
            return;
        }
        if (givePoints) {
            info.points += kUpvotePointValue;
        }
        else if (losePoints) {
            info.points += kDownvotePointValue;
        }
        [SGAWSUtility pushUserInfo:info];
        [info release];
        [creator release];
    }
    [aStory release];
}

-(void)save {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                             delegate:self
                                                    cancelButtonTitle:@"Never Mind"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:kFacebookTag, kEmailTag, kSaveTag, nil];
    actionSheet.actionSheetStyle =  UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = kActionSheetSaveTag;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];    
}

-(void)upvote {
    if(upvoted) {
        self.story.upvotes--;
        upvoted = NO;
        downvoted = NO;
    }
    else if(downvoted) {
        //"if downvoted, change to upvote"
        self.story.downvotes--;
        self.story.upvotes++;
        upvoted = YES;
        downvoted = NO;
    }
    else {
        self.story.upvotes++;
        upvoted = YES;
        downvoted = NO;
    }
    
    [downvoteUIButton setImage:[UIImage imageNamed:@"downvote.png"] forState:UIControlStateNormal];
    if (upvoted)
        [upvoteUIButton setImage:[UIImage imageNamed:@"upvote_selected.png"] forState:UIControlStateNormal];
    else
         [upvoteUIButton setImage:[UIImage imageNamed:@"upvote.png"] forState:UIControlStateNormal];
    
    [self.storyDetailView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)downvote {
    if(upvoted) {
        self.story.upvotes--;
        self.story.downvotes++;
        downvoted = YES;
        upvoted = NO;
    }
    else if (downvoted) {
        self.story.downvotes--;
        downvoted = NO;
        upvoted = NO;
    }
    else {
        self.story.downvotes++;
        downvoted = YES;
        upvoted = NO;
    }
    
    [upvoteUIButton setImage:[UIImage imageNamed:@"upvote.png"] forState:UIControlStateNormal];
    
    if (downvoted)
        [downvoteUIButton setImage:[UIImage imageNamed:@"downvote_selected.png"] forState:UIControlStateNormal];
    else
        [downvoteUIButton setImage:[UIImage imageNamed:@"downvote.png"] forState:UIControlStateNormal];

    [self.storyDetailView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    downvoted = NO;
    upvoted = NO;
    didSave = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    upvoteUIButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    upvoteUIButton.frame = CGRectMake(0, 0, 24, 24); //Size of the Image
    upvoteUIButton.showsTouchWhenHighlighted = YES;
    upvoteUIButton.adjustsImageWhenHighlighted = NO;
    [upvoteUIButton setImage:[UIImage imageNamed:@"upvote.png"] forState:UIControlStateNormal];
    [upvoteUIButton addTarget:self action:@selector(upvote) forControlEvents:UIControlEventTouchUpInside];    
    
    UIBarButtonItem *upvoteButton = [[UIBarButtonItem alloc] initWithCustomView:upvoteUIButton];
    
    downvoteUIButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    downvoteUIButton.frame = CGRectMake(0, 0, 24, 24); //Size of the Image
    downvoteUIButton.showsTouchWhenHighlighted = YES;
    downvoteUIButton.adjustsImageWhenHighlighted = NO;
    [downvoteUIButton setImage:[UIImage imageNamed:@"downvote.png"] forState:UIControlStateNormal];
    [downvoteUIButton addTarget:self action:@selector(downvote) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *downvoteButton = [[UIBarButtonItem alloc] initWithCustomView:downvoteUIButton];
    
    if (!self.inSaveView) {
        saveUIButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        saveUIButton.frame = CGRectMake(0, 0, 24, 24); //Size of the Image
        saveUIButton.showsTouchWhenHighlighted = YES;
        saveUIButton.adjustsImageWhenHighlighted = NO;
        [saveUIButton setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
        [saveUIButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:saveUIButton];
        self.navigationController.navigationBar.topItem.rightBarButtonItems = [NSArray arrayWithObjects:upvoteButton, downvoteButton, saveButton, nil];
        [saveButton release];
    }
    else {
        self.navigationController.navigationBar.topItem.rightBarButtonItems = [NSArray arrayWithObjects:upvoteButton, downvoteButton, nil];
    }

    [upvoteButton release];
    [downvoteButton release];

}

-(void)viewWillDisappear:(BOOL)animated {
    if (upvoted || downvoted) {
        [NSThread detachNewThreadSelector:@selector(push:) toTarget:self withObject:self.story];
    }
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];

}

#pragma mark - Table View Data Source + Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) return 1;
    return [self.story.turns count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FullStoryCellIdentifier = @"SGFullStoryCell";
    static NSString *TurnDetailCellIdentifier = @"SGTurnDetailCell";
    static NSString *StoryDetailCellIdentifier = @"SGStoryDetailCell";
    
    if ([indexPath section] == 0) {
        SGStoryDetailCell *cell = (SGStoryDetailCell *)[tableView dequeueReusableCellWithIdentifier:StoryDetailCellIdentifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SGStoryDetailCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SGStoryDetailCell *)view;
                }
            }
        }
        [cell setStory:self.story];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;

    }
    else if ([indexPath section] == 1) {
        SGFullStoryCell *cell = (SGFullStoryCell *)[tableView dequeueReusableCellWithIdentifier:FullStoryCellIdentifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SGFullStoryCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SGFullStoryCell *)view;
                }
            }
        }
        [cell setStory:self.story];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        SGTurnDetailCell *cell = (SGTurnDetailCell *)[tableView dequeueReusableCellWithIdentifier:TurnDetailCellIdentifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SGTurnDetailCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SGTurnDetailCell *)view;
                }
            }
        }
        //setup cell
        [cell setTurn:[self.story.turns objectAtIndex:[indexPath row]]];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return 80;
    }
    else if ([indexPath section] == 1) {
        return 250;
    }
    else {
        return 100;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetSaveTag) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kSaveTag]) {
            if (didSave) {
                return;
            }
            SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
            SGLocalDataUtility *saveUtility = delegate.localDataUtility;
            [saveUtility writeStoryURL:story.url];
            didSave = YES;
            [SVProgressHUD dismiss];
            [SVProgressHUD show];
            [SVProgressHUD dismissWithSuccess:@"This story has been saved to your \"Saved\" List." afterDelay:1.5];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kEmailTag]) {
            [self sendEmail];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kFacebookTag]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post on Facebook?"
                                                            message:@"Would you like to publish this story on your News Feed?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Okay", nil];
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - UIAlertViewDelegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag = FacebookAlertTag) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Okay"]) {
            SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (!delegate.facebook) {
                [delegate startFacebook];
            }

            NSString *postString = [NSString stringWithFormat:@"%@ \n %@ \n \n This Story was created in Blurbit!", 
                                    self.story.title, self.story.storyString];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           postString, @"message",
                                           nil];
            
            [delegate.facebook requestWithGraphPath:@"/me/feed" andParams:params
                                      andHttpMethod:@"POST" andDelegate:nil];
        }
    }
}

#pragma mark - MFMailComposeController delegate


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error  {	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
    void (^completion)(void) = ^(void) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
	[self dismissViewControllerAnimated:YES completion:completion];
}


#pragma mark - Memory Management

-(void)dealloc {
    [saveUIButton release];
    [upvoteUIButton release];
    [downvoteUIButton release];
    self.storyDetailView = nil;
    self.story = nil;
    [super dealloc];
}


@end
