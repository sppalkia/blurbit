//
//  SGBluetoothGame.h
//  Guava
//
//  Created by Shoumik Palkar on 11/17/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGGame.h"
#import <GameKit/GameKit.h>

@interface SGBluetoothGame : SGGame <GKSessionDelegate> {
    GKSession *session;
}

@property(nonatomic, retain) GKSession *session;

-(void)invalidateSession:(GKSession *)aSession;
-(id)initWithName:(NSString *)name playersOrNil:(NSMutableArray *)playerList session:(GKSession *)aSession;

@end
