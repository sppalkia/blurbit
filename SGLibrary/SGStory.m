//
//  SGStory.m
//  Guava
//
//  Created by Shoumik Palkar on 12/4/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGStory.h"
#import "SGTurn.h"

@implementation SGStory
@synthesize upvotes, downvotes;
@synthesize storyString;
@synthesize turns;
@synthesize title;
@synthesize date;

-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle {
    if (self = [super init]) {
        if (turnList) {
            self.turns = turnList;
        }
        else {
            self.turns = [NSArray array];
        }
        self.title = aTitle;
        self.upvotes = 0;
        self.downvotes = 0;
        
        NSString *aStory = @"";
        for (int i = 0; i < [self.turns count]; i++) {
            NSString *toAdd = [[self.turns objectAtIndex:i] playString];
            toAdd = [@" " stringByAppendingString:toAdd];
            aStory = [aStory stringByAppendingString:toAdd];
        }
        self.date = [NSDate date];
        self.storyString = aStory;
    }
    
    return self;
}

-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle upvotes:(NSInteger)up downvotes:(NSInteger)down {
    if (self = [self initWithTurns:turnList title:aTitle]) {
        self.upvotes = up;
        self.downvotes = down;
    }
    return self;
}

-(NSInteger)votes {
    return self.upvotes-self.downvotes;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.turns = [aDecoder decodeObjectForKey:@"turns"];
        self.storyString = [aDecoder decodeObjectForKey:@"storyString"];
        self.upvotes = [aDecoder decodeIntForKey:@"upvotes"];
        self.downvotes = [aDecoder decodeIntForKey:@"downvotes"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.turns forKey:@"turns"];
    [aCoder encodeObject:self.storyString forKey:@"storyString"];
    [aCoder encodeInt:self.upvotes forKey:@"upvotes"];
    [aCoder encodeInt:self.downvotes forKey:@"downvotes"];
}

-(void)dealloc {
    self.date = nil;
    self.title = nil;
    self.storyString = nil;
    self.turns = nil;
    [super dealloc];
}

@end
