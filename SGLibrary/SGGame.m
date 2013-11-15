//
//  SGGame.m
//  Guava
//
//  Created by Shoumik Palkar on 10/20/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGGame.h"
#import "SGPlayer.h"
#import "SGTurn.h"
#import "SGRulebook.h"

@implementation SGGame
@synthesize turns;
@synthesize players;
@synthesize gameType;
@synthesize elapsedTurns;
@synthesize name;
@synthesize previousTurn;
@synthesize numberOfTurns;
@synthesize rulebook;
@synthesize currentPlayer;
@synthesize myPlayer;
@synthesize tag;
@synthesize gameOver;
@synthesize dateString;

-(id)initWithName:(NSString *)aName playersOrNil:(NSMutableArray *)playerList {
    if (self = [super init]) {
        self.turns = [[[NSMutableArray alloc] init] autorelease];
        self.players = [[[NSMutableArray alloc] init] autorelease];
        if (playerList) {
            for (int i = 0; i < [playerList count]; i++) {
                [self addPlayer:[playerList objectAtIndex:i]];
            }
        }
        else {
            SGPlayer *defaultPlayer  = [[SGPlayer alloc] initWithName:@"Anonymous"];
            [self addPlayer:defaultPlayer];
            [defaultPlayer release];
        }
        
        self.numberOfTurns = kNumTurns;
        self.gameOver = NO;
        self.gameType = kSGGameTypeSingle;
        self.elapsedTurns = 0;
        self.name = aName;
        self.rulebook = [[SGRulebook alloc] init];
        self.currentPlayer = [self.players objectAtIndex:0];
        NSDate *date = [NSDate date];
        self.dateString = [date description];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.turns = [coder decodeObjectForKey:@"turns"];
        self.players = [coder decodeObjectForKey:@"players"];
        self.gameType = [coder decodeObjectForKey:@"gameType"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.elapsedTurns = [coder decodeIntForKey:@"elapsedTurns"];
        self.numberOfTurns = [coder decodeIntForKey:@"numberOfTurns"];
        self.previousTurn = [coder decodeObjectForKey:@"previousTurn"];
        self.rulebook = [coder decodeObjectForKey:@"rulebook"];
        self.currentPlayer = [coder decodeObjectForKey:@"currentPlayer"];
        self.myPlayer = [coder decodeObjectForKey:@"myPlayer"];
        self.tag = [coder decodeIntForKey:@"tag"];
        self.gameOver = [coder decodeBoolForKey:@"gameOver"];
        self.dateString = [coder decodeObjectForKey:@"dateString"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.turns forKey:@"turns"];
    [aCoder encodeObject:self.players forKey:@"players"];
    [aCoder encodeObject:self.gameType forKey:@"gameType"];
    [aCoder encodeObject:self.name forKey:@"name"];    
    [aCoder encodeInt:self.elapsedTurns forKey:@"elapsedTurns"];
    [aCoder encodeInt:self.numberOfTurns forKey:@"numberOfTurns"];
    [aCoder encodeObject:self.previousTurn forKey:@"previousTurn"];
    [aCoder encodeObject:self.rulebook forKey:@"rulebook"];
    [aCoder encodeObject:self.currentPlayer forKey:@"currentPlayer"];
    [aCoder encodeObject:self.myPlayer forKey:@"myPlayer"];
    [aCoder encodeInt:tag forKey:@"tag"];
    [aCoder encodeBool:gameOver forKey:@"gameOver"];
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
}

-(BOOL)isTurn {
    return YES;
}

-(void)addPlayer:(SGPlayer *)player {
    if (![self.players containsObject:player]) {
        [self.players addObject:player];
    }
}

-(void)addTurn:(SGTurn *)turn {
    self.elapsedTurns++;
    [self.turns addObject:turn];
    self.previousTurn = turn;
    if (self.elapsedTurns >= self.numberOfTurns) {
        self.gameOver = YES;
    }
}

-(BOOL)submitMove:(NSString *)move {
    NSString *output = [self.rulebook applyRules:move];
    if (![SGRulebook producedError:output] && !(self.elapsedTurns >= self.numberOfTurns)) {
        SGTurn *turn = [[SGTurn alloc] initWithPlayer:self.currentPlayer move:output date:[NSDate date]];
        [self addTurn:turn];
        [turn release];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

-(BOOL)submitMove:(NSString *)move withPlayer:(SGPlayer *)player {

    NSString *output = [self.rulebook applyRules:move];
    if (![SGRulebook producedError:output] && !(self.elapsedTurns >= self.numberOfTurns)) {
        SGTurn *turn = [[SGTurn alloc] initWithPlayer:player move:output date:[NSDate date]];
        [self addPlayer:player];
        [self addTurn:turn];
        [turn release];
        return TRUE;
    }
    else {
        return FALSE;
    }

}

-(NSString *)finalizeStory {
    NSString *story = @"";
    for (int i = 0; i < [self.turns count]; i++) {
        NSString *toAdd = [[self.turns objectAtIndex:i] playString];
        toAdd = [@" " stringByAppendingString:toAdd];
        story = [story stringByAppendingString:toAdd];
    }
    return story;
}

-(void)dealloc {
    self.myPlayer = nil;
    self.currentPlayer = nil;
    self.gameType = nil;
    self.rulebook = nil;
    self.name = nil;
    self.turns = nil;
    self.players = nil;
    self.dateString = nil;
    [super dealloc];
}

@end
