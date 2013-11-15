//
//  SGUserInfo.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/11/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGPlayer;
@interface SGUserInfo : NSObject <NSCoding> {
    
    //name, uuid
    //player.idNumber = self.uuid
    SGPlayer *player;
    NSString *uuid;
    NSDate *playerSince;
    
    NSMutableArray *trophies;
    NSInteger upvotes;
    NSInteger downvotes;
    
    NSInteger gamesCreated;
    NSInteger gamesPlayed;
    
    NSInteger rank;
    NSInteger points;
    
    BOOL purchased;
    
    //Purchased Information
    NSString *password;
    NSString *authEmail;
    
    NSMutableArray *friends;
}

@property(nonatomic, retain) SGPlayer *player;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) NSDate *playerSince;

@property(nonatomic, retain) NSMutableArray *trophies;
@property(nonatomic) NSInteger upvotes;
@property(nonatomic) NSInteger downvotes;
@property(nonatomic, readonly) NSInteger votes;

@property(nonatomic) NSInteger rank;
@property(nonatomic) NSInteger points;

@property(nonatomic) NSInteger gamesCreated;
@property(nonatomic) NSInteger gamesPlayed;
@property(nonatomic, readonly) NSInteger contributions;


@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *password;
@property(nonatomic, retain) NSString *authEmail;
@property(nonatomic) BOOL purchased;

@property(nonatomic, retain) NSMutableArray *friends;


//used only when loading the player on startup
-(id)initWithPlayer:(SGPlayer *)aPlayer UUID:(NSString *)aUUID playerSince:(NSDate *)aDate 
           trophies:(NSArray *)trophyCollection 
            upvotes:(NSInteger)upvotes 
          downvotes:(NSInteger)dvotes;

-(void)addFriend:(SGPlayer *)player;
-(void)removeFriendWithUsername:(NSString *)username;


@end
