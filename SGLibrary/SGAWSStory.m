//
//  SGAWSStory.m
//  Blurbit
//
//  Created by Shoumik Palkar on 3/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGAWSStory.h"

@implementation SGAWSStory
@synthesize url;

-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle url:(NSString *)u {
    if (self = [super initWithTurns:turnList title:aTitle]) {
        self.url = u;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.url forKey:@"url"];
}

-(void)dealloc {
    self.url = nil;
    [super dealloc];
}

@end
