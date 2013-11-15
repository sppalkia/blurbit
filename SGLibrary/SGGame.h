//
//  SGGame.h
//  Guava
//
//  Created by Shoumik Palkar on 10/20/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString SGGameType;

//This is an abstract class. Only instantiate 
//subclasses of SGGame
@class SGPlayer, SGTurn, SGRulebook;
@interface SGGame : NSObject <NSCoding> {
    NSMutableArray *turns;
    NSMutableArray *players;
    SGGameType *gameType;
    NSInteger elapsedTurns;
    NSInteger numberOfTurns;
    NSString *name;
    SGTurn *previousTurn;
    SGRulebook *rulebook;
    SGPlayer *currentPlayer;
    SGPlayer *myPlayer;
    
    NSInteger tag;
    NSString *dateString;
    BOOL gameOver;
}

@property(nonatomic, retain) NSMutableArray *turns;
@property(nonatomic, retain) NSMutableArray *players;
@property(nonatomic, retain) SGGameType *gameType;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, retain) SGTurn *previousTurn;
@property(nonatomic, retain) SGRulebook *rulebook;
@property(nonatomic, retain) SGPlayer *currentPlayer;
@property(nonatomic, retain) SGPlayer *myPlayer;
@property(nonatomic, copy) NSString *dateString;
@property(nonatomic) BOOL gameOver;
@property(nonatomic) NSInteger tag;
@property(nonatomic) NSInteger elapsedTurns;
@property(nonatomic) NSInteger numberOfTurns;


-(id)initWithName:(NSString *)name playersOrNil:(NSMutableArray *)playerList;
-(void)addPlayer:(SGPlayer *)player;
-(void)addTurn:(SGTurn *)turn;
-(BOOL)submitMove:(NSString *)move;
-(BOOL)submitMove:(NSString *)move withPlayer:(SGPlayer *)player;
-(BOOL)isTurn;
-(NSString *)finalizeStory;

@end
