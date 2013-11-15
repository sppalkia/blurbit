//
//  SGListGamesViewController.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/24/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGListGamesViewController : UITableViewController {
    NSArray *gameList;
    NSError *_error;
}

@property(nonatomic, retain) NSArray *gameList;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil gameList:(NSArray *)list error:(NSError *)e;

@end
