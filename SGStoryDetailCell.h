//
//  SGStoryDetailCell.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGStory;
@interface SGStoryDetailCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UILabel *upvotesLabel; 
@property(nonatomic, retain) IBOutlet UILabel *downvotesLabel;
@property(nonatomic, retain) IBOutlet UILabel *votesLabel;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *createdByLabel;
@property(nonatomic, retain) IBOutlet UILabel *createdOnLabel;

-(void)setStory:(SGStory *)story;
@end
