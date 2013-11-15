//
//  SGAWSGame.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGGame.h"

@interface SGAWSGame : SGGame {
    NSString *creatorID;
    NSString *url;
}

@property(nonatomic, copy) NSString *creatorID;
@property(nonatomic, copy) NSString *url;

-(id)initWithName:(NSString *)aName playersOrNil:(NSMutableArray *)playerList uniqueCreatorID:(NSString *)uuid;

@end
