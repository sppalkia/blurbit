//
//  SGBluetoothGame.m
//  Guava
//
//  Created by Shoumik Palkar on 11/17/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGBluetoothGame.h"
#import "Constants.h"
#import "SGTurn.h"
#import "SGPlayer.h"

@implementation SGBluetoothGame
@synthesize session;

-(id)initWithName:(NSString *)name playersOrNil:(NSMutableArray *)playerList session:(GKSession *)aSession {
    if (self = [super initWithName:name playersOrNil:playerList]) {
        self.session = aSession;
        self.session.delegate = self;
        self.gameType = kSGGameTypeBluetooth;
        [self.session setDataReceiveHandler:self withContext:nil];
        for (SGPlayer* p in playerList) {
            if ([p.name isEqualToString:[self.session displayNameForPeer:self.session.peerID]]) {
                self.myPlayer = p;
                NSLog(@"The player is included in the peer list");
            }
        }
    }
    return self;
}

-(BOOL)isTurn {
    return (self.myPlayer == self.currentPlayer);
}

-(void)invalidateSession:(GKSession *)aSession {
    if(aSession != nil) {
		[aSession disconnectFromAllPeers]; 
		aSession.available = NO; 
		[aSession setDataReceiveHandler: nil withContext: NULL]; 
		aSession.delegate = nil; 
	}
}

-(void)sendMoveOverBluetooth:(NSString *)move {
    //encapsulate SGTurn data and send it to all other peers
    NSData *data;
    NSString *str = self.previousTurn.playString;
    data = [str dataUsingEncoding:NSASCIIStringEncoding];
    if (self.session) {
        [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}

-(BOOL)submitMove:(NSString *)move {
    if ([super submitMove:move]) {
        [self sendMoveOverBluetooth:move];
        return TRUE;
    }
    return FALSE;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
            [self invalidateSession:self.session];
            break;
        default:
            break;
    }
}

- (void)receiveData:(NSData *)data 
           fromPeer:(NSString *)peer 
          inSession:(GKSession *)session 
            context:(void *)context {
    
    NSString *move = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [super submitMove:move];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Player Played!" 
                                                    message:move
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release]; 

}

-(void)dealloc {
    self.session = nil;
    [super dealloc];
}

@end
