//
//  SGViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/22/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGViewController.h"
#import "SGUserInfoViewController.h"
#import "SGParentGameViewController.h"
#import "SGPlayGameViewController.h"
#import "SGStoryRootViewController.h"
#import "SGGameListCell.h"
#import "SGTutorialViewController.h"

#import "SGAppDelegate.h"
#import "SGLocalDataUtility.h"

#import "SGGame.h"
#import "SGPlayer.h"
#import "SGAWSGame.h"
#import "SGAWSStory.h"
#import "SGTurn.h"
#import "SGAWSUtility.h"
#import "SGUserInfo.h"
#import "SVProgressHUD.h"

@implementation SGViewController
@synthesize gameListView;
@synthesize games;
@synthesize adView;

#define ROW_HEIGHT 70
#define kBannerOffset 50

#define NewGameTag      @"New Game"
#define ExistingGameTag @"Join Game"
#define FriendsGameTag  @"New Friends Game"
#define UpgradeTag      @"Upgrade to Full ($0.99)"
#define UserInfoTag     @"Your Info"
#define CertificatesTag @"Certificates"
#define RankingTag      @"Rankings"
#define GuideTag        @"View Guide"

//Alert View
#define InvalidUserNameTag @"Invalid Username"
#define UsernameAlertTag @"Welcome to Blurbit!"
#define UsernameAlertDone @"Done"
#define UsernameAlertAnon @"Anonymous"


#define kPlayGameActionSheetTag 10
#define kInfoActionSheetTag     20

#pragma mark - Thread Callbacks

-(void)pushUserInfo:(SGUserInfo *)userInfo {
    [SGAWSUtility pushUserInfo:userInfo];
}

#pragma mark - Selectors and Callbacks

-(void)showHelpImage {
    [SVProgressHUD dismiss];
    if (_helpImage) {
        if ([[self.navigationController.view subviews] containsObject:_helpImage]) {
            //the help image is already displayed
            return;
        }
        [_helpImage release];
    }
    _helpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpscreen.png"]];
    _helpImage.alpha = 0.0;
    _helpImage.frame = CGRectOffset(self.navigationController.view.frame, 0, 20);
    [_helpImage setNeedsDisplay];
    [self.navigationController.view addSubview:_helpImage];
    [self.navigationController.view setNeedsDisplay];
    
    self.gameListView.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    [_helpImage becomeFirstResponder];
    
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.7];
    _helpImage.alpha = 1.0;
    [UIView commitAnimations];

}

-(void)cleanUpHelpImageDismiss {
    [_helpImage removeFromSuperview];
    [_helpImage release];
    _helpImage = nil;
}

-(void)dismissHelpImage {
    if (!_helpImage) {
        _helpImage = nil;
        return;
    }
    if (![[self.navigationController.view subviews] containsObject:_helpImage]) {
        [_helpImage release];
        _helpImage = nil;
    }
    
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:0.3];
    _helpImage.alpha = 0.0;
    [UIView commitAnimations];
    
    self.gameListView.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [_helpImage resignFirstResponder];
    [self performSelector:@selector(cleanUpHelpImageDismiss) withObject:nil afterDelay:1.0];
}

-(void)processPurchase {
    //no ads in purchased version of Blurbit
    if (self.adView) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
}

-(void)composeButton {
    //NSString *purchased;
    //SGUserInfo *userInfo = [(SGAppDelegate *)[[UIApplication sharedApplication] delegate] userInfo];
    //if (userInfo.purchased) purchased = FriendsGameTag;
    //else purchased = UpgradeTag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Never Mind" 
                                               destructiveButtonTitle:nil otherButtonTitles:NewGameTag, ExistingGameTag, nil];
    actionSheet.tag = kPlayGameActionSheetTag;
    [actionSheet showInView:self.view];
    [actionSheet release];  
}

