//
//  SGListGamesViewController.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/24/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGListGamesViewController.h"
#import "SGPlayGameViewController.h"
#import "SVProgressHUD.h"
#import "SGGame.h"
#import "SGTurn.h"

@implementation SGListGamesViewController
@synthesize gameList;

#define ROW_HEIGHT  70

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil gameList:(NSArray *)list error:(NSError *)e {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        if (!list)
            list = [NSArray array];
        _error = nil;
        if (e) {
            _error = e;
            [_error retain];
        }
        
        self.gameList = list;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    if ([_error code] == NETWORK_ERROR) {
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"A network connection could not be established." afterDelay:2];
    }
    else if ([self.gameList count] == 0) {
        [SVProgressHUD show];
        [SVProgressHUD dismissWithError:@"No Games Found. Why not create one?" afterDelay:2];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    UIImage *bubbleImage = [UIImage imageNamed:@"comment.png"];
    cell.imageView.image = bubbleImage;

    SGGame *game = [gameList objectAtIndex:[indexPath row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = game.name;
    cell.detailTextLabel.text = game.previousTurn.playString;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SGPlayGameViewController *controller = [[SGPlayGameViewController alloc] initWithNibName:@"SGPlayGameViewController" bundle:nil];
    controller.game = [gameList objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - Memory

-(void)dealloc {
    if (_error)
        [_error release];
    self.gameList = nil;
    [super dealloc];
}

@end
