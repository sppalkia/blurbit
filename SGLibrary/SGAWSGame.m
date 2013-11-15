//
//  SGAWSGame.m
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGAWSGame.h"

@implementation SGAWSGame
@synthesize creatorID;
@synthesize url;

-(id)initWithName:(NSString *)aName playersOrNil:(NSMutableArray *)playerList uniqueCreatorID:(NSString *)uuid {
    if (self = [super initWithName:aName playersOrNil:playerList]) {
        self.creatorID = uuid;
        self.url = [NSString stringWithFormat:@"%@/%@", self.name, self.dateString];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.creatorID = [coder decodeObjectForKey:@"creatorID"];
        self.url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.creatorID forKey:@"creatorID"];
    [aCoder encodeObject:self.url forKey:@"url"];
}


-(void)dealloc {
    self.url = nil;
    self.creatorID = nil;
    [super dealloc];
}

@end
