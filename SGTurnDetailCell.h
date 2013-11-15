//
//  SGTurnDetailCell.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGTurn;
@interface SGTurnDetailCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UITextView *turnStringView;
@property(nonatomic, retain) IBOutlet UILabel *playedByLabel;

-(void)setTurn:(SGTurn *)turn;

@end
