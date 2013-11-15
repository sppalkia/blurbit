//
//  SGPlayer.h
//  Guava
//
//  Created by Shoumik Palkar on 10/10/11.
//  Copyright (c) 2011 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGPlayer : NSObject <NSCoding> {
    NSString *name;
    NSString *idNumber;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *idNumber;

-(id)initWithName:(NSString *)aName;
-(id)initWithName:(NSString *)aName uuid:(NSString *)aID;

@end