-(void)aboutButton {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Never Mind" 
                                               destructiveButtonTitle:nil otherButtonTitles: UserInfoTag, GuideTag, CertificatesTag, RankingTag, nil];
    actionSheet.tag = kInfoActionSheetTag;
    [actionSheet showInView:self.view];
    [actionSheet release];  
}

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

-(void)showStoryViewButton {
    SGStoryRootViewController *controller = [[SGStoryRootViewController alloc] initWithNibName:@"SGStoryRootViewController" bundle:nil];
    [self presentViewController:controller animated:YES completion:nil];
    [controller release];
}

-(void)loadGamesAnimated:(BOOL)animated {
    //Prevents Spam of this button, which will cause 
    //unneccesary requests and charges.
    
    if (!shouldUpdate) {
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"No new updates" afterDelay:1.0];
        return;
    }
    
    if (animated) {
        [SVProgressHUD showWithStatus:@"Loading Games from the Server..." networkIndicator:YES];
    }
    
    NSMutableArray *preloadGames;
    if (self.games) {
        preloadGames = [self.games retain];
    }
    else {
        preloadGames = [[NSMutableArray alloc] init];
    }
    NSMutableArray *tmpGames = nil;
    SGUserInfo *info;
    
    SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    /******** TODO ********
     Make a SGUserInviteList
     object and fetch it to
     recieve a list of URLs.
     Add these urls to the 
     local data utility.
     These urls represent
     invites from friends and
     are dynamically added to 
     your game list.
     
     SGUserInviteList objects
     are readonly to invitees
     and readwrite to inviters.
     **********************/
    
    info = [SGAWSUtility fetchUserInfo:nil];
    while (!info) {}
    if (![[info uuid] isEqualToString:ERROR_ID]) {
        delegate.userInfo = info;
    }
    
    tmpGames = [SGAWSUtility fetchGamesWithURLs:[delegate.localDataUtility getGameURLs]];
    while (!tmpGames) {}
    if ([tmpGames count] > 0 && [tmpGames objectAtIndex:0] == ERROR_ID) {
        if (animated) {
            [SVProgressHUD dismissWithError:@"A network connection could not be established." afterDelay:2.0];
            shouldUpdate = YES;
        }
    }
    else if ([tmpGames count] == 0) {
        if (animated) {
            [SVProgressHUD dismissWithError:@"You're not in any games right now. Tap the Pencil to join a game!" afterDelay:2.0];
            shouldUpdate = NO;
        }
    }
    else {
        shouldUpdate = NO;
        
        //add a story if the story has not been written once already.
        for (int i = 0; i < [tmpGames count]; i++) {
            SGAWSGame *game = [tmpGames objectAtIndex:i];
            NSString *datestr = [game dateString];
            BOOL addStory = YES;
            if (!game.gameOver) {
                continue;
            }
            
            for (int j = 0; j < [preloadGames count]; j++) {
                NSString *datestr2 = [(SGAWSGame *)[preloadGames objectAtIndex:j] dateString];
                if ([datestr isEqualToString:datestr2]) {
                    addStory = NO;
                    break;
                }
            }
            if (addStory) {
                [delegate.localDataUtility writeStoryURL:game.url];
            }
        }
        self.games = [NSMutableArray arrayWithArray:tmpGames];
        
        if (animated) {
            [SVProgressHUD dismiss];
        }
    }
    
    //just a sanity check
    if (!self.games) {
        self.games = [NSMutableArray array]; 
    }
    
    [preloadGames release];
    [self.gameListView reloadData];
    
}

#pragma mark - UIResponder Methods

