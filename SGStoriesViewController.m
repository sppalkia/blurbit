//
//  SGStoriesViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStoriesViewController.h"
#import "SGStoryDetailViewController.h"
#import "SGLocalDataUtility.h"
#import "SGAppDelegate.h"
#import "SGAWSStory.h"
#import "SGAWSUtility.h"
#import "SGStoryDetailCell.h"
#import "SVProgressHUD.h"

@implementation SGStoriesViewController
@synthesize query;
@synthesize stories;
@synthesize listView;
@synthesize presentedParent;

#define NO_QUERY        @"No Query"
#define MAX_NUM_FETCHED 10

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil query:(SGStoryQuery)q error:(NSError *)error {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.query = q;
        self.stories = [NSArray array];
        if (error) {
            _error = error;
            [_error retain];
        }
    }
    return self;
}

-(void)back {
    if (self.presentedParent)
        [self.presentedParent dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    _doneLoadingStories = NO;
    [super viewDidLoad];
    if (!self.query) {
        self.query = LOCAL_QUERY;
    }
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:RGBA_BAR_COLORS[0] 
                                                                        green:RGBA_BAR_COLORS[1] 
                                                                         blue:RGBA_BAR_COLORS[2] 
                                                                        alpha:RGBA_BAR_COLORS[3]];
    self.navigationController.navigationBar.topItem.hidesBackButton = YES;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = backButton;
    [backButton release];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.listView reloadData];
    self.navigationController.navigationBar.topItem.title = @"Stories";
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.query isEqualToString:LOCAL_QUERY]) {
        self.navigationController.navigationBar.topItem.title = @"Saved Stories";
    }
    if ([self.query isEqualToString:VOTE_QUERY]) {
        self.navigationController.navigationBar.topItem.title = @"Top Rated";
    }
    if ([self.query isEqualToString:NEWEST_QUERY]) {
        self.navigationController.navigationBar.topItem.title = @"Newest";
    }
    
    if (_error) {
        [SVProgressHUD show];
        switch ([_error code]) {
            case 1:
                [SVProgressHUD dismissWithError:@"A network connection could not be established" afterDelay:2.5];
                break;
            default:
                [SVProgressHUD dismissWithError:@"An unknown error occurred" afterDelay:2.5];
                break;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}


#pragma mark - Table View Data Source + Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.query isEqualToString:LOCAL_QUERY])
        return [self.stories count];
    return [self.stories count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *StoryDetailCellIdentifier = @"SGStoryDetailCell";
    static NSString *LoadMoreCellIdentifier = @"CellIdentifier";
    
    BOOL local = [self.query isEqualToString:LOCAL_QUERY];
    if (local || ([indexPath row] < [self.stories count])) {
        SGStoryDetailCell *cell = (SGStoryDetailCell *)[tableView dequeueReusableCellWithIdentifier:StoryDetailCellIdentifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SGStoryDetailCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SGStoryDetailCell *)view;
                }
            }
        }
        
        SGAWSStory *story = [self.stories objectAtIndex:[indexPath row]];
        [cell setStory:story];
        return cell;    
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:LoadMoreCellIdentifier] autorelease];
        }
        cell.textLabel.text = @"                 More Stories...";
        cell.detailTextLabel.text = @"                 Load the next 10 Stories.";
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BOOL local = [self.query isEqualToString:LOCAL_QUERY];
    if ((local || ([indexPath row] < [self.stories count]))) {
        SGStoryDetailViewController *controller;
        if (!local) {
            controller = [[SGStoryDetailViewController alloc] initWithNibName:@"SGStoryDetailViewController" 
                                                                       bundle:nil 
                                                                        story:[self.stories objectAtIndex:[indexPath row]]];
        }
        else {
            controller = [[SGStoryDetailViewController alloc] initWithNibName:@"SGStoryDetailViewController" 
                                                                       bundle:nil 
                                                                        story:[self.stories objectAtIndex:[indexPath row]]
                                                                   inSaveView:YES];
            
        }
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else {
        if (_doneLoadingStories) {
            [SVProgressHUD show];
            [SVProgressHUD dismissWithError:@"All Stories Loaded!" afterDelay:1.5];
            return;
        }
        [SVProgressHUD showWithStatus:@"Loading More Stories..."];
        NSMutableArray *moreStories = [SGAWSUtility fetchStoriesByQuery:self.query];
        
        while (!moreStories) {}
        if ([moreStories count] > 0 && [moreStories objectAtIndex:0] == ERROR_ID) {
            [SVProgressHUD dismissWithError:@"Stories could not be loaded"];
            return;
        }
        
        if ([moreStories count] < MAX_NUM_FETCHED) {
            _doneLoadingStories = YES;
        }
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < [self.stories count]; i++) {
            SGAWSStory *story = [self.stories objectAtIndex:i];
            for (int j = 0; j < [moreStories count]; j++) {
                SGAWSStory *comp = [moreStories objectAtIndex:j];
                if ([[comp url] isEqualToString:[story url]]) {
                    [moreStories removeObjectAtIndex:j];
                    j--;
                }
            }
        }
        NSUInteger currentCount  = [self.stories count];
        for (int i = 0; i < [moreStories count]; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:currentCount+i inSection:0];
            [indexPaths addObject:path];
        }
        [self.stories addObjectsFromArray:moreStories];
        [self.listView beginUpdates];
        [self.listView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.listView endUpdates];
        [SVProgressHUD dismiss];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.query isEqualToString:LOCAL_QUERY]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.editing = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.query isEqualToString:LOCAL_QUERY]) {
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SGAWSStory *story = [[self.stories objectAtIndex:[indexPath row]] retain];
        NSString *url = story.url;
        
        SGAppDelegate *delegate = (SGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.localDataUtility removeStoryURL:url];
        
        [self.stories removeObjectAtIndex:[indexPath row]];
        [story release];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


#pragma mark - Memory Management

-(void)dealloc {
    if (_error)
        [_error release];
    self.presentedParent = nil;
    self.query = nil;
    self.stories = nil;
    self.listView = nil;
    [super dealloc];
}
@end
