//
//  SGAWSStory.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/2/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import "SGStory.h"

@interface SGAWSStory : SGStory {
    NSString *url;
}

@property(nonatomic, retain) NSString *url;

-(id)initWithTurns:(NSArray *)turnList title:(NSString *)aTitle url:(NSString *)u;

@end
