//
//  SGPlayer.m
//  Guava
//
//  Created by Shoumik Palkar on 10/10/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import "SGPlayer.h"

@implementation SGPlayer
@synthesize name;
@synthesize idNumber;

-(id)initWithName:(NSString *)aName {
    if (self = [super init]) {
        self.name = aName;
        self.idNumber = @"";
    }
    return self;
}

-(id)initWithName:(NSString *)aName uuid:(NSString *)aID {
    if (self = [super init]) {
        self.name = aName;
        if (!aID) aID = @"";
        self.idNumber = aID;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.idNumber = [coder decodeObjectForKey:@"idNumber"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:@"idNumber"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

-(void)dealloc {
    self.name = nil;
    [idNumber release];
    [super dealloc];
}
@end
