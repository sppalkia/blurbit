//
//  SGFullStoryCell.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGFullStoryCell.h"
#import "SGStory.h"

@implementation SGFullStoryCell
@synthesize fullStoryView;

-(void)setStory:(SGStory *)story {
    self.fullStoryView.backgroundColor = self.backgroundColor;
    self.fullStoryView.text = story.storyString;
    [self layoutSubviews];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.fullStoryView.frame = CGRectMake(5, 5, self.frame.size.width-40, self.frame.size.height-20);
}

-(void)dealloc {
    self.fullStoryView = nil;
    [super dealloc];
}

@end
