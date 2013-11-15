//
//  SGTurnDetailCell.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/9/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGTurnDetailCell.h"
#import "SGTurn.h"
#import "SGPlayer.h"

@implementation SGTurnDetailCell
@synthesize turnStringView;
@synthesize playedByLabel;

-(void)setTurn:(SGTurn *)turn {
    self.turnStringView.backgroundColor = self.backgroundColor;
    self.turnStringView.text = turn.playString;
    self.playedByLabel.text = [NSString stringWithFormat:@"Played by %@.", turn.player.name];
}

-(void)dealloc {
    self.turnStringView = nil;
    self.playedByLabel = nil;
    [super dealloc];
}

@end
