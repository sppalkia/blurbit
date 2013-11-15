//
//  SGCircularGame.m
//  Blurbit
//
//  Created by Shoumik Palkar on 1/27/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGCircularGame.h"
#import "SGRulebook.h"
#import "SGTurn.h"

@implementation SGCircularGame

-(BOOL)submitMove:(NSString *)move {
    SGPlayer *current = self.currentPlayer;
    BOOL canSubmit = [super submitMove:move];
    if ([self.turns count] < kNumTurns) {
        return canSubmit;
    }
    if (canSubmit) {
        //Loop around to first player if last player in line just played.
        NSInteger nextIndex = [self.players indexOfObject:current]+1;
        self.currentPlayer = ([self.players count] == nextIndex) ? [self.players objectAtIndex:0] : [self.players objectAtIndex:nextIndex];
    }
    return canSubmit;
}


@end