- (BOOL)canBecomeFirstResponder { 
    return YES; 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_helpImage) {
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInView:_helpImage];
        if ([_helpImage pointInside:position withEvent:event]) {
            [self dismissHelpImage];
        }
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self showHelpImage];
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    shouldUpdate = YES;
    firstTimeViewing = YES;
    showHelpOnViewAppear = NO;
    
    SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    adView.frame = CGRectOffset(self.adView.frame, 0, kBannerOffset);
    _bannerIsVisible = NO;
    
    if (delegate.userInfo.purchased) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    
    CGSize contentSize = self.gameListView.contentSize;
    self.gameListView.contentSize = CGSizeMake(contentSize.width, contentSize.height+44);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [UIBezierPath bezierPathWithRect:self.gameListView.bounds].CGPath;
    shapeLayer.masksToBounds = NO;
    shapeLayer.shadowPath = [UIBezierPath bezierPathWithRect:self.gameListView.bounds].CGPath;   
    shapeLayer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    shapeLayer.shadowColor = [UIColor blackColor].CGColor;
    shapeLayer.shadowOpacity = 1.0f;
    shapeLayer.shadowRadius = 5.0f;
    shapeLayer.position = self.gameListView.frame.origin;
    [self.view.layer insertSublayer:shapeLayer below:self.gameListView.layer];
    
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:RGBA_BAR_COLORS[0] 
                                                                        green:RGBA_BAR_COLORS[1] 
                                                                         blue:RGBA_BAR_COLORS[2] 
                                                                        alpha:RGBA_BAR_COLORS[3]];
    
    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame = CGRectMake(0, 0, 100, 30); //Size of the Image
    logoButton.showsTouchWhenHighlighted = YES;
    logoButton.adjustsImageWhenHighlighted = NO;
    [logoButton setImage:[UIImage imageNamed:@"logo.png"] forState:UIControlStateNormal];
    [logoButton addTarget:self action:@selector(aboutButton) forControlEvents:UIControlEventTouchUpInside];    
    
    UIBarButtonItem *logo = [[UIBarButtonItem alloc] initWithCustomView:logoButton];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pencil.png"] 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(composeButton)];
    
    UIBarButtonItem *storiesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks 
                                                                                   target:self 
                                                                                   action:@selector(showStoryViewButton)];
    
    [self.navigationController.navigationBar.topItem setLeftBarButtonItems:[NSArray arrayWithObjects:storiesButton, space, logo, space, composeButton, nil]];
    
    [logo release];
    [space release];
    [composeButton release];
    [storiesButton release];
    
    self.games = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated {
    shouldUpdate = YES;
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.firstRun) {
        showHelpOnViewAppear = YES;
        [self showSetUsernameAlert];
        delegate.firstRun = NO;
        
        /*
         On 1.1 update, on FRE, ask if 
         user already has an account. If not, create one 
         here. This should be done on updated apps as well.
         
         If account exists, login and pull userInfo.
         */
    }
    else if (showHelpOnViewAppear) {
        showHelpOnViewAppear = NO;
        [self showHelpImage];
    }
    else if (firstTimeViewing) {
        shouldUpdate = YES;
        [self loadGamesAnimated:YES];
    }
    
    firstTimeViewing = NO;
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [self dismissHelpImage];
    [SVProgressHUD dismiss];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.gameListView = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (actionSheet.tag == kPlayGameActionSheetTag) {
        if ([title isEqualToString:NewGameTag]) {
            SGParentGameViewController *controller = [[SGParentGameViewController alloc] initWithNibName:@"SGParentGameViewController" bundle:nil root:kGameStateNew];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }
        else if ([title isEqualToString:ExistingGameTag]) {
            SGParentGameViewController *controller = [[SGParentGameViewController alloc] initWithNibName:@"SGParentGameViewController" bundle:nil root:kGameStateExisting];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }
    }
    else if (actionSheet.tag == kInfoActionSheetTag) {
        if ([title isEqualToString:UserInfoTag]) {
            SGUserInfoViewController *controller = [[SGUserInfoViewController alloc] initWithNibName:@"SGUserInfoViewController" bundle:nil];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }
        else if ([title isEqualToString:RankingTag]) {
            [SVProgressHUD dismiss];
            [SVProgressHUD show];
            [SVProgressHUD dismissWithError:@"Rankings will be available soon!" afterDelay:2.0];
        }
        else if ([title isEqualToString:CertificatesTag]) {
            [SVProgressHUD dismiss];
            [SVProgressHUD show];
            [SVProgressHUD dismissWithError:@"Certificates will be issued soon!" afterDelay:2.0];
        }
        else if ([title isEqualToString:GuideTag]) {
            SGTutorialViewController *controller = [[SGTutorialViewController alloc] initWithNibName:@"SGTutorialViewController" bundle:nil];
            [self presentViewController:controller animated:YES completion:nil];
            [controller release];
        }
    }
}

