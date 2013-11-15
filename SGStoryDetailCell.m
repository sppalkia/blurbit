//
//  SGStoryDetailCell.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStoryDetailCell.h"
#import "SGStory.h"
#import "SGTurn.h"
#import "SGPlayer.h"

@implementation SGStoryDetailCell
@synthesize upvotesLabel;
@synthesize downvotesLabel;
@synthesize titleLabel;
@synthesize votesLabel;
@synthesize createdByLabel;
@synthesize createdOnLabel;

-(void)setStory:(SGStory *)story {
    self.upvotesLabel.text = [NSString stringWithFormat:@"%d", story.upvotes];
    self.downvotesLabel.text = [NSString stringWithFormat:@"%d", story.downvotes];
    self.votesLabel.text = [NSString stringWithFormat:@"%d", story.votes];
    self.titleLabel.text = story.title;
    
    SGTurn *firstTurn = [story.turns objectAtIndex:0];
    self.createdByLabel.text = firstTurn.player.name;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeStyle:NSDateFormatterNoStyle];
    NSString *datePlayed = [dateFormat stringFromDate:story.date];
    [dateFormat release];
    self.createdOnLabel.text = datePlayed;
}

-(void)dealloc {
    self.upvotesLabel = nil;
    self.downvotesLabel = nil;
    self.votesLabel = nil;
    self.titleLabel = nil;
    [super dealloc];
}

@end
