//
//  SGGameListCell.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/1/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGGameListCell.h"
#import "SGGame.h"
#import "SGTurn.h"
#import "SGPlayer.h"
#import "SGUserInfo.h"
#import "SGAppDelegate.h"

@implementation SGGameListCell
@synthesize gameNameLabel;
@synthesize lastPlayedLabel;
@synthesize previousTurnLabel;
@synthesize roundWordLabel;
@synthesize roundNumberLabel;

-(void)setInfoForGame:(SGGame *)game {
    if (game.gameOver) {
        self.gameNameLabel.textColor = self.lastPlayedLabel.textColor = [UIColor darkGrayColor];
        self.previousTurnLabel.textColor = [UIColor lightGrayColor];
        self.roundNumberLabel.textColor = self.roundWordLabel.textColor = [UIColor darkGrayColor];
        self.roundWordLabel.text = @"Finished";
    }
    else {
        self.gameNameLabel.textColor = self.lastPlayedLabel.textColor = [UIColor darkTextColor];
        self.previousTurnLabel.textColor = [UIColor darkGrayColor];
        self.roundNumberLabel.textColor = self.roundWordLabel.textColor = [UIColor blueColor];
    }   
    if ([game.turns count] == game.numberOfTurns-1) {
        self.roundNumberLabel.textColor = self.roundWordLabel.textColor = [UIColor redColor];
    }
    
    /*
    if (game.currentPlayer != nil) {
        //for circular games
        SGPlayer *current = game.currentPlayer;
        SGUserInfo *userInfo = [(SGAppDelegate *)[[UIApplication sharedApplication] delegate] userInfo];
        if ([[current idNumber] isEqualToString:userInfo.uuid])
            self.roundNumberLabel.textColor = self.roundWordLabel.textColor = [UIColor greenColor];
    }
    */

    
    NSString *lastPlayed = game.previousTurn.player.name;
    
    NSString *gameDetails;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd"];
    NSString *datePlayed = [dateFormat stringFromDate:game.previousTurn.date];
    [dateFormat release];
    gameDetails = [NSString stringWithFormat:@"Last played by \"%@\" on %@", lastPlayed, datePlayed];
    
    NSUInteger numTurns = [game.turns count];
    
    self.gameNameLabel.text = game.name;
    self.previousTurnLabel.text = [NSString stringWithFormat: @"\"%@\"", game.previousTurn.playString];
    self.lastPlayedLabel.text = gameDetails;
    
    if (!game.gameOver) {
        self.roundNumberLabel.text = getPostFixedNumber(numTurns);
        self.roundWordLabel.text = @"Round";
    }
    else
        self.roundNumberLabel.text = @"";
    

}

-(void)dealloc {
    self.gameNameLabel = nil;
    self.lastPlayedLabel = nil;
    self.previousTurnLabel = nil;
    self.roundNumberLabel = nil;
    self.roundWordLabel = nil;
    [super dealloc];
}

@end
