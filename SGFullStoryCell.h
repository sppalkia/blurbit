//
//  SGFullStoryCell.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGStory;
@interface SGFullStoryCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UITextView *fullStoryView;

-(void)setStory:(SGStory *)story;

@end
