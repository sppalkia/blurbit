//
//  SGUserInfo.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/11/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGUserInfo.h"
#import "SGPlayer.h"

@implementation SGUserInfo
@synthesize uuid;
@synthesize player;
@synthesize downvotes;
@synthesize upvotes;
@synthesize gamesPlayed;
@synthesize gamesCreated;
@synthesize trophies;
@synthesize playerSince;
@synthesize purchased;
@synthesize password;
@synthesize authEmail;
@synthesize friends;
@synthesize rank;
@synthesize points;

-(id)initWithPlayer:(SGPlayer *)aPlayer UUID:(NSString *)aUUID playerSince:(NSDate *)aDate 
            trophies:(NSArray *)trophyCollection 
            upvotes:(NSInteger)uvotes 
          downvotes:(NSInteger)dvotes {
    if (self = [super init]) {
        self.player = aPlayer;
        self.uuid = aUUID;
        self.playerSince = aDate;
        self.trophies = [NSMutableArray arrayWithArray:trophyCollection];
        self.upvotes = uvotes;
        self.downvotes = dvotes;
        self.purchased = NO;
        self.friends = [NSMutableArray array];
        self.points = 0;
        self.rank = 0;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.player = [aDecoder decodeObjectForKey:@"player"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.trophies = [aDecoder decodeObjectForKey:@"trophies"];
        self.playerSince = [aDecoder decodeObjectForKey:@"playerSince"];
        self.upvotes = [aDecoder decodeIntForKey:@"upvotes"];
        self.upvotes = [aDecoder decodeIntForKey:@"downvotes"];
        self.gamesCreated = [aDecoder decodeIntForKey:@"gamesCreated"];
        self.gamesPlayed = [aDecoder decodeIntForKey:@"gamesPlayed"];
        self.purchased = [aDecoder decodeBoolForKey:@"purchased"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.authEmail = [aDecoder decodeObjectForKey:@"authEmail"];
        self.friends = [aDecoder decodeObjectForKey:@"friends"];
        self.rank = [aDecoder decodeIntForKey:@"rank"];
        self.points = [aDecoder decodeIntForKey:@"points"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.player forKey:@"player"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.trophies forKey:@"trophies"];
    [aCoder encodeObject:self.playerSince forKey:@"playerSince"];
    [aCoder encodeInt:self.upvotes forKey:@"upvotes"];
    [aCoder encodeInt:self.downvotes forKey:@"downvotes"];
    [aCoder encodeInt:self.gamesPlayed forKey:@"gamesPlayed"];
    [aCoder encodeInt:self.gamesCreated forKey:@"gamesCreated"];
    [aCoder encodeBool:self.purchased forKey:@"purchased"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.authEmail forKey:@"authEmail"];
    [aCoder encodeObject:self.friends forKey:@"friends"];
    [aCoder encodeInt:self.rank forKey:@"rank"];
    [aCoder encodeInt:self.points forKey:@"points"];
}

#pragma mark - Methods

-(void)addFriend:(SGPlayer *)player {
    [self.friends addObject:friends];
}

-(void)removeFriendWithUsername:(NSString *)username {
    for (int i = 0; i < [self.friends count]; i++) {
        SGPlayer *p = [self.friends objectAtIndex:i];
        if ([p.name isEqualToString:username]) {
            [self.friends removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark - Custom Properties

-(NSString *)username {
    return self.player.name;
}

-(void)setUsername:(NSString *)username {
    [self.player setName:username];
}

-(NSInteger)votes {
    return self.upvotes - self.downvotes;
}

-(NSInteger)contributions {
    return self.gamesCreated+self.gamesPlayed;
}

-(void)dealloc {
    self.password = nil;
    self.username = nil;
    self.uuid = nil;
    self.player = nil;
    self.playerSince = nil;
    self.trophies = nil;
    self.authEmail = nil;
    [super dealloc];
}

@end
