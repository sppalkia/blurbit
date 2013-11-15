//
//  SGTurn.m
//  Guava
//
//  Created by Shoumik Palkar on 10/10/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGTurn.h"
#import "SGPlayer.h"

@implementation SGTurn
@synthesize player;
@synthesize playString;
@synthesize date;

#pragma mark - Memory Management

-(id)initWithPlayer:(SGPlayer *)aPlayer move:(NSString *)move date:(NSDate *)aDate {
    if (self = [super init]) {
        self.player = aPlayer;
        self.playString = move;
        self.date = aDate;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.player = [coder decodeObjectForKey:@"player"];;
        self.playString = [coder decodeObjectForKey:@"playString"];
        self.date = [coder decodeObjectForKey:@"date"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.player forKey:@"player"];
    [aCoder encodeObject:self.playString forKey:@"playString"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

#pragma mark - Memory Management

-(void)dealloc {
    self.date = nil;
    self.player = nil;
    self.playString = nil;
    [super dealloc];
}
@end
