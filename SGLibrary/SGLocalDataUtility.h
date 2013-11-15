//
//  SGLocalDataUtility.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/27/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SGUserInfo, UserInfo;
@interface SGLocalDataUtility : NSObject {
    NSManagedObjectContext *managedObjectContext;
    NSMutableDictionary *_managedGameURLs, *_managedStoryURLs;
    UserInfo *_userInfo;
}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

-(NSArray *)getGameURLs;
-(void)writeGameURL:(NSString *)url;
-(void)removeGameURL:(NSString *)url;

-(NSArray *)getStoryURLs;
-(void)writeStoryURL:(NSString *)url;
-(void)removeStoryURL:(NSString *)url;

-(void)writeUserInfo:(SGUserInfo *)userInfo;
-(SGUserInfo *)getUserInfo;

-(BOOL)commitChanges;


@end