#pragma mark - Table View Data Source + Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [self.games count] + 1;
    else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SGGameListCell";
    static NSString *LastCellIdentifier = @"Cell";
    static NSString *DummyCellIdentifier = @"Dummy";
    if ([indexPath section] == 0) {
        
        if ([indexPath row] == [self.games count]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LastCellIdentifier] autorelease];
            }
            cell.textLabel.text = @"            Reload Games...";
            cell.detailTextLabel.text = @"        Update your Game and Story list.";
            return cell;
        }
        
        SGGameListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SGGameListCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SGGameListCell *)view;
                }
            }
        }
        
        [cell prepareForReuse];
        SGGame *game = [self.games objectAtIndex:[indexPath row]];
        [cell setInfoForGame:game];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DummyCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DummyCellIdentifier] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"";
        return cell;
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return ROW_HEIGHT;
    }
    else {
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([indexPath section] == 0) {
        if ([indexPath row] == [self.games count]) {
            [self loadGamesAnimated:YES];
        }
        else {
            [SVProgressHUD dismiss];
            SGAWSGame *game = [self.games objectAtIndex:[indexPath row]];
            NSString *title = game.name;
            NSString *turns = [NSString stringWithFormat:@"%d/%d turns played", [game.turns count], game.numberOfTurns];
            NSString *displayString = [NSString stringWithFormat:@"%@ \n \n %@", title, turns];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD dismissWithSuccess:displayString afterDelay:3.0];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        if ([indexPath row] >= [self.games count])
            return;
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            SGAWSGame *game = [[self.games objectAtIndex:[indexPath row]] retain];
            NSString *url = game.url;
            
            SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.localDataUtility removeGameURL:url];
            
            [self.games removeObjectAtIndex:[indexPath row]];
            [game release];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }   
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView title] isEqualToString:UsernameAlertTag]) {
        SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
        SGUserInfo *info = delegate.userInfo;
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:UsernameAlertDone]) {
            UITextField *field = [alertView textFieldAtIndex:0];
            if (![field.text isEqualToString:@""]) {
                info.username = field.text;
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
            info.username = @"Anonymous";
        }
        showHelpOnViewAppear = YES;
        [NSThread detachNewThreadSelector:@selector(pushUserInfo:) toTarget:self withObject:info];
        SGTutorialViewController *controller = [[SGTutorialViewController alloc] initWithNibName:@"SGTutorialViewController" bundle:nil];
        [self presentViewController:controller animated:YES completion:nil];
        [controller release];
    }
    else if ([[alertView title] isEqualToString:InvalidUserNameTag]) {
        [self showSetUsernameAlert];
    }
}

#pragma mark - ADBannerViewDelegate + Banner Hide and Show

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
	if (!_bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        //move up
		banner.frame = CGRectOffset(banner.frame, 0, -kBannerOffset);
        [UIView commitAnimations];
        _bannerIsVisible = YES;
    }
     
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    if (_bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        //move down
        banner.frame = CGRectOffset(banner.frame, 0, kBannerOffset);
        [UIView commitAnimations];
        _bannerIsVisible = NO;
    }
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if (_helpImage)
        [_helpImage release];
    self.adView = nil;
    self.games = nil;
    self.gameListView = nil;
    [super dealloc];
}

@end
