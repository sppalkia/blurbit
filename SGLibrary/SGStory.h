//
//  SGStory.h
//  Guava
//
//  Created by Shoumik Palkar on 12/4/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

/*
 This class is only used for a story that is saved
 locally. When the to display stories is loaded, data is fetched
 from 
 */

#import <Foundation/Foundation.h>

@interface SGStory : NSObject <NSCoding> {
    NSInteger upvotes, downvotes;
    NSString *storyString;
    NSArray *turns;
    NSString *title;
    NSDate *date;
}

@property(nonatomic) NSInteger upvotes;
@property(nonatomic) NSInteger downvotes;
@property(nonatomic, copy) NSString *storyString;
@property(nonatomic, retain) NSArray *turns;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, readonly) NSInteger votes;
@property(nonatomic, retain) NSDate *date;

-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle;
-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle upvotes:(NSInteger)up downvotes:(NSInteger)down;

@end
