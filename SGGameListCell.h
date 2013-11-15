//
//  SGGameListCell.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/1/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGGame;
@interface SGGameListCell : UITableViewCell {
    IBOutlet UILabel *gameNameLabel;
    IBOutlet UILabel *lastPlayedLabel;
    IBOutlet UILabel *previousTurnLabel;
    IBOutlet UILabel *roundNumberLabel;
    IBOutlet UILabel *roundWordLabel;
}
                                    

@property(nonatomic, retain) IBOutlet UILabel *gameNameLabel;
@property(nonatomic, retain) IBOutlet UILabel *lastPlayedLabel;
@property(nonatomic, retain) IBOutlet UILabel *previousTurnLabel;
@property(nonatomic, retain) IBOutlet UILabel *roundNumberLabel;
@property(nonatomic, retain) IBOutlet UILabel *roundWordLabel;

-(void)setInfoForGame:(SGGame *)game;


@end
