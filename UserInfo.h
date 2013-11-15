//
//  UserInfo.h
//  Blurbit
//
//  Created by Shoumik Palkar on 3/19/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic) int32_t downvotes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval playerSince;
@property (nonatomic, retain) NSString * trophies;
@property (nonatomic) int32_t upvotes;
@property (nonatomic, retain) NSString * uuid;

@end
