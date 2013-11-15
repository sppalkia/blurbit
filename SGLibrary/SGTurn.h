//
//  SGTurn.h
//  Guava
//
//  Created by Shoumik Palkar on 10/10/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGPlayer;
@interface SGTurn : NSObject <NSCoding> {
    SGPlayer *player;
    NSString *playString;
    NSDate *date;
}

@property(nonatomic, retain) NSDate *date;
@property(nonatomic, retain) SGPlayer *player;
@property(nonatomic, copy) NSString *playString;

-(id)initWithPlayer:(SGPlayer *)aPlayer move:(NSString *)move date:(NSDate *)aDate;
@end
