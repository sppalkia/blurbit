//
//  SGAWSRequest.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/21/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGAWSRequest : NSObject <NSCoding>

@property(nonatomic, retain) NSString *toUUID;
@property(nonatomic, retain) NSString *fromUUID;
@property(nonatomic, retain) NSString *gameURL;

-(id)initWithToUUID:(NSString *)to fromUUID:(NSString *)from url:(NSString *)url;

@end
