//
//  SGAWSUtility.h
//  Blurbit
//
//  Created by Shoumik Palkar on 2/3/12.
//  Copyright (c) 2012 Shoumik Palkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SGAWSGame, SGAWSStory, SGUserInfo;

typedef NSString* SGStoryQuery;

extern const SGStoryQuery VOTE_QUERY;
extern const SGStoryQuery TITLE_QUERY;
extern const SGStoryQuery NEWEST_QUERY;
extern const SGStoryQuery LOCAL_QUERY;

@interface SGAWSUtility : NSObject

+(NSString *)pushStory:(SGAWSStory *)story;
+(NSString *)pushGame:(SGAWSGame *)game;
+(NSMutableArray *)fetchGames;
+(NSMutableArray *)fetchStoriesByQuery:(SGStoryQuery)query;
+(NSMutableArray *)fetchGamesWithURLs:(NSArray *)urls;
+(NSMutableArray *)fetchStoriesWithURLs:(NSArray *)urls;

+(NSString *)pushUserInfo:(SGUserInfo *)userInfo;
+(SGUserInfo *)fetchUserInfo:(NSString *)aURL;
+(SGUserInfo *)fetchInfoWithUsername:(NSString *)uname password:(NSString *)password;

+(void)resetQuery;

@end
