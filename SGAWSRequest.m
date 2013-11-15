//
//  SGAWSRequest.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/21/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGAWSRequest.h"

@implementation SGAWSRequest 
@synthesize toUUID;
@synthesize fromUUID;
@synthesize gameURL;

-(id)initWithToUUID:(NSString *)to fromUUID:(NSString *)from url:(NSString *)url {
    if (self = [super init]) {
        self.toUUID = to;
        self.fromUUID = from;
        self.gameURL = nil;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.toUUID = [coder decodeObjectForKey:@"toUUID"];;
        self.fromUUID = [coder decodeObjectForKey:@"fromUUID"];
        self.gameURL = [coder decodeObjectForKey:@"gameURL"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.toUUID forKey:@"toUUID"];
    [aCoder encodeObject:self.fromUUID forKey:@"fromUUID"];
    [aCoder encodeObject:self.gameURL forKey:@"gameURL"];
}

-(void)dealloc {
    self.toUUID = nil;
    self.fromUUID = nil;
    self.gameURL = nil;
    [super dealloc];
}

@end
