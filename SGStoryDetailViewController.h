//
//  SGStoryDetailViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class SGAWSStory;
@interface SGStoryDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
                                                    UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>{
    UITableView *storyDetailView;
    SGAWSStory *story;
    
    BOOL downvoted, upvoted;
    BOOL inSaveView;
    BOOL didSave;
                                                        
    @private
    UIButton *upvoteUIButton;
    UIButton *downvoteUIButton;
    UIButton *saveUIButton;
}

@property(nonatomic) BOOL inSaveView;
@property(nonatomic, retain) SGAWSStory *story;
@property(nonatomic, retain) IBOutlet UITableView *storyDetailView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil story:(SGAWSStory *)st;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil story:(SGAWSStory *)st inSaveView:(BOOL)flag;

@end
